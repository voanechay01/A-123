import tkinter as tk
from PIL import Image, ImageDraw, ImageGrab, ImageTk, ImageFont
import keyboard
import os, sys, atexit

# --- WRITE PID ON START ---
_HERE = os.path.dirname(os.path.abspath(__file__))   # resources/
_ROOT = os.path.dirname(_HERE)                       # A-123/
PIDFILE = os.path.join(_HERE, "a-123.pid")
try:
    with open(PIDFILE, "w") as f:
        f.write(str(os.getpid()))
except Exception:
    pass

def _cleanup_pid():
    try:
        os.remove(PIDFILE)
    except Exception:
        pass
atexit.register(_cleanup_pid)
# -----------------------------

# --- LOAD CONFIG ---
sys.path.insert(0, _HERE)
try:
    import config
except ImportError:
    print("[CONFIG] config.py NOT FOUND — USING DEFAULTS")
    class config:
        KEY_SHOT = "z"
        ANIMATION_ENABLED = 1
        ACTIVE_GLOW_ENABLED = 1
        ANIMATION_MS = 150
        MAX_SHOTS = 2
        BORDER_COLOR = "#ffdebd"
# -----------------------------

# ==================== SETTINGS ====================
SHOT_W, SHOT_H = 300, 100     # SCREENSHOT SIZE AROUND CROSSHAIR
BORDER         = 3            # FRAME THICKNESS
RADIUS         = 14           # CORNER RADIUS
ALPHA          = 1.0          # WINDOW OPACITY

TRANSPARENT_KEY = "#010203"
HIDE_DELAY_MS   = 150
WINDOW_OFFSET_X = 40
WINDOW_OFFSET_Y = 70
STACK_GAP       = 8
NUMBER_ALPHA    = 100
NUMBER_SIZE     = 22
NUMBER_OFFSET   = (6, 4)

# FONT IS IN A-123/fonts/ (OUTSIDE resources/)
FONT_FILE = os.path.join(_ROOT, "fonts", "DOORS.ttf")

# CONFIG-DRIVEN VALUES (SAFE TYPE CASTING)
def _to_int(v, default):
    try:
        return int(v)
    except (TypeError, ValueError):
        return default

MAX_SHOTS      = max(1, min(4, _to_int(config.MAX_SHOTS, 2)))
BORDER_COLOR   = str(config.BORDER_COLOR)
ANIMATION_ON   = _to_int(config.ANIMATION_ENABLED, 1)
GLOW_ON        = _to_int(config.ACTIVE_GLOW_ENABLED, 1)
ANIMATION_MS   = _to_int(config.ANIMATION_MS, 150)
KEY_SHOT       = str(config.KEY_SHOT).strip().lower()
# ===================================================


# --- FONT ---
def get_font(size):
    if os.path.exists(FONT_FILE):
        try:
            return ImageFont.truetype(FONT_FILE, size)
        except Exception as e:
            print(f"[FONT] CANNOT LOAD {FONT_FILE}: {e}")
    else:
        print(f"[FONT] NOT FOUND: {FONT_FILE} — USING SYSTEM FONT")
    for p in ("C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf",
              "segoeui.ttf", "arial.ttf", "DejaVuSans.ttf"):
        try:
            return ImageFont.truetype(p, size)
        except Exception:
            continue
    return ImageFont.load_default()


# --- ANTI-ALIASED ROUNDED MASK ---
def rounded_mask(size, radius, ss=4):
    w, h = size
    if w <= 0 or h <= 0:
        return Image.new("L", (max(w, 1), max(h, 1)), 0)
    big = Image.new("L", (w * ss, h * ss), 0)
    ImageDraw.Draw(big).rounded_rectangle(
        (0, 0, w * ss - 1, h * ss - 1),
        radius=radius * ss, fill=255,
    )
    return big.resize((w, h), Image.LANCZOS)


def hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))


def build_framed(screenshot, number=None, is_active=False):
    """RETURNS A SINGLE IMAGE: ROUNDED FRAME + ROUNDED SCREENSHOT INSIDE."""
    inner = screenshot.convert("RGBA")
    inner_mask = rounded_mask(inner.size, max(RADIUS - BORDER, 2))
    inner_rounded = Image.new("RGBA", inner.size, (0, 0, 0, 0))
    inner_rounded.paste(inner, (0, 0), inner_mask)

    total_w = inner.size[0] + 2 * BORDER
    total_h = inner.size[1] + 2 * BORDER

    # FRAME COLOR — brighter for active (glow effect)
    base_rgb = hex_to_rgb(BORDER_COLOR)
    if is_active and GLOW_ON:
        frame_rgb = tuple(min(255, c + 70) for c in base_rgb)
    else:
        frame_rgb = base_rgb

    frame_mask = rounded_mask((total_w, total_h), RADIUS)
    frame_layer = Image.new("RGBA", (total_w, total_h), frame_rgb + (255,))
    frame_layer.putalpha(frame_mask)

    shot_layer = Image.new("RGBA", (total_w, total_h), (0, 0, 0, 0))
    shot_layer.paste(inner_rounded, (BORDER, BORDER), inner_rounded)

    canvas = Image.alpha_composite(frame_layer, shot_layer)

    # NUMBER
    if number is not None:
        draw = ImageDraw.Draw(canvas, "RGBA")
        font = get_font(NUMBER_SIZE)
        x = BORDER + NUMBER_OFFSET[0]
        y = BORDER + NUMBER_OFFSET[1]
        draw.text((x, y), str(number),
                  fill=(255, 255, 255, NUMBER_ALPHA), font=font)
    return canvas


