<!-- ═══════════════════════════════════════════════════════════ -->
<!--                         A-123                               -->
<!-- ═══════════════════════════════════════════════════════════ -->

<div align="center">

# <img src="https://img.icons8.com/?size=100&id=K7eAkaqXsClq&format=png&color=000000" height=30/> <a href="https://github.com/voanechay52/">𝚟𝚘𝚊𝚗𝚎𝚌𝚑𝚊𝚢</a><a href="https://github.com/voanechay52/A-123">/𝙰-𝟷𝟸𝟹</a>

### DOORS: The Archives Mailroom helper

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-22c55e?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-ffdebd?style=for-the-badge)

**🇷🇺 [Русский](#-русский) · 🇬🇧 [English](#-english)**

</div>

---

## 📸 Что это / What is this

**A-123** — это скриншот-инструмент для игры **DOORS: The Archives** (Roblox).  
Наводишь прицел на монитор с кодом, жмёшь **Z** — и получаешь красиво оформленный скриншот в рамке прямо в углу экрана. Больше не нужно запоминать номера коробок в Почтовой комнате.

**A-123** is a screenshot tool for **DOORS: The Archives** (Roblox).  
Aim at the monitor with the code, press **Z** — and get a beautifully framed screenshot in the corner of your screen. No more memorizing box numbers in the Mailroom.

---

<div align="center">

## 🇷🇺 РУССКИЙ

</div>

### 📁 Структура папки

```
A-123/
├── management.bat        ← запускай это
├── README.txt            ← инструкция
├── fonts/
│   └── DOORS.ttf         ← шрифт для цифр на скринах
└── resources/
    ├── a-123.py          ← главный скрипт
    ├── config.py         ← настройки
    ├── _cfg.ps1          ← помощник для чтения/записи config
    └── (lang.txt, libs.checked, a-123.pid — создаются сами)
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

Нажми **1** и Enter. Язык запомнится — второй раз спрашивать не будет.

**Шаг 4.** Программа проверит всё автоматически:

| Что проверяется | Если ОК | Если НЕТ |
|:---|:---|:---|
| **Python** | ✅ `[OK] PYTHON НАЙДЕН` | предложит установить → жми **Y** |
| **Библиотеки** *(Pillow, keyboard)* | ✅ `[OK] ВСЕ БИБЛИОТЕКИ НА МЕСТЕ` | предложит установить → жми **Y** |

Проверка библиотек делается **раз в 24 часа**, не при каждом запуске.

**Шаг 5.** Появится приветствие → нажми **любую клавишу**.

**Шаг 6.** Откроется **главное меню**:

```
[1] ЗАПУСТИТЬ
[2] ОСТАНОВИТЬ
[3] ПЕРЕЗАПУСТИТЬ
[4] ПРОВЕРКА БИБЛИОТЕК
[5] НАСТРОЙКИ
[0] ВЫХОД
```

</details>

### 🎮 Как пользоваться

1. В меню нажми **`1`** — скрипт запустится в фоне.
2. Запусти **DOORS: The Archives** в Roblox.
3. Когда дойдёшь до **Почтовой комнаты**:
   - Наведи **прицел** ровно на монитор с кодом (например, `A-123`).
   - Нажми **`Z`** *(работает и в русской раскладке — клавиша физическая)*.
   - В левом нижнем углу появится картинка в рамке.
4. Иди к нужной коробке, сверяйся с номером.
5. **`ESC`** — спрятать окно.

### 🖼️ Стопка скринов

Можно держать **до 4 скринов** одновременно. Новый всегда появляется **снизу**, старые сдвигаются вверх. Когда стопка полна — самый старый вытесняется. В левом верхнем углу каждого скрина — полупрозрачная цифра (`1`, `2`, `3`, `4`), её рисует шрифт **DOORS**.

### ⌨️ Горячие клавиши

| Клавиша | Действие |
|:---:|:---|
| **`Z`** | Сделать скрин области вокруг прицела |
| **`ESC`** | Спрятать все скрины |

### ⚙️ Настройки (пункт `[5]` в меню)

<details>
<summary><b>Что можно настроить</b></summary>

| Пункт | Что делает | По умолчанию |
|:---:|:---|:---:|
| **`[1]`** Анимация | Плавный сдвиг скринов при добавлении нового | ВКЛ |
| **`[2]`** Обводка нового | Яркая рамка у самого свежего скрина | ВКЛ |
| **`[3]`** Макс. скринов | Сколько скринов держать (1–4) | 3 |
| **`[4]`** Хоткей | Одна клавиша для RU и EN | `Z` |
| **`[5]`** Открыть config.py | Ручная правка всех настроек в блокноте | — |
| **`[6]`** Сменить язык | Переключение RU / EN | RU |
| **`[7]`** Проверить библиотеки | Сбросить 24-часовой кэш проверки | — |

</details>

### 🔧 Если что-то не работает

<details>
<summary><b>Хоткей не срабатывает</b></summary>

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
- Выбери **`[4]`** — проверка библиотек.
- Если чего-то нет — установи.

</details>

<details>
<summary><b>Хочу изменить размер или позицию окна</b></summary>

Открой `resources/a-123.py` и найди вверху:

```python
SHOT_W, SHOT_H = 300, 100     # размер скрина
WINDOW_OFFSET_X = 40          # отступ слева
WINDOW_OFFSET_Y = 70          # отступ снизу
```

</details>

---

<div align="center">

## 🇬🇧 ENGLISH

</div>

### 📁 Folder structure

```
A-123/
├── management.bat        ← run this
├── README.txt            ← instructions
├── fonts/
│   └── DOORS.ttf         ← font for numbers on screenshots
└── resources/
    ├── a-123.py          ← main script
    ├── config.py         ← settings
    ├── _cfg.ps1          ← helper for reading/writing config
    └── (lang.txt, libs.checked, a-123.pid — auto-created)
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

Press **2** and Enter. The choice is remembered — no need to choose again.

**Step 4.** The program checks everything automatically:

| What is checked | If OK | If NOT |
|:---|:---|:---|
| **Python** | ✅ `[OK] PYTHON FOUND` | offers to install → press **Y** |
| **Libraries** *(Pillow, keyboard)* | ✅ `[OK] ALL LIBRARIES ARE PRESENT` | offers to install → press **Y** |

Library check runs **once every 24 hours**, not on every launch.

**Step 5.** A welcome screen appears → press **any key**.

**Step 6.** The **main menu** opens:

```
[1] START
[2] STOP
[3] RESTART
[4] CHECK LIBRARIES
[5] SETTINGS
[0] EXIT
```

</details>

### 🎮 How to use

1. In the menu, press **`1`** — the script starts in the background.
2. Launch **DOORS: The Archives** in Roblox.
3. When you reach the **Mailroom**:
   - Aim the **crosshair** exactly at the monitor with a code (e.g. `A-123`).
   - Press **`Z`** *(works in any layout — it's a physical key)*.
   - A framed image appears in the bottom-left corner.
4. Walk to the correct box and match the number.
5. **`ESC`** — hide all shots.

### 🖼️ Screenshot stack

You can keep up to **4 screenshots** at once. The new one always appears **at the bottom**, older ones shift up. When the stack is full, the oldest is pushed out. In the top-left corner of each shot there's a semi-transparent digit (`1`, `2`, `3`, `4`) rendered with the **DOORS** font.

### ⌨️ Hotkeys

| Key | Action |
|:---:|:---|
| **`Z`** | Take a screenshot around the crosshair |
| **`ESC`** | Hide all screenshots |

### ⚙️ Settings (`[5]` in the menu)

<details>
<summary><b>What can be configured</b></summary>

| Option | Description | Default |
|:---:|:---|:---:|
| **`[1]`** Animation | Smooth slide of shots when a new one is added | ON |
| **`[2]`** Glow on newest | Brighter frame on the newest shot | ON |
| **`[3]`** Max shots | How many shots to keep (1–4) | 3 |
| **`[4]`** Hotkey | One key for both RU and EN | `Z` |
| **`[5]`** Open config.py | Manual editing of all settings in Notepad | — |
| **`[6]`** Change language | Switch RU / EN | RU |
| **`[7]`** Recheck libraries | Reset 24h cache | — |

</details>

### 🔧 Troubleshooting

<details>
<summary><b>Hotkey doesn't work</b></summary>

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
- Choose **`[4]`** — check libraries.
- If anything is missing — install it.

</details>

<details>
<summary><b>I want to change the window size or position</b></summary>

Open `resources/a-123.py` and find at the top:

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

1. Открой `management.bat` → **`[2]`** (остановить) → **`[0]`** (выход).  
   *Open `management.bat` → **`[2]`** (stop) → **`[0]`** (exit).*
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
