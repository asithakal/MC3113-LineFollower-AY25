# MC3113 Line‑Follower Project Brief (Digital Twin Competition)

Version: AY25.2 - Realistic Requirements Update  
Audience: Students and Instructors  
Owner: MC3113 Teaching Team  
Status: Released (Bronze tier validated, realistic disturbances)

---

## 1. Purpose and Learning Goals

This project gives every team a common, well‑specified mechatronic system to practice the end‑to‑end design process:

> Item Definition → Requirements → Architecture / ICD → Controller Design → Verification & Validation → Design Reviews

You will use a **shared digital twin** of a line‑follower robot as the backbone for:

- Applying **MBSE** and the **V‑model (VDI 2206)**
- Writing **measurable functional and non‑functional requirements**
- Building **traceability** from requirements to tests and evidence (RTM)
- Defining and using **interface control documents (ICDs)**
- Running **scenario‑based verification** using a common metrics set
- Incorporating **standards** (VDI 2206, ISO 26262 / IEC 61508, ISO 13849, ISO 14040/44) into design and testing

---

## 2. System Overview (What You Are Building)

- **Plant**: Differential‑drive line‑follower robot simulated in a provided digital twin
- **Sensors**: 5‑element reflectance array across the track plus a derived lateral error signal \(e_{\text{line}}\)
- **Controller**: Your code that reads sensor and state signals and outputs left/right wheel commands \((u_L, u_R)\) at 100 Hz
- **HMI / Telemetry**: Start/stop, scenario selection, standard 100 Hz CSV logging
- **Safety**: Scenario‑specific safety behaviour (e.g., speed caps, line‑loss limits) enforced by your controller and checked by the twin

Your team **does not** change the plant physics or scenario definitions.  
Your team **does** design:

- The controller logic (and any additional safety logic)
- Supporting HMI elements and scripts
- Requirements and V&V artefacts (RTM, test procedures, evidence)

---

## 3. Digital Twin Asset Pack

The teaching team provides a reference "twin asset pack" with this structure:

```
linefollower_twin/
  README.md
  config/
    plant_params.yaml       # geometry, dynamics, sensor rates, limits
    scenarios.yaml          # S1 / S2 / S3 definitions
  models/
    plant_model.slx         # Simulink / Simscape plant model (or equivalent)
    controller_stub.slx     # Controller I/O ports matching the ICD
  interfaces/
    ICD_linefollower.md     # All signal names, units, rates, ranges
  logging/
    log_schema.md           # CSV column order and definitions
    example_S1_log.csv      # Example log with correct schema
  metrics/
    compute_metrics.m       # (or .py) script to compute metrics
  scripts/
    run_scenario.m          # Runs a scenario and writes CSV logs
    run_all_scenarios.m     # Convenience batch runner (optional)
```

**Instructor notes**

- `plant_params.yaml` and `scenarios.yaml` are **frozen** by end of Week 3
- Students may read these but should not change them unless explicitly asked (e.g., for sensitivity studies)
- All teams must adhere to the same ICD, logging schema, and metrics script

---

## 4. Verification Scenarios (S1, S2, S3)

Three shared scenarios define the verification and competition spine.

### 4.1 Scenario S1 — Nominal

- **Description**: Baseline line‑following with no obstacles and no sensor faults
- **Duration**: 90 s
- **Purpose**:
  - Verify basic tracking and stability
  - Measure finish time, IAE, and energy proxy under ideal conditions

### 4.2 Scenario S2 — Disturbance (Obstacle)

- **Description**:
  - A virtual obstacle appears on the track at a specified time (t = 12 s)
  - Obstacle duration: 2 seconds (t = 12-14s)
  - **Lateral disturbance force**: 0.12 m/s² (Bronze tier - reduced from 0.30 for realistic undergraduate difficulty)
  - **Collision detection**: Robot center within 2cm of line during obstacle window
- **Duration**: 120 s
- **Purpose**:
  - Test obstacle detection and response
  - Verify functional safety (minimize collisions)
  - Assess recovery back to line and robustness
