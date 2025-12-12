\# MC3113 Line‑Follower Project Brief (Digital Twin Competition)



Version: AY25.1  

Audience: Students and Instructors  

Owner: MC3113 Teaching Team  

Status: Released (frozen parameters effective Week 3)



---



\## 1. Purpose and Learning Goals



This project gives every team a common, well‑specified mechatronic system to practice the end‑to‑end design process:



> Item Definition → Requirements → Architecture / ICD → Controller Design → Verification \& Validation → Design Reviews



You will use a \*\*shared digital twin\*\* of a line‑follower robot as the backbone for:



\- Applying \*\*MBSE\*\* and the \*\*V‑model (VDI 2206)\*\*.

\- Writing \*\*measurable functional and non‑functional requirements\*\*.

\- Building \*\*traceability\*\* from requirements to tests and evidence (RTM).

\- Defining and using \*\*interface control documents (ICDs)\*\*.

\- Running \*\*scenario‑based verification\*\* using a common metrics set.

\- Incorporating \*\*standards\*\* (VDI 2206, ISO 26262 / IEC 61508, ISO 13849, ISO 14040/44) into design and testing.



---



\## 2. System Overview (What You Are Building)



\- \*\*Plant\*\*: Differential‑drive line‑follower robot simulated in a provided digital twin.

\- \*\*Sensors\*\*: 5‑element reflectance array across the track plus a derived lateral error signal \\(e\_{\\text{line}}\\).

\- \*\*Controller\*\*: Your code that reads sensor and state signals and outputs left/right wheel commands \\((u\_L, u\_R)\\) at 100 Hz.

\- \*\*HMI / Telemetry\*\*: Start/stop, scenario selection, standard 100 Hz CSV logging.

\- \*\*Safety\*\*: Scenario‑specific safety behaviour (e.g., speed caps, line‑loss limits) enforced by your controller and checked by the twin.



Your team \*\*does not\*\* change the plant physics or scenario definitions.  

Your team \*\*does\*\* design:



\- The controller logic (and any additional safety logic).

\- Supporting HMI elements and scripts.

\- Requirements and V\&V artefacts (RTM, test procedures, evidence).



---



\## 3. Digital Twin Asset Pack



The teaching team provides a reference "twin asset pack" with this structure:



```

LineFollowerDemo/

&nbsp; README.md

&nbsp; config/

&nbsp;   scenarios.yaml          # S1 / S2 / S3 definitions

&nbsp; models/                   # (optional) Simulink models

&nbsp;   plant\_model.slx         # Simulink / Simscape plant model

&nbsp;   controller\_stub.slx     # Controller I/O ports matching the ICD

&nbsp; interfaces/

&nbsp;   ICD\_linefollower.md     # All signal names, units, rates, ranges

&nbsp; logging/

&nbsp;   log\_schema.md           # CSV column order and definitions

&nbsp; metrics/

&nbsp;   compute\_metrics.m       # Script to compute metrics from CSV logs

&nbsp; scripts/

&nbsp;   run\_scenario.m          # Runs a scenario and writes CSV logs

&nbsp;   run\_scenario\_simple.m   # Simple fidelity (fast testing)

&nbsp;   run\_scenario\_hifi.m     # High fidelity (research grade)

&nbsp; src/

&nbsp;   my\_controller\_step.m    # Student controller template

&nbsp; docs/

&nbsp;   Line-Follower-Project-Brief.md  # This document

&nbsp;   DemoSteps.md            # Getting started guide

&nbsp; testing/

&nbsp;   verify\_branch.m         # Branch verification tool

```



\*\*Branch Structure:\*\*



\- \*\*`main` branch\*\*: Student-facing materials (templates, docs, getting started)

\- \*\*`demo-instructor-complete` branch\*\* (instructor only): Complete working solution with:

&nbsp; - `demo-solution/` — instructor controller and guides

&nbsp; - `plotting/` — visualization tools



\*\*Note to students\*\*: You work on the `main` branch. The `demo-instructor-complete` branch is for instructor demonstrations only and is not accessible to students.



\*\*Configuration files:\*\*



\- Scenario definitions in `config/scenarios.yaml` are \*\*frozen\*\* by end of Week 3.

\- Students may read these but should not change them unless explicitly asked (e.g., for sensitivity studies).

\- All teams must adhere to the same ICD, logging schema, and metrics script.



---



\## 4. Verification Scenarios (S1, S2, S3)



Three shared scenarios define the verification and competition spine.



\### 4.1 Scenario S1 — Nominal



