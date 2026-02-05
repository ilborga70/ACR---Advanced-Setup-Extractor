### ✨ New Features [1.5.0] - 2026-02-05 
* The interface has been fully modernized with a cohesive dark theme, improved readability, and a more polished visual identity across all components.
* Key Enhancements
* Full Dark Theme — Unified dark background with professional gradient accents for depth and visual balance.
* Modern Color Palette — Refined combination of deep grays and professional blue highlights for a clean, contemporary look.
* Flat Design Buttons — Borderless buttons with smooth hover effects to improve clarity and interaction feedback.
* Dark-Themed Textboxes — High‑contrast text fields with dark backgrounds and light text for optimal readability.
* Improved Typography — Adoption of Segoe UI for a modern, consistent, and highly legible interface.
* Status Bar Added — New bottom status bar providing real‑time operational feedback.
* Refined Borders and Shadows — Subtle visual separation and depth without clutter.
* Consistent Dialog Styling — All dialog windows now follow the same dark theme for a unified user experience.
* Enhanced HTML Output — Updated HTML templates featuring dark mode styling and gradient elements.
* Improved Visual Feedback — Clearer indicators during operations for better user awareness.

<img width="2016" height="1078" alt="ACR - Advanced Setup Extractor v1 5 0" src="https://github.com/user-attachments/assets/1a3508fb-8dc4-4c41-9db0-6eea1f415aa9" />

### ✨ New Features [1.2.0] - 2026-02-04
* **Video Embed Dialog:** Introduced a new popup window (`Show-VideoInputDialog`) that automatically appears for each selected setup during export.
* Allows pasting specific YouTube `<iframe>` embed code for each Car/Track combination.
* If left empty, the system handles it gracefully.
* **Video Integration in Report:** The HTML report now dynamically renders the video section:
* **With Code:** Displays the video in a responsive 16:9 player.
* **Without Code:** Displays a stylish placeholder labeled `[ NO VIDEO AVAILABLE ]`.

### 🌍 Localization
* **English Report:** The entire HTML output has been translated from Italian to Professional English (Sim Racing Terminology).
* *Examples:* "Meccanica" → "Chassis & Suspensions", "Cambio" → "Gearbox", "Molle" → "Spring Stiffness".
* **International Formatting:** Labels and headers have been adapted for an international audience.

### 🎨 UI/UX Improvements
* **Responsive Video CSS:** Added CSS classes (`.video-container`, `.video-placeholder`) to ensure videos maintain the correct aspect ratio and do not break the layout on smaller screens.
* **Code Cleanup:** Resolved previous syntax conflicts; the script is now a single, clean block free of bracket errors.

## [1.0.0] - 2026-01-24

### 🛠 Technical Fixes (Core Engine)
- **Single Selection Fix**: Resolved a critical bug where selecting only one setup from the list caused the application to crash. [cite_start]The system now correctly handles data as an array regardless of the number of items[cite: 1].
- [cite_start]**Method Call Error Resolved**: Fixed the `MethodNotFound` error related to `WriteTable`, which previously caused the GUI button to fail[cite: 1].
- **Deep Scan Optimization**: Enhanced the reading function to accurately capture numerical values even when they appear on the line following the parameter label in the `.sav` file.

### 📊 HTML Export (Professional Layout)
- **New 3-Column Structure**: Updated the export layout to reflect a professional comparative format: **Parameter | Front (FL/FR) | [cite_start]Rear (RL/RR)**.
- **Complete Parameter Mapping**: Automatic extraction and organization of:
  - [cite_start]**Chassis & Suspensions**: Tire pressure, Camber, Toe, Springs, ARB, and damper transitions.
  - [cite_start]**Drivetrain & Electronics**: Gear sets, differentials (Center/Front/Rear), ABS, and TCS.
  - [cite_start]**Braking System**: Discs, calipers, pads, brake bias, and handbrake force.
- [cite_start]**Technical Units**: Automatically appends professional units of measurement (PSI, N/m, °, m) to raw data for improved readability.

