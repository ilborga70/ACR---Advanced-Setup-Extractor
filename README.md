# Changelog - ACR Advanced Setup Extractor

Comprehensive log of recent updates to the extraction logic and export layout.

## [1.0.0] - 2026-01-24

### 🛠 Technical Fixes (Core Engine)
- **Single Selection Fix**: Resolved a critical bug where selecting only one setup from the list caused the application to crash. The system now correctly handles data as an array regardless of the number of items.
- **Method Call Error Resolved**: Fixed the `MethodNotFound` error related to `WriteTable`, which previously caused the GUI button to fail.
- **Deep Scan Optimization**: Enhanced the reading function to accurately capture numerical values even when they appear on the line following the parameter label in the `.sav` file.

### 📊 HTML Export (Professional Layout)
- **New 3-Column Structure**: Updated the export layout to reflect a professional comparative format: **Parameter | Front (FL/FR) | Rear (RL/RR)**.
- **Complete Parameter Mapping**: Automatic extraction and organization of:
  - **Chassis & Suspensions**: Tire pressure, Camber, Toe, Springs, ARB, and damper transitions.
  - **Drivetrain & Electronics**: Gear sets, differentials (Center/Front/Rear), ABS, and TCS.
  - **Braking System**: Discs, calipers, pads, brake bias, and handbrake force.
- **Technical Units**: Automatically appends professional units of measurement (PSI, N/m, °, m) to raw data for improved readability.

### 🎨 Interface & Styling
- **Google Sites Ready**: The generated HTML file is now fully compatible with the aesthetic requirements of Google Sites.
- **Graphic Restyling**: 
  - Section headers in **Red (#d32f2f)** and **Blue (#1976d2)**.
  - Implemented card-style containers with shadows and rounded corners.
  - Red bold highlighting for electronic systems (ABS/TCS).
- **Video Integration**: Added a 16:9 black `video-placeholder` to allow users to easily paste their YouTube embed codes.

---

**Unlock your Assetto Corsa Rally setup data.** A standalone utility designed to extract, decode, and organize car setup parameters from `CarSetupsDataSaveSlot.sav` files, even when standard parsers fail.

![Version](https://img.shields.io/badge/version-1.0-blue) ![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)

## <img width="2560" height="1080" alt="ACR - Advanced Setup Extractor v1 0 0 0" src="https://github.com/user-attachments/assets/36f1cfa5-369f-4697-af01-bc8995932006" />

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