\- \*\*Description\*\*: Baseline line‑following with no obstacles and no sensor faults.

\- \*\*Duration\*\*: 90 s.

\- \*\*Purpose\*\*:

&nbsp; - Verify basic tracking and stability.

&nbsp; - Measure finish time, IAE, and energy proxy under ideal conditions.



\### 4.2 Scenario S2 — Disturbance (Obstacle)



\- \*\*Description\*\*:

&nbsp; - A virtual obstacle appears on the track at a specified time (e.g., t = 12 s) and location.

&nbsp; - Obstacle length ≈ 0.25 m.

\- \*\*Duration\*\*: 120 s.

\- \*\*Purpose\*\*:

&nbsp; - Test obstacle detection and response.

&nbsp; - Verify zero physical contact (no “collisions”).

&nbsp; - Assess recovery back to line and robustness.



\### 4.3 Scenario S3 — Fault (Sensor Dropout + Speed Cap)



\- \*\*Description\*\*:

&nbsp; - Sensor dropout from t = 20–30 s (10 s window): sensor readings are invalid or held.

&nbsp; - A speed cap (e.g., \\(v \\le 0.45\\) m/s) must be enforced whenever `fault\_flag = 1`.

\- \*\*Duration\*\*: 150 s.

\- \*\*Purpose\*\*:

&nbsp; - Evaluate safe degraded operation during sensor faults.

&nbsp; - Verify enforcement of speed cap.

&nbsp; - Check for line‑loss events (e.g., \\(|e\_{\\text{line}}| > 0.5\\) m for more than 1 s).



---



\## 5. Interface Control Document (ICD) — Summary



Control and logging rate: \*\*100 Hz\*\* (Δt = 0.01 s).



\### 5.1 Controller Inputs



From the twin to your controller:



\- `sensor\[5]` — normalized reflectance values, range \[0..1], 5 elements.

\- `e\_line` — lateral error to the track centre (m).

\- `v` — forward speed (m/s).

\- `omega` — yaw rate (rad/s).

\- `obstacle\_flag` — boolean; 1 when an obstacle is present (S2).

\- `fault\_flag` — boolean; 1 during the defined S3 fault window.



\### 5.2 Controller Outputs



From your controller to the twin:



\- `u\_L`, `u\_R` — normalized wheel commands, range \[−1..1].



\### 5.3 Diagnostic / Derived Signals (read‑only to you, written by twin)



\- `line\_loss\_flag` — boolean; 1 when \\(|e\_{\\text{line}}|\\) exceeds a defined threshold.

\- `sat\_flag\_L`, `sat\_flag\_R` — booleans; 1 if corresponding command is saturated.

\- `safety\_violation` — boolean; 1 if a safety condition is breached (e.g., obstacle contact, speed cap violation).



The \*\*full ICD\*\* with exact units, ranges, and comments is in `interfaces/ICD\_linefollower.md`.  

Your controller \*\*must respect\*\* signal ranges and treat flags appropriately.



---



\## 6. Logging Schema



All teams record data using the \*\*same CSV schema\*\* at 100 Hz:



1\. `run\_id`           (string) e.g., `Team03\_S1\_001`

2\. `scenario\_id`      (string) `S1`, `S2`, or `S3`

3\. `t`                (s)

4\. `x`                (m)

5\. `y`                (m)

6\. `theta`            (rad)

7\. `v`                (m/s)

8\. `omega`            (rad/s)

9\. `e\_line`           (m)

10\. `line\_loss\_flag`  (0/1)

11\. `sensor\_1`        (0..1)

12\. `sensor\_2`

13\. `sensor\_3`

14\. `sensor\_4`

15\. `sensor\_5`

16\. `obstacle\_flag`   (0/1)

17\. `fault\_flag`      (0/1)

18\. `u\_L`             (−1..1)

19\. `u\_R`             (−1..1)

20\. `sat\_flag\_L`      (0/1)

21\. `sat\_flag\_R`      (0/1)

22\. `safety\_violation`(0/1)

23\. `notes`           (string, optional)



\*\*File naming convention:\*\*



\- `logging/MC3113\_AY25\_Team##\_<Scenario>\_runNNN.csv`



Example: `MC3113\_AY25\_Team03\_S1\_run001.csv`



Do \*\*not\*\* change column order or omit columns. If you add extra signals, put them after column 23 and document them.



---



\## 7. Metrics (Provided Script)



A shared metrics script (e.g., `metrics/compute\_metrics.m`) computes:



\### 7.1 Common Metrics



For each run:



\- `t\_final` — final time or time to finish a defined end of track.