- **Note**: Perfect avoidance (0 contacts) requires predictive techniques beyond Bronze tier

### 4.3 Scenario S3 — Fault (Sensor Dropout + Speed Cap)

- **Description**:
  - Sensor dropout from t = 20–30 s (10 s window): sensor readings are invalid or held
  - A speed cap (v ≤ 0.45 m/s) must be enforced whenever `fault_flag = 1`
- **Duration**: 150 s
- **Purpose**:
  - Evaluate safe degraded operation during sensor faults
  - Verify enforcement of speed cap
  - Check for line‑loss events

---

## 5. Interface Control Document (ICD) — Summary

Control and logging rate: **100 Hz** (Δt = 0.01 s)

### 5.1 Controller Inputs

From the twin to your controller:

- `sensor[5]` — normalized reflectance values, range [0..1], 5 elements
- `e_line` — lateral error to the track centre (m)
- `v` — forward speed (m/s)
- `omega` — yaw rate (rad/s)
- `obstacle_flag` — boolean; 1 when an obstacle is present (S2)
- `fault_flag` — boolean; 1 during the defined S3 fault window

### 5.2 Controller Outputs

From your controller to the twin:

- `u_L`, `u_R` — normalized wheel commands, range [−1..1]

### 5.3 Diagnostic / Derived Signals (read‑only to you, written by twin)

- `line_loss_flag` — boolean; 1 when \(|e_{\text{line}}|\) exceeds a defined threshold
- `sat_flag_L`, `sat_flag_R` — booleans; 1 if corresponding command is saturated
- `safety_violation` — boolean; 1 if a safety condition is breached

The **full ICD** with exact units, ranges, and comments is in `interfaces/ICD_linefollower.md`.  
Your controller **must respect** signal ranges and treat flags appropriately.

---

## 6. Logging Schema

All teams record data using the **same CSV schema** at 100 Hz:

1. `run_id` (string) e.g., `Team03_S1_001`
2. `scenario_id` (string) `S1`, `S2`, or `S3`
3. `t` (s)
4. `x` (m)
5. `y` (m)
6. `theta` (rad)
7. `v` (m/s)
8. `omega` (rad/s)
9. `e_line` (m)
10. `line_loss_flag` (0/1)
11-15. `sensor_1` through `sensor_5` (0..1)
16. `obstacle_flag` (0/1)
17. `fault_flag` (0/1)
18. `u_L` (−1..1)
19. `u_R` (−1..1)
20. `sat_flag_L` (0/1)
21. `sat_flag_R` (0/1)
22. `safety_violation` (0/1)
23. `notes` (string, optional)

**File naming convention:**

- `logging/MC3113_AY25_Team##_<Scenario>_runNNN.csv`

Do **not** change column order or omit columns.

---

## 7. Metrics (Provided Script)

A shared metrics script (e.g., `metrics/compute_metrics.m`) computes:

### 7.1 Common Metrics

For each run:

- `t_final` — final time or time to finish
- **IAE** — Integrated Absolute Error:
  \[
  \mathrm{IAE} = \int |e_{\text{line}}(t)| \, dt \approx \sum_k |e_{\text{line}}[k]| \, \Delta t
  \]
- **Energy proxy**:
  \[
  E_{\text{proxy}} = \int (|u_L| + |u_R|)\, dt
  \]

### 7.2 Scenario‑Specific Metrics

- **S2**:
  - `obstacle_contacts` — number of safety_violation events during obstacle window
- **S3**:
  - `max_v_fault` — maximum v during `fault_flag = 1`
  - `speed_cap_ok` — true if `max_v_fault` ≤ 0.45 m/s
  - `line_loss_events` — number of line‑loss episodes longer than 1 s

---

## 8. Competition Format and Scoring

Each team must produce **one official run per scenario** (S1, S2, S3) for scoring.

### 8.1 Scenario Weights

- **S1 (Nominal)**: 40%
- **S2 (Obstacle)**: 30%
- **S3 (Fault/Safety)**: 30%

