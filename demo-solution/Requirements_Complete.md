# MC3113 Line-Follower Demo Project - Requirements Specification
**Team:** Instructor Demo Team  
**Version:** 1.0  
**Date:** January 2026

---

## 1. Functional Requirements

### R-TRACK-01: Line Following (S1)
**ID:** R-TRACK-01  
**Type:** Functional  
**Priority:** High  
**Description:** The system shall track the centerline using the 5-element sensor array and maintain lateral error within acceptable bounds.  
**Acceptance Criteria:** In S1, |e_line| ≤ 0.15 m for at least 95% of the run duration.  
**Source:** Project Brief Section 4.1  
**Linked to:** T-S1-TRACK

---

### R-OBS-01: Obstacle Avoidance (S2)
**ID:** R-OBS-01  
**Type:** Functional  
**Priority:** High  
**Description:** The system shall detect and avoid obstacles without physical contact.  
**Acceptance Criteria:** In S2, obstacle_contacts = 0 (no safety_violation events flagged as collision).  
**Source:** Project Brief Section 4.2, ISO 13849 (Safety category)  
**Linked to:** T-S2-OBS

---

### R-FAULT-01: Fault Handling (S3)
**ID:** R-FAULT-01  
**Type:** Functional  
**Priority:** High  
**Description:** The system shall continue operation in a safe degraded mode when sensor fault occurs.  
**Acceptance Criteria:** In S3, system shall complete the scenario without uncontrolled deviation (line_loss_events = 0).  
**Source:** ISO 26262 Clause 5 (Safe state)  
**Linked to:** T-S3-FAULT

---

## 2. Non-Functional Requirements

### R-TIME-01: Completion Time (S1)
**ID:** R-TIME-01  
**Type:** Performance  
**Priority:** Medium  
**Description:** The system shall complete S1 scenario in reasonable time.  
**Acceptance Criteria:** t_final ≤ 75 seconds.  
**Source:** Project Brief Section 9.1  
**Linked to:** T-S1-TIME

---

### R-CAP-01: Speed Limit Under Fault (S3)
**ID:** R-CAP-01  
**Type:** Safety  
**Priority:** Critical  
**Description:** The system shall enforce speed cap during sensor fault to prevent unsafe operation.  
**Acceptance Criteria:** When fault_flag = 1, v(t) ≤ 0.45 m/s at all times (max_v_fault ≤ 0.45 m/s).  
**Source:** ISO 26262 Clause 6.4.3 (Controllability), Project Brief Section 9.1  
**Linked to:** T-S3-CAP

---

### R-IAE-01: Tracking Accuracy (S1)
**ID:** R-IAE-01  
**Type:** Performance  
**Priority:** Medium  
**Description:** The system shall minimize lateral tracking error during nominal operation.  
**Acceptance Criteria:** IAE ≤ 0.025 m·s in S1.  
**Source:** Project Brief Section 9.1  
**Linked to:** T-S1-IAE

---

### R-ENERGY-01: Energy Efficiency (S1)
**ID:** R-ENERGY-01  
**Type:** Sustainability  
**Priority:** Low  
**Description:** The system shall operate with reasonable energy efficiency during nominal operation.  
**Acceptance Criteria:** Energy_proxy ≤ 60 normalized units in S1.  
**Source:** ISO 14040/44 (Use-phase LCA), Project Brief Section 9.2  
**Linked to:** T-S1-ENERGY

---

## 3. Requirements Traceability Summary

| ReqID | Scenario | TestID | Verification Method |
|-------|----------|--------|---------------------|
| R-TRACK-01 | S1 | T-S1-TRACK | Simulation/Test |
| R-OBS-01 | S2 | T-S2-OBS | Simulation/Test |
| R-FAULT-01 | S3 | T-S3-FAULT | Simulation/Test |
| R-TIME-01 | S1 | T-S1-TIME | Analysis/Simulation |
| R-CAP-01 | S3 | T-S3-CAP | Test |
| R-IAE-01 | S1 | T-S1-IAE | Analysis/Simulation |
| R-ENERGY-01 | S1 | T-S1-ENERGY | Analysis/Simulation |

---

_End of Requirements Specification_