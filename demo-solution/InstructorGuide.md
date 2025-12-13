# MC3113 Line-Follower Complete Demo Project - Instructor Guide
**Version:** AY25.1  
**Branch:** demo-instructor-complete  
**Status:** Instructor-only / Do not distribute

---

## Purpose

This complete demo project demonstrates the full MBSE workflow:
- Item Definition → Requirements → Architecture/ICD → Controller Design → V&V → Reviews

Use this to:
- Show students what "complete" looks like during lectures
- Calibrate your rubrics for PDR/CDR/demo marking
- Demo live during Lectures 6-9
- Prepare teaching examples

**Never share code, models, or editable files with students.**

---

## What's Included

### Documentation
- `Requirements_Complete.md` - 7 requirements (FR + NFR)
- `RTM_Complete.xlsx` - Requirements-to-Test Matrix
- `ICD_v1.0.md` - Full interface control document
- `SysML_Models.md` - BDD and IBD descriptions

### Code & Models
- `src/instructor_controller.m` - Working P+I controller with S3 safety
- `models/plant_model.slx` - Complete Simulink plant (if available)
- `scripts/run_all_scenarios_demo.m` - Batch runner

## Controller Versions

### Untuned (instructor_controller_untuned.m)
- Simple P control, Kp = -1.0
- Use for Week 3 demo to show poor performance
- IAE ≈ 20 m·s, fails requirements
- **Teaching value:** Shows why tuning matters

### Tuned (instructor_controller.m)
- Full PID with adaptive speed
- Kp = -3.0, Ki = -0.5, Kd = -0.8
- IAE ≈ 0.5-2.0 m·s, much better
- **Teaching value:** Shows proper design

### Demo Script
Week 3: Show untuned first, then tuned version
Week 11: Students present their tuned versions


### Evidence
- `logs/Demo_S1_final.csv` - S1 nominal run
- `logs/Demo_S2_final.csv` - S2 obstacle run
- `logs/Demo_S3_final.csv` - S3 fault run
- `metrics/Demo_metrics_summary.json` - All metrics
- `plots/Demo_*.png` - Key plots (e_line, u_L/u_R, v)

---

## How to Use in Teaching

### Lecture 6 (ICD + First S1 Run)
- Show `ICD_v1.0.md` on screen
- Run S1 live: `run_scenario('S1', @instructor_controller, 'Live_S1')`
- Open generated log, show columns match ICD
- Compute metrics live

### Lecture 7 (Standards → Safety Requirements)
- Show `Requirements_Complete.md` R-CAP and R-LL
- Explain how ISO 26262 safe-state concept led to these
- Show S3 log section where `fault_flag=1` and v $\leq$ 0.45

### Lecture 8-9 (PDR Preparation)
- Display RTM table and trace one requirement end-to-end
- Show S1 plots: `Demo_e_line.png`, `Demo_commands.png`
- Discuss trade-offs: IAE vs energy vs time

### Week 11 (CDR Readiness)
- Show all three scenarios' metrics side-by-side
- Highlight where safety requirements passed/failed
- Use as calibration: "This is B+/A- quality work"

---

## Running the Demo Controller

```matlab
cd '/path/to/LineFollowerDemo'
git checkout demo-instructor-complete

addpath('src', 'scripts', 'metrics', 'demo-solution');

% Run all three scenarios
run_all_scenarios_demo();

% Or run individually
run_scenario('S1', @instructor_controller, 'Demo_S1_final');
run_scenario('S2', @instructor_controller, 'Demo_S2_final');
run_scenario('S3', @instructor_controller, 'Demo_S3_final');

% Compute metrics
m1 = compute_metrics('logs/Demo_S1_final.csv', 'S1');
m2 = compute_metrics('logs/Demo_S2_final.csv', 'S2');
m3 = compute_metrics('logs/Demo_S3_final.csv', 'S3');
```

---

## Key Teaching Points

### What to Emphasize
- **Traceability**: Every requirement has TestID, scenario, evidence
- **ICD as contract**: Controller respects signal ranges/units
- **Safety first**: S3 metrics show hard constraints (speed cap, line-loss)
- **Iteration**: Mention this took 3-4 design cycles to tune

### What NOT to Say
- "This is the optimal solution" (it's deliberately mid-range)
- "Copy this structure exactly" (encourage variety in RTM/SysML formats)
- Avoid showing exact gain values (Kp, Ki) before PDR

---

## Maintenance

- **After each semester:** Review metrics thresholds if scenarios change
- **If plant model updates:** Re-run all scenarios, regenerate logs
- **Keep separate from main branch:** Never merge demo-solution/ into main

---

_End of Instructor Guide_