### 8.2 Performance Metrics Per Scenario

- **S1**:
  - Finish time (lower better)
  - IAE (lower better)
  - Energy proxy (lower better)

- **S2**:
  - Same as S1, plus:
  - Obstacle contacts (minimize - perfect avoidance not required for Bronze)

- **S3**:
  - Finish time and IAE
  - Safety:
    - Hard fail if speed cap is violated
    - Penalty if line‑loss events exceed acceptable duration

### 8.3 Tiered Performance Grading

Performance is assessed on three tiers to encourage both baseline competence and excellence:

#### **Bronze Tier (Pass - 50% performance marks)**
Demonstrates functional controller with basic safety compliance:

- **S1**: IAE ≤ 2.1 m·s, Energy ≤ 80 units, Time ≤ 90 s
- **S2**: Obstacle contacts ≤ 15 (demonstrates functional response - 60%+ reduction from baseline)
- **S3**: Speed cap enforced (v ≤ 0.45 m/s during fault), Line loss ≤ 5 s total

*Rationale*: Bronze tier ensures students can implement a working PID controller that meets fundamental safety requirements. Achievable with systematic tuning and basic scenario handling.

#### **Silver Tier (Good - 75% performance marks)**
Shows optimized performance with refined tuning:

- **S1**: IAE ≤ 0.5 m·s, Energy ≤ 70 units, Time ≤ 85 s
- **S2**: Obstacle contacts ≤ 3 (near-perfect avoidance with advanced techniques)
- **S3**: Speed cap enforced, Line loss ≤ 1 s total

*Rationale*: Silver tier rewards teams who implement adaptive strategies, predictive obstacle logic, and demonstrate excellent disturbance rejection. Requires iteration and advanced control techniques.

#### **Gold Tier (Excellent - 90%+ performance marks)**
Achieves near-optimal performance across all scenarios:

- **S1**: IAE ≤ 0.1 m·s, Energy ≤ 65 units, Time ≤ 80 s
- **S2**: Obstacle contacts = 0 (perfect predictive avoidance)
- **S3**: Speed cap enforced, Zero line loss (robust fault observers)

*Rationale*: Gold tier represents research-grade controller performance. Requires advanced techniques (feedforward, gain scheduling, predictive obstacle detection, fault observers) and extensive validation.

### 8.4 Scoring Philosophy

- **Safety first**: A run that violates hard safety constraints (speed cap violation) may receive zero score for that scenario
- **Progressive difficulty**: Each tier requires increasingly sophisticated control strategies
- **Tier qualification**: Teams must meet **all** requirements within a tier to qualify
- **Partial credit**: Performance between tiers is awarded proportionally

---

## 9. Standards and Requirements

Each team must define a **testable requirement set** for the line‑follower, informed by standards.

### 9.1 Baseline Requirements (Bronze Tier - Realistic for Undergraduates)

All teams must demonstrate compliance with these minimum requirements:

#### **R‑TIME-01 (S1 - Nominal Completion Time)**
- **Statement**: "In Scenario S1, the system shall complete the track in ≤ 90 s."
- **Acceptance**: `t_finish ≤ 90.0 s` from CSV
- **Tier**: Bronze (minimum passing requirement)
- **Standards mapping**: VDI 2206 (functional requirement verification)

#### **R‑IAE-01 (S1 - Tracking Accuracy)**
- **Statement**: "In Scenario S1, the IAE shall be ≤ 2.1 m·s using 100 Hz samples of \(e_{\text{line}}\)."
- **Acceptance**: IAE ≤ 2.1 m·s
- **Tier**: Bronze (minimum passing requirement)
- **Standards mapping**: VDI 2206 (performance verification)
- **Note**: Silver tier: ≤ 0.5 m·s; Gold tier: ≤ 0.1 m·s
- **Rationale**: 2.1 m·s achievable with well-tuned PID; tighter tolerances require advanced techniques

