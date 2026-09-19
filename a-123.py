import tkinter as tk
from PIL import Image, ImageDraw, ImageGrab, ImageTk
import keyboard
import os, atexit

# --- WRITE PID ON START ---
PIDFILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "a-123.pid")
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

# ==================== SETTINGS ====================
SHOT_W, SHOT_H = 300, 100     # SCREENSHOT SIZE AROUND CROSSHAIR
BORDER         = 3            # FRAME THICKNESS
RADIUS         = 14           # CORNER RADIUS
ALPHA          = 1.0          # WINDOW OPACITY

BORDER_COLOR    = "#ffdebd"
TRANSPARENT_KEY = "#010203"

HIDE_DELAY_MS   = 150
WINDOW_OFFSET_X = 40
WINDOW_OFFSET_Y = 70
# ===================================================


def rounded_mask(size, radius):
    m = Image.new("L", size, 0)
    ImageDraw.Draw(m).rounded_rectangle(
        (0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255
    )
    return m


def build_framed(screenshot):
    """RETURNS A SINGLE IMAGE: ROUNDED FRAME + ROUNDED SCREENSHOT INSIDE."""
    # INNER SCREENSHOT WITH ROUNDED CORNERS
    inner = screenshot.convert("RGBA")
    inner_mask = rounded_mask(inner.size, max(RADIUS - BORDER, 2))
    inner_rounded = Image.new("RGBA", inner.size, (0, 0, 0, 0))
    inner_rounded.paste(inner, (0, 0), inner_mask)

    # TOTAL CANVAS = SCREENSHOT + FRAME ON BOTH SIDES
    total_w = inner.size[0] + 2 * BORDER
    total_h = inner.size[1] + 2 * BORDER

    canvas = Image.new("RGBA", (total_w, total_h), (0, 0, 0, 0))
    # FRAME BACKGROUND — FILL WITH BORDER COLOR USING ROUNDED MASK
    frame_mask = rounded_mask((total_w, total_h), RADIUS)
    border_layer = Image.new("RGBA", (total_w, total_h),
                             tuple(int(BORDER_COLOR.lstrip('#')[i:i+2], 16)
                                   for i in (0, 2, 4)) + (255,))
    canvas.paste(border_layer, (0, 0), frame_mask)

    # PLACE ROUNDED SCREENSHOT ON TOP
    canvas.paste(inner_rounded, (BORDER, BORDER), inner_rounded)
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

        self.W = SHOT_W + 2 * BORDER
        self.H = SHOT_H + 2 * BORDER

        self.sw = self.root.winfo_screenwidth()
        self.sh = self.root.winfo_screenheight()

        self.canvas = tk.Canvas(self.root, bg=TRANSPARENT_KEY,
                                highlightthickness=0, bd=0)
        self.canvas.pack(fill="both", expand=True)

        self.photo = None
        self.busy  = False

        self.move_offscreen()

        try:
            keyboard.on_press_key("z", lambda e: self.root.after(0, self.take_shot))
            keyboard.on_press_key("я", lambda e: self.root.after(0, self.take_shot))
            keyboard.on_press_key("esc", lambda e: self.root.after(0, self.move_offscreen))
            print("[OK] HOTKEYS INSTALLED (Z/Я — SCREENSHOT, ESC — HIDE)")
        except Exception as e:
            print("[ERROR]", e)

        self.root.mainloop()

    def move_offscreen(self):
        self.root.geometry("1x1+-10000+-10000")
        self.root.update_idletasks()

    def move_to_position(self):
        x = WINDOW_OFFSET_X
        y = self.sh - self.H - WINDOW_OFFSET_Y
        self.root.geometry(f"{self.W}x{self.H}+{x}+{y}")
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

            framed = build_framed(img)
            self.photo = ImageTk.PhotoImage(framed)

            self.canvas.delete("all")
            self.canvas.create_image(0, 0, anchor="nw", image=self.photo)

            self.move_to_position()
            self.root.deiconify()
            print("[SHOT] WINDOW SHOWN")
        except Exception as e:
            print("[SHOT ERROR]", e)
        finally:
            self.busy = False


if __name__ == "__main__":
    App()