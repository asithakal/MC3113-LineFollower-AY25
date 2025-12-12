# MC3113 Line-Follower Demo - Complete Instructor Solution

**Branch:** `demo-instructor-complete`  
**Repository:** https://github.com/asithakal/mc3113-line-follower-demo  
**Status:** 🔒 PRIVATE - Instructor Only  
**Version:** AY25.1

---

## ⚠️ IMPORTANT: This is the INSTRUCTOR SOLUTION branch

**DO NOT:**
- ❌ Share this branch with students
- ❌ Make this branch public
- ❌ Push this to any public repository
- ❌ Include solution files in student handouts
- ❌ Show controller code before PDR

**DO:**
- ✅ Use for live demonstrations in lectures
- ✅ Use as rubric calibration for marking
- ✅ Show plots, metrics, and documentation only
- ✅ Keep on private branches only

---

## What's in this branch

This branch contains a **complete, worked solution** for the MC3113 line-follower project, demonstrating the full MBSE workflow:

```
LineFollowerDemo/
├── demo-solution/              ← Complete solution package
│   ├── InstructorGuide.md      ← How to use this in teaching
│   ├── Requirements_Complete.md ← 7 requirements (FR + NFR)
│   ├── RTM_Complete.csv        ← Full requirements traceability matrix
│   ├── ICD_v1.0.md             ← Complete interface control document
│   ├── SysML_Models.md         ← BDD/IBD descriptions
│   ├── instructor_controller.m ← Working P+I controller
│   └── run_all_scenarios_demo.m ← Batch scenario runner
├── src/                        ← Student-facing templates
├── config/                     ← Scenario configurations
├── interfaces/                 ← ICD templates
├── logging/                    ← Log schemas + demo logs
├── metrics/                    ← Metrics computation
└── scripts/                    ← Scenario runners
```

---

## Quick Start for Instructors

### 1. Switch to this branch

```
cd /path/to/mc3113-line-follower-demo
git checkout demo-instructor-complete
```

### 2. Run the complete demo

```
% In MATLAB
cd 'D:\path\to\mc3113-line-follower-demo'
# addpath(genpath(pwd));
addpath('src', 'scripts', 'metrics', 'demo-solution');

% Run all three scenarios
run_all_scenarios_demo();

% Or run individually
run_scenario('S1', @instructor_controller, 'Demo_S1_final');
run_scenario('S2', @instructor_controller, 'Demo_S2_final');
run_scenario('S3', @instructor_controller, 'Demo_S3_final');
```

### 3. View results

```
% Load metrics
m1 = compute_metrics('logging/Demo_S1_final.csv', 'S1');
m2 = compute_metrics('logging/Demo_S2_final.csv', 'S2');
m3 = compute_metrics('logging/Demo_S3_final.csv', 'S3');

% Display
disp(m1);
disp(m2);
disp(m3);
```

---

## Using this in lectures

### Week 3 (Lecture 3) - Standards, RTM, ICD
- **Show:** `demo-solution/ICD_v1.0.md` on screen
- **Show:** 2-3 requirements from `Requirements_Complete.md`
- **Demo:** Basic ICD → controller → log workflow
- **Don't show:** Controller code yet

### Week 6 (Lecture 6) - Digital Twin & First S1 Run
- **Demo:** Live S1 run with `instructor_controller`
- **Show:** Generated CSV log structure
- **Show:** Metrics computation and results
- **Don't share:** Controller .m file

### Week 7 (Lecture 7) - Standards to Safety
- **Show:** R-CAP-01 and R-LL-01 requirements
- **Show:** S3 log excerpt where fault_flag=1 and v ≤ 0.45
- **Discuss:** ISO 26262 safe-state concept

### Week 9 (PDR Preparation)
- **Show:** Complete RTM with traceability links
- **Show:** Plots from S1 (e_line, u_L/u_R, v)
- **Use as:** Calibration example for "B+/A-" quality work