\- \*\*IAE\*\* — Integrated Absolute Error:

&nbsp; \\\[

&nbsp; \\mathrm{IAE} = \\int |e\_{\\text{line}}(t)| \\, dt \\approx \\sum\_k |e\_{\\text{line}}\[k]| \\, \\Delta t

&nbsp; \\]

\- \*\*Energy proxy\*\*:

&nbsp; \\\[

&nbsp; E\_{\\text{proxy}} = \\int (|u\_L| + |u\_R|)\\, dt

&nbsp; \\]



\### 7.2 Scenario‑Specific Metrics



\- \*\*S2\*\*:

&nbsp; - `obstacle\_contacts` — number of times `safety\_violation` indicates a collision.

\- \*\*S3\*\*:

&nbsp; - `max\_v\_fault` — maximum `v` during `fault\_flag = 1`.

&nbsp; - `speed\_cap\_ok` — true if `max\_v\_fault` ≤ 0.45 m/s.

&nbsp; - `line\_loss\_events` — number of line‑loss episodes longer than 1 s.



These metrics are used:



\- By you, to tune controllers.

\- By the teaching team, to \*\*score\*\* performance and check requirement compliance.



---



\## 8. Competition Format and Scoring



Each team must produce \*\*one official run per scenario\*\* (S1, S2, S3) for scoring, plus any number of test runs.



\### 8.1 Scenario Weights



\- \*\*S1 (Nominal)\*\*: 40%

\- \*\*S2 (Obstacle)\*\*: 30%

\- \*\*S3 (Fault/Safety)\*\*: 30%



\### 8.2 Performance Metrics Per Scenario



\- \*\*S1\*\*:

&nbsp; - Finish time (lower better).

&nbsp; - IAE (lower better).

&nbsp; - Energy proxy (lower better).



\- \*\*S2\*\*:

&nbsp; - Same as S1, plus:

&nbsp; - Obstacle contacts (must be 0 for full credit; each contact heavily penalised).



\- \*\*S3\*\*:

&nbsp; - Finish time and IAE.

&nbsp; - Safety:

&nbsp;   - Hard fail if speed cap is violated (v > 0.45 m/s during `fault\_flag = 1`).

&nbsp;   - Hard fail (or strong penalty) if line‑loss events exceed a defined duration/number.



\### 8.3 Scoring Philosophy



\- \*\*Safety first\*\*: A run that violates safety constraints may receive zero score for that scenario regardless of speed.

\- \*\*Trade‑offs\*\*: There is typically a trade‑off between time, accuracy, and energy; clever controllers balance these.



Exact numerical scoring formulas will be shared later (e.g., min–max normalization or rank‑based), but the \*\*metrics and weights listed here are fixed\*\*.



---



\## 9. Standards and Requirements



Each team must define a \*\*small, testable requirement set\*\* for the line‑follower, informed by standards.



\### 9.1 Example Requirements



\- \*\*R‑TIME (S1)\*\*:

&nbsp; - “In Scenario S1, the system shall complete the track in ≤ 70 s, measured from start flag to finish zone entry.”

&nbsp; - Acceptance: `t\_finish − t\_start ≤ 70.0 s` from CSV.



\- \*\*R‑IAE (S1)\*\*:

&nbsp; - “In Scenario S1, the IAE shall be ≤ 0.020 m·s using 100 Hz samples of \\(e\_{\\text{line}}\\).”

&nbsp; - Acceptance: IAE ≤ 0.020 m·s.



\- \*\*R‑OBS (S2)\*\*:

&nbsp; - “In Scenario S2, the system shall avoid physical contact with the obstacle.”

&nbsp; - Acceptance: `obstacle\_contacts = 0` (no `safety\_violation` events flagged as contact).



\- \*\*R‑CAP (S3)\*\*:

&nbsp; - “In Scenario S3, when `fault\_flag = 1`, the forward velocity v(t) shall not exceed 0.45 m/s.”

&nbsp; - Acceptance: `max(v)` during fault window ≤ 0.45 m/s.



\- \*\*R‑LL (S3)\*\*:

&nbsp; - “In Scenario S3, there shall be no sustained line loss where \\(|e\_{\\text{line}}| > 0.50\\) m for more than 1 s continuously.”

&nbsp; - Acceptance: `line\_loss\_events = 0`.



\### 9.2 RTM and Standards Mapping



Teams maintain a \*\*Requirements‑to‑Test Matrix (RTM)\*\* with columns:



\- ReqID, short text, acceptance criteria, TestID, Method (I/T/A/S), Scenario (S1/S2/S3), evidence file(s).



