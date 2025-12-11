# MC3113 Line Follower Demo – Digital Twin Assets

This repository contains a **minimal digital twin scaffold** for the MC3113 line‑follower project.  
It is intended as an instructor‑maintained reference and a starting point for student controllers.

The twin provides:

- A **standardised folder structure** for configs, interfaces, logging, metrics, and scripts.
- A **shared Interface Control Document (ICD)** for controller I/O.
- A **fixed CSV logging schema** used for all runs.
- A **metrics script** to compute time, IAE, energy proxy, and safety indicators.
- A **scenario runner template** for S1 (nominal), S2 (obstacle), and S3 (fault + speed cap).

> Students design **controllers** and requirements/V&V around this twin; they do **not** modify the plant or core configs unless explicitly asked.

---

## Repository structure

```
LineFollowerDemo/
  README.md
  .gitignore

  src/
    DemoMain.m            # (existing) main demo script
    ICD_Definition.m      # (existing) example ICD script / notes
    Requirements_RTM.m    # (existing) example requirements + RTM
    Scenario_S1.m         # (existing) scenario-specific script
    Scenario_S3.m         # (existing) scenario-specific script
    VerificationReport.m  # (existing) example verification report

  config/
    plant_params.yaml     # Plant geometry, dynamics, sensor and control rates
    scenarios.yaml        # S1, S2, S3 scenario definitions

  interfaces/
    ICD_linefollower.md   # Formal interface control document (signals, units, rates)

  logging/
    log_schema.md         # Canonical CSV log column definitions
    example_S1_log.csv    # Tiny sample log for illustration

  metrics/
    compute_metrics.m     # MATLAB function to compute metrics from a log

  scripts/
    run_scenario.m        # Template runner for S1/S2/S3 (to be wired to plant_model)
```

> Note: `plant_model.slx` / `controller_stub.slx` are expected to live under a `models/` folder when you add them.

---

## Key concepts

### Scenarios

- **S1 – Nominal:** no obstacle, no fault (baseline performance).  
- **S2 – Disturbance (obstacle):** obstacle appears mid‑run; tests avoidance/robustness.  
- **S3 – Fault (sensor dropout + speed cap):** dropout window with \( v(t) \le 0.45 \,\text{m/s} \) cap; tests safe degraded mode.

`config/scenarios.yaml` encodes durations and event timings.

### ICD (Interface Control Document)

`interfaces/ICD_linefollower.md` defines all signals between controller and plant, including:

- Inputs: `sensor[5]`, `e_line`, `v`, `omega`, `obstacle_flag`, `fault_flag`.
- Outputs: `u_L`, `u_R` in \([-1, 1]\) at 100 Hz.
- Diagnostic flags: `line_loss_flag`, `sat_flag_L/R`, `safety_violation` (logged by the twin).

Controllers must respect these names, units, and ranges.

### Logging schema

`logging/log_schema.md` fixes the CSV column order (time, states, signals, flags).  
`logging/example_S1_log.csv` shows a minimal example.

All metrics and analysis tools assume **exactly** this schema.

### Metrics

`metrics/compute_metrics.m` computes:

- `t_final` – last timestamp / finish time surrogate.
- `IAE` – \(\int |e_{\text{line}}| dt\).
- `energy_proxy` – \(\int (|u_L| + |u_R|) dt\).
- `line_loss_events` – occurrences of 1+ s continuous line‑loss.
- `obstacle_contacts` – from `safety_violation` in S2.
- `max_v_fault`, `speed_cap_ok` – speed cap behaviour in S3.

---

## How to run a basic scenario (instructor demo)

1. Ensure MATLAB’s current folder is `LineFollowerDemo` and the repo is on the path.

2. Implement a simple controller function, for example in `src/my_controller_step.m`:

   ```
   function [u_L, u_R] = my_controller_step(inputs)
   % Simple P controller on lateral error
       Kp   = -1.0;
       base = 0.4;
       steer = Kp * inputs.e_line;

       u_L = base - steer;
       u_R = base + steer;

       u_L = max(min(u_L, 1.0), -1.0);
       u_R = max(min(u_R, 1.0), -1.0);
   end
   ```

3. In the MATLAB Command Window:

   ```
   cd path\to\LineFollowerDemo
   run_scenario('S1', @my_controller_step, 'Demo_S1_001');
   ```

   This will create `logging/Demo_S1_001.csv` (with placeholder plant logic until wired).

4. Compute metrics:

   ```
   metrics = compute_metrics('logging/Demo_S1_001.csv', 'S1');
   disp(metrics);
   ```

5. Plot selected signals (e.g., `e_line`, `u_L/u_R`, flags) to discuss performance.

> Initially, `run_scenario.m` contains a *template* plant; you (or a TA) must replace the placeholder update block with a call into your `plant_model.slx` before using it for serious evaluation.

---

## Intended student workflow (later in the module)

Students will eventually:

1. Clone or download this repo.
2. Read:
   - `ICD_linefollower.md`
   - `log_schema.md`
   - Example `.m` scripts in `src/`.
3. Implement their own controllers (matching the ICD).
4. Use `run_scenario.m` and `compute_metrics.m` to:
   - Generate logs for S1/S2/S3.
   - Evaluate time, IAE, energy, and safety metrics.
5. Include metrics and plots as evidence in their SDR/PDR/CDR and demo submissions.

---

## Contribution / maintenance notes (for staff)

- **Do not** change `config/plant_params.yaml`, `config/scenarios.yaml`, `ICD_linefollower.md`, or `log_schema.md` mid‑semester unless absolutely necessary; they are the “frozen spec” for the cohort.
- Evolve:
  - `run_scenario.m` to call the real plant model.
  - `DemoMain.m` into a simple teaching/demo entry point.
- Use branches if experimenting:
  - `main`: stable teaching version.
  - `dev`: internal experiments before merging.

---

If you extend or fix the twin, please keep the README updated so students and TAs always know the current capabilities and expectations.