### 🎨 Interface & Styling
- [cite_start]**Google Sites Ready**: The generated HTML file is now fully compatible with the aesthetic requirements of Google Sites[cite: 2, 3].
- **Graphic Restyling**: 
  - [cite_start]Section headers in **Red (#d32f2f)** and **Blue (#1976d2)**[cite: 3, 4].
  - [cite_start]Implemented card-style containers with shadows and rounded corners[cite: 3, 4].
  - [cite_start]Red bold highlighting for electronic systems (ABS/TCS)[cite: 3, 4].
- [cite_start]**Video Integration**: Added a 16:9 black `video-placeholder` to allow users to easily paste their YouTube embed codes[cite: 3, 4].

---

**Unlock your Assetto Corsa Rally setup data.** A standalone utility designed to extract, decode, and organize car setup parameters from `CarSetupsDataSaveSlot.sav` files, even when standard parsers fail.

![Version](https://img.shields.io/badge/version-1.0-blue) ![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)

## 🏎️ What is it?

The **ACR - Advanced Setup Extractor** is a powerful tool for the *Assetto Corsa Rally* community. The game stores car setups in a complex, serialized format (GVAS) that often appears encrypted or compressed, making it impossible to read with standard text editors or generic save parsers.

This tool uses a **Deep String Harvest (Brute Force)** method combined with **Smart Pattern Recognition** to bypass structure errors and retrieve 100% of the readable text data.

### Key Features

* **🛡️ Universal Compatibility:** Works on any `CarSetupsDataSaveSlot.sav` file, regardless of game version or encryption status.
* **📂 Multi-Setup Splitter:** Automatically detects if a save file contains multiple setups (e.g., different cars or tracks) and splits them into distinct, organized sections.
* **🧠 Smart Context:** Identifies the **Car Model**, **Username**, and **Track** associated with each setup using version-tag heuristics.
* **💾 Portable Executable:** No scripts or coding knowledge required. Just run the `.exe`.
* **📄 Clean Export:** Saves the extracted data into a readable `.txt` file for easy sharing or analysis.

---

## 📥 Installation

1.  Go to the **[Releases](../../releases)** page of this repository.
2.  Download the latest `ACR - Advanced Setup Extractor.zip`.
3.  Extract the zip file to a folder of your choice.
4.  Run `ACR - Advanced Setup Extractor.exe`.

> **Note:** This is a standalone application. You do not need PowerShell or any external libraries installed.

---

## 🚀 How to Use

1.  **Launch the Application:** Double-click `ACR - Advanced Setup Extractor.exe`.

2.  **Select your Save File:** Click the **"Select .sav File"** button.  
    *Typical location for ACR save files:* `C:\Users\[YourName]\AppData\Local\acr\Saved\SaveGames\CarSetupsDataSaveSlot.sav`

3.  **Run the Extraction:** Click the **"EXTRACT & SPLIT SETUPS"** button.  
    The tool will scan the file byte-by-byte. It will identify version markers (e.g., `0.2.2.xxxxx`) to separate different setups found within the same file.

4.  **Save the Report:** A "Save As" dialog will appear. Choose where to save your `.txt` report.

5.  **View Your Data:** Open the generated text file. You will see a section for each setup found, containing the Car, Driver, Track, and all tuning values (Suspension, Gears, Brakes, etc.).

---

## 🔍 How it Works (Technical)

Unlike standard GVAS parsers that crash when encountering non-standard headers or compressed blocks, this tool performs a **heuristic scan**.

1.  **Deep Scan:** It harvests all valid ASCII and Unicode strings from the binary file.
2.  **Pattern Matching:** It looks for specific game version signatures (e.g., `0.X.X.XXXX`).
3.  **Logic Split:** Based on the position of these signatures, it effectively maps out the data structure:
    * `[Offset -2]`: Car Model
    * `[Offset -1]`: Setup Name / Username
    * `[Offset +0]`: Version Tag
    * `[Offset +2]`: Track Name
4.  **Reconstruction:** It groups the tuning properties found between these anchors into individual setup blocks.

---

## ⚠️ Disclaimer

This software is an unofficial tool and is not affiliated with, endorsed by, or connected to the developers of *Assetto Corsa Rally*. Use it to back up and view your own setup data.

---

**Created by [ilborga70]**
