# Line-Follower Digital Twin – Logging Schema

All scenarios (S1, S2, S3) produce log files in **CSV format** with identical structure.

## Sampling

- Time step: Δt = 0.01 s
- Sampling rate: 100 Hz
- All signals logged at every time step.

## Columns (in order)

1. `run_id`          — string, e.g. `MC3113_AY25_Team03_S1_001`
2. `scenario_id`     — string: `"S1"`, `"S2"`, or `"S3"`
3. `t`               — time [s]
4. `x`               — x-position [m]
5. `y`               — y-position [m]
6. `theta`           — heading [rad]
7. `v`               — forward speed [m/s]
8. `omega`           — yaw rate [rad/s]
9. `e_line`          — lateral error [m]
10. `line_loss_flag` — 0 or 1
11. `sensor_1`       — normalized sensor reading [0..1]
12. `sensor_2`
13. `sensor_3`
14. `sensor_4`
15. `sensor_5`
16. `obstacle_flag`  — 0 or 1
17. `fault_flag`     — 0 or 1
18. `u_L`            — command [-1..1]
19. `u_R`            — command [-1..1]
20. `sat_flag_L`     — 0 or 1
21. `sat_flag_R`     — 0 or 1
22. `safety_violation` — 0 or 1
23. `notes`          — free text (optional; may be empty)

## File naming convention

logging/MC3113_AY25_Team##_S1_runNNN.csv
logging/MC3113_AY25_Team##_S2_runNNN.csv
logging/MC3113_AY25_Team##_S3_runNNN.csv

text

Where:
- `##` is the zero-padded team number.
- `NNN` is a zero-padded run index (001, 002, ...).

All tools (metrics, plotting) assume **exactly this header and column order**.