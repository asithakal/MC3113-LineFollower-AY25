# Line-Follower Digital Twin – Interface Control Document (ICD)

This document defines the **signals exchanged between the controller and the digital twin** (plant + environment).

## 1. Timing

- Controller update rate: **100 Hz** (Δt = 0.01 s)
- Logging rate: **100 Hz** (same as controller)

## 2. Controller inputs (from twin to controller)

| Signal         | Direction | Type / Units       | Rate  | Range              | Notes                                           |
|----------------|-----------|--------------------|-------|--------------------|------------------------------------------------|
| `sensor[5]`    | In        | normalized [0..1]  | 100Hz | [0, 1]             | 5 reflectance sensors across the line          |
| `e_line`       | In        | m                  | 100Hz | approx. ±0.5       | Lateral error from track centre                |
| `v`            | In        | m/s                | 100Hz | [0, v_max]         | Forward speed                                   |
| `omega`        | In        | rad/s              | 100Hz | [−ω_max, ω_max]    | Yaw rate                                        |
| `obstacle_flag`| In        | bool               | 100Hz | {0, 1}             | 1 when obstacle is active (S2)                  |
| `fault_flag`   | In        | bool               | 100Hz | {0, 1}             | 1 during sensor fault window (S3)              |

## 3. Controller outputs (from controller to twin)

| Signal  | Direction | Type / Units       | Rate  | Range    | Notes                                 |
|---------|-----------|--------------------|-------|----------|---------------------------------------|
| `u_L`   | Out       | normalized [-1..1] | 100Hz | [-1, 1]  | Left wheel command                    |
| `u_R`   | Out       | normalized [-1..1] | 100Hz | [-1, 1]  | Right wheel command                   |

The twin will clamp commands that exceed this range but such clamping should be **rare** in a good design.

## 4. Diagnostic and safety signals (logged by twin)

These signals are computed and logged by the twin. The controller does not write them but may read them for advanced strategies.

| Signal            | Direction | Type / Units | Rate  | Range  | Notes                                                      |
|-------------------|-----------|--------------|-------|--------|------------------------------------------------------------|
| `line_loss_flag`  | In        | bool         | 100Hz | {0, 1} | 1 when \|e_line\| > line-loss threshold                    |
| `sat_flag_L`      | In        | bool         | 100Hz | {0, 1} | 1 when u_L is clamped                                      |
| `sat_flag_R`      | In        | bool         | 100Hz | {0, 1} | 1 when u_R is clamped                                      |
| `safety_violation`| In        | bool         | 100Hz | {0, 1} | 1 when obstacle contact (S2) or other safety breach occurs |

Exact detection logic lives in the twin (not in your controller) and is used for scoring and verification.

## 5. Assumptions

- All signals are synchronous at 100 Hz.
- Latency between controller output and plant update is negligible for this course.
- `obstacle_flag` and `fault_flag` are perfectly reliable (no communication loss).

Controllers must:
- Respect signal ranges and units.
- Handle `fault_flag` and `obstacle_flag` explicitly, especially in S2 and S3.
- Avoid writing to any signals except `u_L` and `u_R`.
