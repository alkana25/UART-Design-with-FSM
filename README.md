# UART-Design-with-FSM

This repository contains a robust hardware implementation of a **Universal Asynchronous Receiver-Transmitter (UART)** protocol using **Verilog HDL**. The design features a configurable Baud Rate Generator, Finite State Machine (FSM) controlled TX/RX modules, and an oversampling mechanism for noise-resilient data reception.

The project is designed and verified for **FPGA** implementation, targeting a 100 MHz system clock.

##  Features
* **Configurable Baud Rate:** Supports standard baud rates (tested at **9600** and **115200** baud) via a selectable input.
* **Robust Receiver:** Implements **8x Oversampling** technique to detect the center of data bits, ensuring reliable data capture and noise immunity.
* **FSM Control:** Both Transmitter and Receiver modules are governed by optimized Finite State Machines (IDLE, START, DATA, STOP).
* **Loopback Verification:** Includes a Top Module with a loopback mechanism to verify full-duplex communication integrity.
* **Timing Verified:** Post-implementation timing simulation confirms stability with a positive Worst Negative Slack (WNS).

## Repository Structure

| File | Description |
| :--- | :--- |
| `src/uart_tx.v` | Transmitter module. Serializes 8-bit parallel data based on FSM logic. |
| `src/uart_rx.v` | Receiver module. Deserializes incoming bits using 8x oversampling. |
| `src/baud_gen.v` | Generates `tick_1x` (transmission) and `tick_8x` (sampling) pulses from 100 MHz clock. |
| `src/uart_top.v` | Top-level module integrating TX, RX, and Baud Gen for loopback testing. |
| `sim/tb_uart_top.v` | Testbench for verifying the complete system with various data patterns (0x55, 0xAA, etc.). |
| `docs/Project2_report.pdf` | Comprehensive technical report covering state diagrams, timing analysis, and utilization. |

## System Architecture
The design consists of three core modules:

1.  **Baud Rate Generator:** Divides the 100 MHz system clock to generate precise timing ticks.
    * *Tick 1x:* Used by TX to shift data bits.
    * *Tick 8x:* Used by RX to sample the input line 8 times per bit period.
2.  **UART Transmitter (TX):**
    * State Machine: `IDLE` $\rightarrow$ `START` (Logic 0) $\rightarrow$ `DATA` (LSB to MSB) $\rightarrow$ `STOP` (Logic 1).
3.  **UART Receiver (RX):**
    * Synchronizes the asynchronous input signal.
    * Uses a counter to sample the data bit at the **4th tick** (center of the bit) of the 8x cycle for maximum accuracy.

## Simulation & Usage
1.  **Simulation:**
    The project includes a testbench (`tb_uart_top.v`) that performs a loopback test. It sends specific bytes (e.g., `0x55`, `0xAA`) and verifies if the received data matches the transmitted data.
    ```bash
    # Example Output in Console
    [30] SENDING (Tx): 55
    -> [SUCCESSFULL] Rx Read: 55
    ```

2.  **Synthesis:**
    Add the source files to your FPGA project (Vivado/Quartus). The design is constrained for a **100 MHz** clock.

## Results & Performance
The design was synthesized and implemented (Post-Implementation) with the following metrics:

### Resource Utilization (Top Module)
| Resource | Used | Total | Utilization % |
| :--- | :--- | :--- | :--- |
| **LUT** | 54 | 32,600 | 0.17% |
| **FF (Flip-Flop)** | 50 | 65,200 | 0.08% |
| **IO** | 27 | 210 | 12.86% |

### Timing Analysis
* **Clock Frequency:** 100 MHz (10 ns period)
* **Worst Negative Slack (WNS):** `5.651 ns` (Positive value indicates zero timing violations)
* **Total Negative Slack (TNS):** `0.000 ns`

---
*This project was developed as part of the Digital System Design Applications course.*