class App:
    def __init__(self):
        self.root = tk.Tk()
        self.root.overrideredirect(True)
        self.root.attributes("-topmost", True)
        self.root.attributes("-alpha", ALPHA)
        self.root.configure(bg=TRANSPARENT_KEY)
        try:
            self.root.wm_attributes("-transparentcolor", TRANSPARENT_KEY)
        except Exception:
            pass

        self.shot_w = SHOT_W + 2 * BORDER
        self.shot_h = SHOT_H + 2 * BORDER
        self.slot   = self.shot_h + STACK_GAP

        self.sw = self.root.winfo_screenwidth()
        self.sh = self.root.winfo_screenheight()

        self.canvas = tk.Canvas(self.root, bg=TRANSPARENT_KEY,
                                highlightthickness=0, bd=0)
        self.canvas.pack(fill="both", expand=True)

        self.shots   = []
        self._photos = []
        self.busy    = False
        self._anim_gen = 0

        self.move_offscreen()

        try:
            keyboard.on_press_key(KEY_SHOT,
                                  lambda e: self.root.after(0, self.take_shot))
            keyboard.on_press_key("esc",
                                  lambda e: self.root.after(0, self.clear))
            print(f"[OK] HOTKEY: SHOT='{KEY_SHOT}' CLEAR='esc'")
            print(f"[OK] FEATURES: ANIM={ANIMATION_ON} "
                  f"GLOW={GLOW_ON} MAX={MAX_SHOTS}")
        except Exception as e:
            print("[ERROR]", e)

        self.root.mainloop()

    def move_offscreen(self):
        self.root.geometry("1x1+-10000+-10000")
        self.root.update_idletasks()

    def move_to_position(self, extra_h=0):
        n = len(self.shots)
        if n <= 0:
            self.move_offscreen()
            return
        w = self.shot_w
        h = n * self.shot_h + (n - 1) * STACK_GAP + extra_h
        x = WINDOW_OFFSET_X
        y = self.sh - h - WINDOW_OFFSET_Y
        self.root.geometry(f"{w}x{h}+{x}+{y}")
        self.root.update_idletasks()
        self.root.lift()
        self.root.attributes("-topmost", True)

    def take_shot(self):
        if self.busy:
            return
        self.busy = True
        self.move_offscreen()
        self.root.after(HIDE_DELAY_MS, self._do_shot)

    def _do_shot(self):
        try:
            x1 = self.sw // 2 - SHOT_W // 2
            y1 = self.sh // 2 - SHOT_H // 2
            img = ImageGrab.grab(bbox=(x1, y1, x1 + SHOT_W, y1 + SHOT_H))

            n_old = len(self.shots)
            old_shots = list(self.shots)

            self.shots.append(img)
            while len(self.shots) > MAX_SHOTS:
                self.shots.pop(0)

            n_new = len(self.shots)
            print(f"[SHOT] {n_new}/{MAX_SHOTS}")

            # АНИМАЦИЯ ТОЛЬКО ЕСЛИ СТЕК ЕЩЁ НЕ ПОЛОН
            if ANIMATION_ON and n_old > 0 and n_old < MAX_SHOTS:
                overflow = max(0, n_old + 1 - MAX_SHOTS)
                anim = []
                for k in range(n_new):
                    end_y = k * self.slot
                    src_idx = k + overflow
                    if src_idx < n_old and old_shots[src_idx] is self.shots[k]:
                        start_y = src_idx * self.slot
                    else:
                        start_y = end_y + self.slot
                    anim.append((self.shots[k], start_y, end_y))

                self.move_to_position(extra_h=self.slot)
                self.root.deiconify()
                self._start_animation(anim)
            else:
                self.redraw()
                self.move_to_position()
                self.root.deiconify()
                self.busy = False
        except Exception as e:
            print("[SHOT ERROR]", e)
            self.busy = False

    # ---------- ANIMATION ----------
    def _start_animation(self, anim):
        self._anim_gen += 1
        my_gen = self._anim_gen
        frames = max(1, ANIMATION_MS // 16)
        delay  = max(1, ANIMATION_MS // frames)
        n = len(anim)

        def step(i):
            # IF NEW ANIMATION STARTED — CANCEL THIS ONE
            if my_gen != self._anim_gen:
                return
            try:
                t = min(1.0, i / frames)
                t = 1 - (1 - t) ** 3                 # EASE-OUT CUBIC
                positions = [s + (e - s) * t for _, s, e in anim]
                self._draw_at(anim, positions, n)

                if i < frames:
                    self.root.after(delay, step, i + 1)
                else:
                    self.redraw()
                    self.move_to_position()
                    self.busy = False
            except Exception as e:
                print("[ANIM ERROR]", e)
                self.redraw()
                self.move_to_position()
                self.busy = False

        step(0)

    def _draw_at(self, anim, positions, n):
        self.canvas.delete("all")
        self._photos = []
        for k, ((shot, _, _), y) in enumerate(zip(anim, positions)):
            is_active = (k == n - 1)
            framed = build_framed(shot, number=k + 1, is_active=is_active)
            photo = ImageTk.PhotoImage(framed)
            self._photos.append(photo)
            self.canvas.create_image(0, int(round(y)), anchor="nw", image=photo)

    # ---------- STATIC REDRAW ----------
    def redraw(self):
        self.canvas.delete("all")
        self._photos = []
        n = len(self.shots)
        for i, shot in enumerate(self.shots):
            is_active = (i == n - 1)
            framed = build_framed(shot, number=i + 1, is_active=is_active)
            photo = ImageTk.PhotoImage(framed)
            self._photos.append(photo)
            self.canvas.create_image(0, i * self.slot, anchor="nw", image=photo)

    def clear(self):
        self.shots = []
        self.canvas.delete("all")
        self._photos = []
        self.move_offscreen()
        print("[CLEAR]")


if __name__ == "__main__":
    App()