Standards influence requirements and tests, for example:



\- \*\*VDI 2206\*\*:

&nbsp; - Use the V‑model; ensure each requirement is paired with at least one planned test in the RTM.



\- \*\*ISO 26262 / IEC 61508 / ISO 13849\*\*:

&nbsp; - Define a \*\*safe state\*\* for sensor failure: speed cap, line‑loss gate, and a fallback behaviour.

&nbsp; - Provide evidence (S3 logs and metrics) that the safe state is maintained.



\- \*\*ISO 14040/44\*\*:

&nbsp; - Introduce an \*\*energy‑related requirement\*\* (e.g., limit on energy proxy) and justify it as a use‑phase environmental constraint.



---



\## 10. Project Milestones and Deliverables



\### Week 5 — SDR (System Design Review, formative)



\- \*\*Item Definition\*\*:

&nbsp; - Boundary, internal/external elements, interfaces, assumptions, constraints, stakeholders.

\- \*\*Requirements\*\*:

&nbsp; - At least 3 FR/NFR with acceptance criteria.

\- \*\*Architecture \& ICD\*\*:

&nbsp; - High‑level BDD/IBD sketch.

&nbsp; - ICD v0.1 table with core signals (sensor\[5], e\_line, v, omega, u\_L, u\_R, flags).

\- \*\*Verification Plan Outline\*\*:

&nbsp; - Which metrics and scenarios will verify each requirement.

\- \*\*Standards scan\*\*:

&nbsp; - 2–3 standards with one clear design/test implication each.



\### Week 9 — PDR (Preliminary Design Review, graded)



\- At least one \*\*working S1 controller\*\*.

\- One valid S1 log and metrics computed with the shared script.

\- RTM v0.2 (≥3 rows linking requirements ↔ tests ↔ S1).

\- ICD v1 (more complete; includes telemetry and any HMI signals).

\- Plots for S1: time vs. position, e\_line, u\_L/u\_R, key flags.

\- Updated risk/issue list and next steps.



\### Week 11 — CDR (Critical Design Review, graded)



\- Verified runs and logs for \*\*S1, S2, S3\*\*.

\- Full RTM mapping requirements → tests with pass/fail status.

\- Safety evidence:

&nbsp; - Speed cap and line‑loss checks in S3.

&nbsp; - Obstacle handling in S2 (no contact).

\- Test procedures and acceptance thresholds documented.

\- Configuration/change log: what changed since PDR and why.



\### Week 13 — Demo (graded)



\- Demonstration of S2–S3 performance (live or pre‑recorded).

\- Short walkthrough of metrics and evidence.

\- Micro‑vivas on controller design and safety behaviour.



\### Week 14 — Final Presentation \& Report (graded)



\- Narrative of design evolution and decisions.

\- Full traceability from requirements through tests and results.

\- Discussion of sensitivity/robustness, standards compliance, and lessons learned.



---



\## 11. Controller Development Guidelines



Your controller should:



\- Run at 100 Hz, reading inputs and writing outputs according to the ICD.

\- Respect command saturations and scenario constraints (especially S3 speed cap).

\- Handle sensor noise and potential dropout gracefully.

\- Implement reasonable safety behaviours:

&nbsp; - Reduce speed in uncertain conditions.

&nbsp; - Avoid aggressive oscillations and actuator banging.



Recommended development steps:



1\. Implement a simple P or PD controller for S1.

2\. Once S1 is stable, add obstacle logic for S2 (e.g., slow down or reroute).

3\. Add fault handling for S3:

&nbsp;  - Enforce speed cap when `fault\_flag = 1`.

&nbsp;  - Use last‑known good line estimate or a fallback strategy.

4\. Iterate, using the metrics script to guide improvements.



---



\## 12. Academic Integrity and AI Use



You may:



\- Use AI to help with grammar, summarising public standards documents, or generating ideas.

\- Use code suggestions as inspiration, \*\*only if you understand them and can explain them\*\*.



You may not:



\- Submit controllers or explanations generated entirely by AI that you cannot justify in a viva.

\- Manipulate logs or metrics manually to fake results.



Expect:



\- Short oral questions (micro‑vivas) where you must explain your controller, requirements, RTM links, and evidence.

\- Marks to depend on both artefacts and demonstrated understanding.



---



\## 13. Submission Instructions (Files and Formats)



For each milestone, your team will submit:



\- \*\*Reports / briefings\*\*: PDF.

\- \*\*Slides / posters\*\*: PPTX + PDF.

