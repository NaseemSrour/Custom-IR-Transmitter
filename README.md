In a nutshell:
My own custom offline Infrared (IR) Blaster app for phones with an IR transmitter sensor. To be used as an on-the-field remote control (offline, no need for internet connection).

'IR Sketch' file is the Arduino sketch that is used to capture and save the IR codes from their original remote controls. Saving them in the attached Excel file.



# 📡 Custom IR Transmitter

This is a Flutter-based mobile app I built to control home devices (like outdoor projectors and sensors) using infrared, without needing the original remote or an internet connection.

The app sends raw IR signals directly from the phone’s built-in IR blaster. I built it mainly to control no-brand projectors in a wilderness garden in the woods that constantly remembering to bring their remotes with you is a hassle. Most universal remote apps either require internet, don’t support the device, or are cluttered with ads and limitations — so I decided to make a custom one that just works.

---

## 🧠 How It Works

The system is split into two parts:

### 1. 📸 Capturing IR Codes

Since each remote uses its own IR protocol, I needed a way to capture the raw signals. I set up a simple Arduino-based IR receiver using the **IRremote** library. I used it to listen to the projector’s remote and record the hex code patterns for each button.

The captured codes are saved in a spreadsheet (`Projectors IR Codes.xlsx`) so I can easily update or add to them later. The Arduino sketch used for this is also included (`IR Sketch.docx`).

### 2. 📱 Sending IR from the App

The Flutter app reads the stored IR codes and sends them via the phone’s IR transmitter. I wrote a small wrapper to interface with Android’s IR hardware using platform channels (since Flutter doesn’t support IR natively). Everything is stored locally so it works completely offline.

---

## ✨ Features

- Control devices via phone's built-in IR transmitter
- No internet, ads, or bloat — completely offline
- Easy to update IR codes (just paste them into the Dart code or load from a local file)
- Simple, minimal UI tailored for speed and usability

---

## 🛠️ Tech Stack

- **Flutter (Dart)** for cross-platform UI
- **Arduino** for signal capture (with IR receiver module)
- **Platform channels** for native Android IR transmission
- **Manual decoding and mapping** of IR codes

---

## 💡 Why I Built This

The goal wasn’t to make a flashy universal remote — it was about solving a practical problem with a lightweight, reliable tool that does one thing well. Along the way, it turned into a nice mix of embedded hardware, low-level signal handling, and cross-platform mobile dev.
After showing it to a few friends, they loved the idea and asked for copies to use in their gardens and around the house — especially for turning on outdoor projectors, garden lights, and other remote-controlled devices without needing to dig around for remotes.

---

## 📂 Folder Overview

Custom-IR-Blaster/

├── lib/ # Flutter app code

├── android/ # Android-specific native setup

├── test/ # Basic test setup

├── IR Sketch.docx # Arduino sketch for IR capture

├── Projectors IR Codes.xlsx # Captured IR codes

└── pubspec.yaml # Dependencies and assets



---

## 📈 To Do / Future Ideas

- [ ] Support for saving/loading IR codes via local JSON file
- [ ] UI for adding/remapping new buttons dynamically
- [ ] Optional backup of codes (cloud or device sync)
- [ ] Web support (for reference or testing)

---

If you’re trying to build something similar or need help decoding IR signals, feel free to reach out or open an issue. I’ve learned a lot digging into IR protocols and hardware quirks, and I'm happy to help.