#### **R‑ENERGY-01 (S1 - Energy Efficiency)**
- **Statement**: "In Scenario S1, the energy proxy shall be ≤ 80 units."
- **Acceptance**: \(E_{\text{proxy}} = \int (|u_L| + |u_R|)\, dt ≤ 80.0\) units
- **Tier**: Bronze (minimum passing requirement)
- **Standards mapping**: ISO 14040/44 (environmental constraint - use phase energy)
- **Note**: Silver tier: ≤ 70 units; Gold tier: ≤ 65 units

#### **R‑OBS-01 (S2 - Obstacle Response)**
- **Statement**: "In Scenario S2, the system shall demonstrate functional obstacle avoidance response."
- **Acceptance**: `obstacle_contacts ≤ 15` (demonstrates 60%+ reduction from untuned baseline ~40)
- **Tier**: Bronze (minimum passing requirement)
- **Standards mapping**: ISO 26262 (functional safety - hazard mitigation)
- **Rationale**: Perfect avoidance (0 contacts) requires predictive sensing beyond Bronze tier scope. Significant contact reduction demonstrates functional safety response. Silver tier: ≤3; Gold tier: 0
- **Note**: Collision defined as robot center within 2cm of line during obstacle window

#### **R‑CAP-01 (S3 - Speed Cap Enforcement)**
- **Statement**: "In Scenario S3, when `fault_flag = 1`, the forward velocity v(t) shall not exceed 0.45 m/s."
- **Acceptance**: `max(v)` during fault window ≤ 0.45 m/s
- **Tier**: **All tiers (hard requirement)** - Failure = scenario score zero
- **Standards mapping**: ISO 26262 / IEC 61508 (safe state during fault)

#### **R‑FAULT-01 (S3 - Line Loss Management)**
- **Statement**: "In Scenario S3, sustained line loss where \(|e_{\text{line}}| > 0.50\) m shall not exceed 5.0 s total accumulated duration."
- **Acceptance**: `line_loss_total_duration ≤ 5.0 s`
- **Tier**: Bronze (minimum passing requirement)
- **Standards mapping**: ISO 13849 (fault tolerance - degraded mode operation)
- **Note**: Silver tier: ≤ 1.0 s; Gold tier: 0 s (no line loss)

### 9.2 Enhanced Requirements (Silver/Gold Tiers)

Teams targeting higher tiers should add requirements addressing:

- **Transient response**: Overshoot limits, settling time after disturbances
- **Energy optimization**: Minimize oscillations, use feedforward compensation
- **Predictive obstacle avoidance**: Detect and avoid obstacles before physical contact
- **Fault recovery**: Time to re-acquire line after sensor dropout
- **Robustness**: Performance under parameter variations

### 9.3 RTM and Standards Mapping

Teams maintain a **Requirements‑to‑Test Matrix (RTM)** with columns:

- ReqID, short text, acceptance criteria, tier (Bronze/Silver/Gold), TestID, Method (I/T/A/S), Scenario (S1/S2/S3), evidence file(s)

Standards influence requirements and tests:

- **VDI 2206**:
  - Use the V‑model; ensure each requirement is paired with at least one planned test in the RTM
  - Document traceability from stakeholder needs → requirements → architecture → tests → evidence

- **ISO 26262 / IEC 61508 / ISO 13849**:
  - Define a **safe state** for sensor failure: speed cap, line‑loss limits, fallback behaviour
  - Provide evidence (S3 logs and metrics) that the safe state is maintained
  - Document hazard analysis: identify obstacle contact and speed overshoot as hazards, show mitigation

- **ISO 14040/44**:
  - Introduce an **energy‑related requirement** and justify it as a use‑phase environmental constraint
  - Optional: Compare energy consumption across different controller architectures

---

## 10. Project Milestones and Deliverables

### Week 5 — SDR (System Design Review, formative)