\- \*\*Logs\*\*: CSV following `log\_schema.md`.

\- \*\*Metrics\*\*: text / JSON output + plots (PNG/PDF).

\- \*\*Code\*\*: `.m`, `.slx`, or equivalent, as required.



\*\*Naming convention:\*\*



```

MC3113\_AY25\_Team##\_SDR\_Report\_v1.0.pdf

MC3113\_AY25\_Team##\_PDR\_S1\_log.csv

MC3113\_AY25\_Team##\_CDR\_Metrics\_S1S2S3.json

MC3113\_AY25\_Team##\_Demo\_Controller\_v1.3.m

```



Check the module instructions or instructor emails for the exact submission channel (LMS, email, or shared drive).



---



\## 14. Instructor Quick‑Start (Demo in Class)



For instructors:



1\. Add `linefollower\_twin` to MATLAB path.

2\. Implement a simple controller, e.g.:



&nbsp;  ```

&nbsp;  function \[u\_L, u\_R] = my\_controller\_step(inputs)

&nbsp;      Kp = -1.0;

&nbsp;      base = 0.4;

&nbsp;      steer = Kp \* inputs.e\_line;

&nbsp;      u\_L = max(min(base - steer, 1.0), -1.0);

&nbsp;      u\_R = max(min(base + steer, 1.0), -1.0);

&nbsp;  end

&nbsp;  ```



3\. Run a scenario:



&nbsp;  ```

&nbsp;  run\_scenario('S1', @my\_controller\_step, 'Demo\_S1\_001');

&nbsp;  ```



4\. Compute metrics:



&nbsp;  ```

&nbsp;  metrics = compute\_metrics('logging/Demo\_S1\_001.csv', 'S1')

&nbsp;  ```



5\. Show metrics and plots to the class; use them to illustrate requirements and RTM rows.



---



\## 15. Common Pitfalls and Troubleshooting



\- \*\*Unstable behaviour\*\*:

&nbsp; - Gains too high; outputs saturate.

&nbsp; - Fix: reduce gains; ensure smooth commands.



\- \*\*Logs with wrong format\*\*:

&nbsp; - Missing columns or wrong order.

&nbsp; - Fix: use the provided logging helper or adapt your script to match `log\_schema.md`.



\- \*\*Failing S3 speed cap\*\*:

&nbsp; - Controller does not check `fault\_flag`.

&nbsp; - Fix: clamp commanded speed when `fault\_flag = 1`.



\- \*\*Incorrect RTM entries\*\*:

&nbsp; - Requirements do not clearly map to scenarios or metrics.

&nbsp; - Fix: always specify scenario (S1/S2/S3), metric, and evidence file for each requirement.



---



\## 16. Marking Overview (High‑Level)



Exact rubrics will be provided separately, but in broad terms:



\- \*\*SDR\*\*: Conceptual completeness and clarity (Item Definition, early requirements, ICD v0.1).

\- \*\*PDR\*\*: Working S1 controller; quality of early RTM and metrics; clarity of plots and explanations.

\- \*\*CDR\*\*: Verified S1–S3 performance; safety and standards mapping; final RTM and test evidence.

\- \*\*Demo\*\*: Scenario performance, professional presentation, and micro‑viva responses.

\- \*\*Final Presentation \& Report\*\*: Depth of analysis, traceability, reflection, and communication quality.



---



\## 17. Appendices



\### 17.1 Energy Proxy Pseudo‑Code



\*\*Fixed sample time:\*\*



```

energy = 0

for k = 0..N:

&nbsp;   energy += (abs(u\_L\[k]) + abs(u\_R\[k])) \* dt

```



\*\*Variable sample time (trapezoidal):\*\*



```

energy = 0

for k = 1..N:

&nbsp;   dt = t\[k] - t\[k-1]

&nbsp;   avg = 0.5 \* (abs(u\_L\[k-1]) + abs(u\_R\[k-1]) +

&nbsp;                abs(u\_L\[k])   + abs(u\_R\[k]))

&nbsp;   energy += avg \* dt

```



\### 17.2 Example Scenario YAML Snippet (S3)



```

S3:

&nbsp; description: "Sensor dropout + speed cap"

&nbsp; duration\_s: 150

&nbsp; obstacle:

&nbsp;   enabled: false

&nbsp; fault:

&nbsp;   enabled: true

&nbsp;   dropout\_start\_s: 20.0

&nbsp;   dropout\_end\_s: 30.0

&nbsp;   speed\_cap\_mps: 0.45

```



---



\_End of MC3113 Line‑Follower Project Brief\_

