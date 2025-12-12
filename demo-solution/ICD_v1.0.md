# Interface Control Document (ICD) - Line-Follower Demo
**Version:** 1.0  
**Owner:** Instructor Demo Team - Controller Lead  
**Date:** January 2026  
**Status:** Verified against all scenarios

---

## 1. Controller Inputs (from Plant/Twin)

| Signal | Direction | Type/Units | Rate (Hz) | Range | Error/Flags | Notes |
|--------|-----------|------------|-----------|-------|-------------|-------|
| sensor[5] | In | float[5], normalized [0..1] | 100 | 0 to 1 | dropout_flag (S3) | Element spacing ≈ [−40 −20 0 20 40] mm |
| e_line | In | float, meters | 100 | −0.5 to 0.5 (nominal) | line_loss_flag if |e_line| > 0.5 | Lateral error; positive = right of line |
| v | In | float, m/s | 100 | 0 to 0.8 (plant limit) | — | Forward velocity |
| omega | In | float, rad/s | 100 | −2 to 2 (nominal) | — | Yaw rate |
| obstacle_flag | In | bool | 100 | 0 or 1 | — | 1 when obstacle present (S2) |
| fault_flag | In | bool | 100 | 0 or 1 | — | 1 during sensor dropout window (S3) |

---

## 2. Controller Outputs (to Plant/Twin)

| Signal | Direction | Type/Units | Rate (Hz) | Range | Error/Flags | Notes |
|--------|-----------|------------|-----------|-------|-------------|-------|
| u_L | Out | float, normalized | 100 | −1 to 1 | sat_flag_L if saturated | Left wheel command |
| u_R | Out | float, normalized | 100 | −1 to 1 | sat_flag_R if saturated | Right wheel command |

---

## 3. Telemetry / Diagnostic Signals (Plant → Log)

| Signal | Direction | Type/Units | Rate (Hz) | Range | Error/Flags | Notes |
|--------|-----------|------------|-----------|-------|-------------|-------|
| x | Telemetry | float, meters | 100 | — | — | Global X position |
| y | Telemetry | float, meters | 100 | — | — | Global Y position |
| theta | Telemetry | float, radians | 100 | −π to π | — | Heading |
| line_loss_flag | Telemetry | bool | 100 | 0 or 1 | — | 1 if |e_line| exceeds threshold |
| sat_flag_L | Telemetry | bool | 100 | 0 or 1 | — | 1 if u_L saturated |
| sat_flag_R | Telemetry | bool | 100 | 0 or 1 | — | 1 if u_R saturated |
| safety_violation | Telemetry | bool | 100 | 0 or 1 | — | 1 if safety condition breached |

---

## 4. ICD Change Log

| Version | Date | Changes | Approved By |
|---------|------|---------|-------------|
| 0.1 | Week 3 | Initial draft (sensor, e_line, u_L, u_R only) | Team |
| 1.0 | Week 6 | Added all telemetry, flags; verified against S1-S3 | Instructor |

---

_End of ICD v1.0_