### Week 11 (CDR Readiness)
- **Show:** All three scenarios' metrics side-by-side
- **Show:** Safety evidence (speed cap compliance, zero line-loss)
- **Use as:** Rubric anchor for final marking

---

## Key Performance Metrics (Demo Solution)

| Scenario | t_final (s) | IAE (m·s) | Energy | Obstacles | Line Loss | Speed Cap |
|----------|-------------|-----------|---------|-----------|-----------|-----------|
| **S1** | 72.3 | 0.021 | 54.2 | — | 0 | — |
| **S2** | 95.7 | 0.034 | 68.5 | 0 | 0 | — |
| **S3** | 118.4 | 0.052 | 71.3 | — | 0 | ✓ (0.44 m/s) |

**Performance level:** This is intentionally "good but not optimal" - leaves room for student improvement.

---

## Requirements Coverage Summary

All 7 requirements have full traceability:

- ✅ **R-TRACK-01** - Line following (S1)
- ✅ **R-TIME-01** - Completion time ≤ 75s (S1)
- ✅ **R-IAE-01** - IAE ≤ 0.025 m·s (S1)
- ✅ **R-ENERGY-01** - Energy ≤ 60 units (S1)
- ✅ **R-OBS-01** - Zero obstacle contact (S2)
- ✅ **R-FAULT-01** - Fault handling (S3)
- ✅ **R-CAP-01** - Speed cap v ≤ 0.45 m/s (S3)

See `demo-solution/RTM_Complete.csv` for full matrix.

---

## Documentation Files

| File | Purpose | Show to Students? |
|------|---------|-------------------|
| `InstructorGuide.md` | Teaching usage guide | ❌ No |
| `Requirements_Complete.md` | Example requirements | ✅ Yes (excerpts) |
| `RTM_Complete.csv` | Full traceability matrix | ✅ Yes (structure, not details) |
| `ICD_v1.0.md` | Complete ICD | ✅ Yes (as reference) |
| `SysML_Models.md` | BDD/IBD descriptions | ✅ Yes (concepts) |
| `instructor_controller.m` | Working controller | ❌ No (never) |
| Demo logs (CSV) | Scenario outputs | ✅ Yes (show structure) |
| Metrics JSON | Performance results | ✅ Yes (show as example) |

---

## Student Branch

**Students use:** [`main` branch](https://github.com/asithakal/mc3113-line-follower-demo)

The main branch contains:
- Skeleton templates
- Documentation and schemas
- Basic demo controller (simple P-only)
- Getting started guide

Students **cannot see** this `demo-instructor-complete` branch.

---

## Branch Management

### Keep demo branch private
```
# This branch should NEVER be merged to main
git checkout demo-instructor-complete
# Work on solution...
git add .
git commit -m "Update demo solution"
git push origin demo-instructor-complete  # Only to private repo
```

### Update demo with main improvements
```
# If you improve templates/docs on main, merge to demo
git checkout demo-instructor-complete
git merge main  # Brings main changes into demo
```

### Never merge demo → main
```
# NEVER do this:
# git checkout main
# git merge demo-instructor-complete  ← DON'T!
```

---

## Maintenance Checklist

Before each semester:
- [ ] Re-run all three scenarios
- [ ] Verify metrics still pass requirements
- [ ] Update plots if plant model changed
- [ ] Check ICD matches current project brief
- [ ] Review requirements for standards alignment
- [ ] Test that demo runs on fresh MATLAB install

---

## Contact

**Module Coordinator:** Dr. Asitha Kulasekera  
**Email:** asitha@uom.lk  
**Institution:** General Sir John Kotelawala Defence University  
**Module:** MC3113 - Mechatronic Systems Design

---

## Related Resources

- **Project Brief:** `docs/Line-Follower-Project-Brief.md`
- **Student Guide:** `docs/DemoSteps.md`
- **Literature Review:** See module materials
- **Standards:** VDI 2206:2021, ISO 26262:2018, ISO 14040/44

---

**Last Updated:** December 2025  
**For:** AY2025/26 Teaching

---

_This is instructor-only material. Handle with care._