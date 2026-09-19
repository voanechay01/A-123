<!-- ═══════════════════════════════════════════════════════════ -->
<!--                         A-123                               -->
<!-- ═══════════════════════════════════════════════════════════ -->

<div align="center">

# 🎯 A-123

### DOORS: The Archives Mailroom helper

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-22c55e?style=for-the-badge)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Active-ffdebd?style=for-the-badge)](#)

**[Русский](#-русский) · [English](#-english)**

</div>

---

## 📸 Что это / What is this

**A-123** — это скриншот-инструмент для игры **DOORS: The Archives** (Roblox).  
Наводишь прицел на монитор с кодом, жмёшь **Z** — и получаешь красиво оформленный скриншот в рамке прямо в углу экрана. Больше не нужно запоминать номера коробок в Почтовой комнате.

**A-123** is a screenshot tool for **DOORS: The Archives** (Roblox).  
Aim at the monitor with the code, press **Z** — and get a beautifully framed screenshot in the corner of your screen. No more memorizing box numbers in the Mailroom.

---

<div align="center">

## РУССКИЙ

</div>

### 📁 Структура папки

```
A-123/
├── a-123.py          ← главный скрипт
├── management.bat    ← панель управления
├── README.md         ← этот файл
└── (a-123.pid)       ← создаётся автоматически
```

### 🚀 Первый запуск

<details open>
<summary><b>Развернуть пошаговую инструкцию</b></summary>

**Шаг 1.** Открой папку `A-123`.

**Шаг 2.** Дважды кликни по **`management.bat`**.

**Шаг 3.** Появится окно с логотипом и выбором языка:

```
[1] РУССКИЙ
[2] ENGLISH
```

Нажми **1** и Enter.

**Шаг 4.** Программа проверит всё автоматически:

| Что проверяется | Если ОК | Если НЕТ |
|:---|:---|:---|
| **Python** | ✅ `[OK] PYTHON НАЙДЕН` | предложит установить → жми **Y** |
| **Библиотеки** *(Pillow, keyboard)* | ✅ `[OK] ВСЕ БИБЛИОТЕКИ НА МЕСТЕ` | предложит установить → жми **Y** |

**Шаг 5.** Появится приветствие → нажми **любую клавишу**.

**Шаг 6.** Откроется **главное меню**:

```
[A] ЗАПУСТИТЬ
[B] ОСТАНОВИТЬ
[C] ПЕРЕЗАПУСТИТЬ
[D] ПРОВЕРКА БИБЛИОТЕК
[E] ВЫХОД
```

</details>

### 🎮 Как пользоваться

1. В меню нажми **`A`** — скрипт запустится в фоне.
2. Запусти **DOORS: The Archives** в Roblox.
3. Когда дойдёшь до **Почтовой комнаты**:
   - Наведи **прицел** ровно на монитор с кодом (например, `A-123`).
   - Нажми **`Z`** *(или `Я` в русской раскладке)*.
   - В левом нижнем углу появится картинка в рамке.
4. Иди к нужной коробке, сверяйся с номером.
5. **`ESC`** — спрятать окно.

### ⌨️ Горячие клавиши

| Клавиша | Действие |
|:---:|:---|
| **`Z`** / **`Я`** | Сделать скрин области вокруг прицела |
| **`ESC`** | Спрятать окно с картинкой |

### 🔧 Если что-то не работает

<details>
<summary><b>Хоткеи Z / Я не срабатывают</b></summary>

- Запусти `management.bat` **от имени администратора** (правая кнопка → *Запуск от имени администратора*).
- Добавь папку в **исключения антивируса** (Kaspersky, Avast блокируют библиотеку `keyboard`).

</details>

<details>
<summary><b>management.bat вылетает после выбора языка</b></summary>

- Сохрани файл в кодировке **UTF-8 с BOM** (в Notepad++: *Кодировки → UTF-8 с BOM*).
- Или используй **ANSI (CP1251)**.

</details>

<details>
<summary><b>Скриншот не появляется</b></summary>

- Открой `management.bat` заново.
- Выбери **`D`** — проверка библиотек.
- Если чего-то нет — установи.

</details>

<details>
<summary><b>Хочу изменить размер или позицию окна</b></summary>

Открой `a-123.py` и найди вверху:

```python
SHOT_W, SHOT_H = 300, 100     # размер скрина
WINDOW_OFFSET_X = 40          # отступ слева
WINDOW_OFFSET_Y = 70          # отступ снизу
```

</details>

---

<div align="center">

## ENGLISH

</div>

### 📁 Folder structure

```
A-123/
├── a-123.py          ← main script
├── management.bat    ← control panel
├── README.md         ← this file
└── (a-123.pid)       ← created automatically
```

### 🚀 First launch

<details open>
<summary><b>Expand step-by-step guide</b></summary>

**Step 1.** Open the `A-123` folder.

**Step 2.** Double-click **`management.bat`**.

**Step 3.** A window appears with a logo and language selection:

```
[1] РУССКИЙ
[2] ENGLISH
```

Press **2** and Enter.

**Step 4.** The program checks everything automatically:

| What is checked | If OK | If NOT |
|:---|:---|:---|
| **Python** | ✅ `[OK] PYTHON FOUND` | offers to install → press **Y** |
| **Libraries** *(Pillow, keyboard)* | ✅ `[OK] ALL LIBRARIES ARE PRESENT` | offers to install → press **Y** |

**Step 5.** A welcome screen appears → press **any key**.

**Step 6.** The **main menu** opens:

```
[A] START
[B] STOP
[C] RESTART
[D] CHECK LIBRARIES
[E] EXIT
```

</details>

### 🎮 How to use

1. In the menu, press **`A`** — the script starts in the background.
2. Launch **DOORS: The Archives** in Roblox.
3. When you reach the **Mailroom**:
   - Aim the **crosshair** exactly at the monitor with a code (e.g. `A-123`).
   - Press **`Z`** *(or `Я` in Russian layout)*.
   - A framed image appears in the bottom-left corner.
4. Walk to the correct box and match the number.
5. **`ESC`** — hide the window.

### ⌨️ Hotkeys

| Key | Action |
|:---:|:---|
| **`Z`** / **`Я`** | Take a screenshot around the crosshair |
| **`ESC`** | Hide the image window |

### 🔧 Troubleshooting

<details>
<summary><b>Z / Я hotkeys don't work</b></summary>

- Run `management.bat` **as administrator** (right-click → *Run as administrator*).
- Add the folder to your **antivirus exclusions** (Kaspersky, Avast block the `keyboard` library).

</details>

<details>
<summary><b>management.bat crashes after language selection</b></summary>

- Save the file with **UTF-8 with BOM** encoding (Notepad++: *Encoding → UTF-8 with BOM*).
- Or use **ANSI (CP1251)**.

</details>

<details>
<summary><b>No screenshot appears</b></summary>

- Open `management.bat` again.
- Choose **`D`** — check libraries.
- If anything is missing — install it.

</details>

<details>
<summary><b>I want to change the window size or position</b></summary>

Open `a-123.py` and find at the top:

```python
SHOT_W, SHOT_H = 300, 100     # screenshot size
WINDOW_OFFSET_X = 40          # offset from left
WINDOW_OFFSET_Y = 70          # offset from bottom
```

</details>

---

## 🛠️ Tech stack

<div align="center">

| Component | Purpose |
|:---:|:---|
| ![Python](https://img.shields.io/badge/-Python-3776AB?style=flat-square&logo=python&logoColor=white) | Core logic |
| ![Tkinter](https://img.shields.io/badge/-Tkinter-FF6F00?style=flat-square) | Overlay window |
| ![Pillow](https://img.shields.io/badge/-Pillow-8B5CF6?style=flat-square) | Image processing & rounded frame |
| ![keyboard](https://img.shields.io/badge/-keyboard-22C55E?style=flat-square) | Global hotkeys |

</div>

---

## ❌ Удаление / Uninstall

1. Открой `management.bat` → **`B`** (остановить) → **`E`** (выход).  
   *Open `management.bat` → **`B`** (stop) → **`E`** (exit).*
2. Удали всю папку `A-123`.  
   *Delete the entire `A-123` folder.*

Ничего в системе не остаётся — всё хранится внутри папки.  
*Nothing remains in the system — everything is stored inside the folder.*

---

<div align="center">

## 📜 License

**MIT License** — свободно используй, изменяй и распространяй.  
*Free to use, modify and distribute.*

---

**Made with ❤️ for the DOORS community**

⭐ Если проект помог — поставь звезду репозиторию!  
⭐ If this helped — drop a star on the repo!

</div>
