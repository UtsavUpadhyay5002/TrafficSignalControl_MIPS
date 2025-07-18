# 🚦 Traffic Signal Controller – MIPS Assembly

Welcome to our Traffic Signal Controller project!  
Created by **Utsav Upadhyay** and **Kencho Namgyle** as part of the **CS2253 Machine-Level Programming** course at **UNB**.

This project is a simple, interactive traffic signal simulation built entirely in **MIPS Assembly**, focusing on real-time system behavior using **memory-mapped I/O (MMIO)** and core low-level programming concepts.

---

## 📌 Features
- ✅ **Real-time Traffic Light Simulation**  
- 🧍 **Pedestrian Crossing Requests** handled with keyboard input (`p`)
- ⚙️ **Interactive Menu System** to:
    - Start simulation
    - Change green light duration
    - Change yellow light duration
    - Set speed limit (auto-adjusts yellow time)
    - Exit simulation
- 🚨 **Responsive Controls**:
    - `'p'` → Request pedestrian crossing
    - `'m'` → Return to menu
    - `'q'` → Quit simulation

---

## 📝 How It Works
- **Main Menu**: Choose actions like starting the simulation or adjusting timings.
- **Simulation Cycle**: Lights alternate between North-South and East-West with countdown timers.
- **Pedestrian Mode**: When `'p'` is pressed, the simulation adds an all-red pedestrian phase after the current yellow light.
- **Dynamic Yellow Time**: Yellow duration increases with speed limit (3 seconds minimum, increases per +10 mph).

---

## 🖥️ Program Flow
1. Welcome & Controls Display
2. Menu Interface for user options
3. Traffic Light Simulation Loop
4. Real-time input polling every 100ms
5. Pedestrian phase triggered on request
6. Option to return to Menu or Exit anytime

---

## 📂 Files Included
- `mips5.asm` – Full MIPS assembly code.
- `Traffic_Signal_Simulator_Team_P.pdf` – Project summary slides.
- `CSS2253_Report.pdf` – Full project report with design, implementation, and challenges.

---

## 🎓 What We Learned
This project helped us explore:
- Real-time system design using Assembly
- Managing responsiveness without interrupts
- Clean code organization with **subroutines** in MIPS
- Hands-on experience with **MMIO**, loops, and system calls

---

## ❤️ Acknowledgements
Special thanks to the **CS2253 course instructors** for making low-level programming enjoyable and educational!

---