- **Item Definition**
- **Requirements**: At least 3 FR/NFR with acceptance criteria (should target Bronze tier minimum)
- **Architecture & ICD**: High‑level BDD/IBD sketch, ICD v0.1 table
- **Verification Plan Outline**: Which metrics verify each requirement, target tier and justification
- **Standards scan**: 2–3 standards with one clear design/test implication each

### Week 9 — PDR (Preliminary Design Review, graded)

- At least one **working S1 controller** (should target Bronze tier minimum)
- One valid S1 log and metrics computed with the shared script
- RTM v0.2 (≥3 rows linking requirements ↔ tests ↔ S1)
- ICD v1 (more complete; includes telemetry and HMI signals)
- Plots for S1: time vs. position, e_line, u_L/u_R, key flags
- Performance assessment: Which tier is current S1 performance? What needs improvement?
- Updated risk/issue list and next steps

### Week 11 — CDR (Critical Design Review, graded)

- Verified runs and logs for **S1, S2, S3**
- Full RTM mapping requirements → tests with pass/fail status and tier qualification
- Safety evidence:
  - Speed cap and line‑loss checks in S3
  - Obstacle handling in S2
- Test procedures and acceptance thresholds documented (Bronze/Silver/Gold)
- Configuration/change log: what changed since PDR and why
- Final tier claim with supporting evidence

### Week 13 — Demo (graded)

- Demonstration of S2–S3 performance (live or pre‑recorded)
- Short walkthrough of metrics and evidence showing tier qualification
- Micro‑vivas on controller design, safety behaviour, and tier achievement

### Week 14 — Final Presentation & Report (graded)

- Narrative of design evolution and decisions
- Full traceability from requirements through tests and results
- Tier achievement analysis: Why did you reach Bronze/Silver/Gold? What limited further improvement?
- Discussion of sensitivity/robustness, standards compliance, and lessons learned
- Reflection on trade-offs between time, accuracy, and energy

---

## 11. Controller Development Guidelines

Your controller should:

- Run at 100 Hz, reading inputs and writing outputs according to the ICD
- Respect command saturations and scenario constraints (especially S3 speed cap)
- Handle sensor noise and potential dropout gracefully
- Implement reasonable safety behaviours

Recommended development steps:

1. **Bronze tier foundation** (Weeks 3-6):
   - Implement a PID controller for S1
   - Tune to achieve IAE ≤ 2.1 m·s, Energy ≤ 80 units
   - Add basic obstacle response for S2 (reactive avoidance)
   - Implement S3 speed cap enforcement and basic fault handling

2. **Silver tier optimization** (Weeks 7-9):
   - Refine PID gains for better tracking (IAE ≤ 0.5 m·s)
   - Implement advanced obstacle avoidance (predictive or adaptive)
   - Add derivative action for damping, optimize integral anti-windup
   - Improve energy efficiency through strategic speed profiles

3. **Gold tier excellence** (Weeks 10-12, optional):
   - Implement advanced techniques: feedforward, gain scheduling, predictive obstacle detection
   - Optimize energy through path planning
   - Add robust fault observers for S3
   - Validate across multiple parameter variations

4. **Iterate systematically**:
   - Use the metrics script to quantify improvements after each change
   - Document gain tuning process and rationale in design log
   - Maintain version control; tag each milestone (SDR, PDR, CDR)

---

## 12. Academic Integrity and AI Use

You may:

- Use AI to help with grammar, summarising public standards documents, or generating ideas
- Use code suggestions as inspiration, **only if you understand them and can explain them**

You may not:

- Submit controllers or explanations generated entirely by AI that you cannot justify in a viva
- Manipulate logs or metrics manually to fake results
- Claim a higher tier without genuine performance evidence

Expect:

- Short oral questions (micro‑vivas) where you must explain your controller, requirements, RTM links, tier justification, and evidence
- Marks to depend on both artefacts and demonstrated understanding

---

## 13. Submission Instructions

For each milestone, your team will submit:

- **Reports / briefings**: PDF
- **Slides / posters**: PPTX + PDF
- **Logs**: CSV following `log_schema.md`
- **Metrics**: text / JSON output + plots (PNG/PDF)
- **Code**: `.m`, `.slx`, or equivalent

**Naming convention:**

```
MC3113_AY25_Team##_SDR_Report_v1.0.pdf
MC3113_AY25_Team##_PDR_S1_log.csv
MC3113_AY25_Team##_CDR_Metrics_S1S2S3.json
MC3113_AY25_Team##_Demo_Controller_v1.3.m
MC3113_AY25_Team##_TierEvidence_Bronze.pdf
```

---

## 14. Instructor Quick‑Start (Demo in Class)

For instructors:

1. Add `linefollower_twin` to MATLAB path
2. Implement a simple controller (Bronze tier target)
3. Run scenarios and compute metrics
4. Show tier differences to illustrate requirements and RTM

**Teaching recommendation**: Show both untuned (fails Bronze) and tuned (achieves Bronze) controllers to illustrate importance of systematic design.

---

## 15. Common Pitfalls and Troubleshooting

- **Unstable behaviour**: Gains too high; reduce and add derivative damping
- **Logs with wrong format**: Use provided logging helper
- **Failing S3 speed cap**: Check `fault_flag` and clamp speed
- **Bronze tier not achieved**: 
  - S1 IAE: Tune gains systematically
  - S2 contacts: Implement reactive avoidance (reverse during obstacle)
  - S3: Enforce speed cap strictly
- **Incorrect RTM entries**: Always specify scenario, tier, metric, and evidence file

---

## 16. Marking Overview (High‑Level)

Exact rubrics will be provided separately, but in broad terms:

- **SDR (10%)**: Conceptual completeness and clarity
- **PDR (20%)**: Working S1 controller; quality of early RTM and metrics; Bronze tier progress
- **CDR (25%)**: Verified S1–S3 performance; safety and standards mapping; tier qualification
- **Demo (20%)**: Scenario performance, tier achievement, professional presentation
- **Final Presentation & Report (25%)**: Depth of analysis, traceability, tier justification, communication quality

**Performance component**: Weighted by tier achieved (Bronze: 50%, Silver: 75%, Gold: 90%+ of available performance marks)

---

## 17. Appendices

### 17.1 Tier Qualification Summary Table

| Tier | S1 IAE | S1 Energy | S1 Time | S2 Contacts | S3 Speed Cap | S3 Line Loss | Performance % |
|------|--------|-----------|---------|-------------|--------------|--------------|---------------|
| **Bronze** | ≤ 2.1 m·s | ≤ 80 | ≤ 90 s | ≤ 15 | ≤ 0.45 m/s (hard) | ≤ 5 s | 50% |
| **Silver** | ≤ 0.5 m·s | ≤ 70 | ≤ 85 s | ≤ 3 | ≤ 0.45 m/s (hard) | ≤ 1 s | 75% |
| **Gold** | ≤ 0.1 m·s | ≤ 65 | ≤ 80 s | 0 | ≤ 0.45 m/s (hard) | 0 s | 90%+ |

**Note**: Hard requirements (speed cap) must pass for any tier qualification. Tier is determined by the **lowest tier achieved across all metrics**.

### 17.2 Teaching Notes - Disturbance Tuning

The S2 obstacle scenario includes a lateral disturbance force that pushes the robot toward the line:

```
disturbance_force_y = 0.12 * sin(pi * (t - 12) / 2);  % Peak: 0.12 m/s²
```

**Tier-based disturbance scaling** (optional for advanced courses):
- **Bronze**: 0.12 m/s² (reactive avoidance sufficient)
- **Silver**: 0.20 m/s² (requires predictive or adaptive techniques)
- **Gold**: 0.30 m/s² (requires advanced obstacle prediction)

This creates pedagogically meaningful tier differentiation.

### 17.3 Collision Detection Threshold

Collision is defined as:
```
abs(e_line) < 0.02  % Robot center within 2cm of line during obstacle
```

This represents realistic physical contact given typical robot/track dimensions.

---

_End of MC3113 Line‑Follower Project Brief_
