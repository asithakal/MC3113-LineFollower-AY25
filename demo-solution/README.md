# Demo Solution Package - Instructor Guide

**Location:** `demo-solution/` folder  
**Branch:** demo-instructor-complete only  
**Access:** Instructor and authorized TAs only

---

## 📁 Contents

| File | Description | Use in Teaching |
|------|-------------|-----------------|
| `InstructorGuide.md` | Complete teaching usage guide | Read first |
| `Requirements_Complete.md` | 7 fully specified requirements | Show excerpts in Lecture 3-7 |
| `RTM_Complete.csv` | Full requirements-to-test matrix | Show structure at PDR prep |
| `ICD_v1.0.md` | Complete ICD with all signals | Reference during ICD activities |
| `SysML_Models.md` | BDD/IBD textual descriptions | Use for SysML lab examples |
| `instructor_controller.m` | Working MATLAB controller | Demo only, never share code |
| `run_all_scenarios_demo.m` | Batch runner for S1-S3 | Use for quick demos |

---

## 🚀 Quick Demo

```
% Set up path
cd 'D:\path\to\mc3113-line-follower-demo'
addpath('demo-solution', 'src', 'scripts', 'metrics');

% Run complete demo
run_all_scenarios_demo();

% Results saved to:
% - logging/Demo_S1_final.csv
% - logging/Demo_S2_final.csv  
% - logging/Demo_S3_final.csv
% - metrics/Demo_metrics_summary.json
```

---

## 📊 Performance Summary

### S1 - Nominal Scenario
- ⏱️ **Time:** 72.3 s (target: ≤75 s) ✅
- 📏 **IAE:** 0.021 m·s (target: ≤0.025) ✅
- ⚡ **Energy:** 54.2 units (target: ≤60) ✅
- 🎯 **Line Loss:** 0 events ✅

### S2 - Obstacle Scenario
- ⏱️ **Time:** 95.7 s
- 📏 **IAE:** 0.034 m·s
- 🚧 **Obstacle Contacts:** 0 ✅
- 🎯 **Line Loss:** 0 events ✅

### S3 - Fault Scenario
- ⏱️ **Time:** 118.4 s
- 📏 **IAE:** 0.052 m·s
- 🛡️ **Max Speed (fault):** 0.44 m/s (cap: ≤0.45) ✅
- 🎯 **Line Loss:** 0 events ✅
- ✅ **All safety requirements passed**

---

## 🎓 Teaching Guidelines

### What to Show
- ✅ Requirements structure and acceptance criteria
- ✅ RTM format and traceability links
- ✅ ICD signal definitions
- ✅ Generated CSV logs (structure)
- ✅ Metrics outputs and plots
- ✅ SysML concepts (BDD/IBD structure)

### What NOT to Show
- ❌ Controller implementation code
- ❌ Exact gain values (Kp, Ki, etc.)
- ❌ Detailed control logic before PDR
- ❌ Step-by-step solution process

### When to Use

| Week | Lecture | Use |
|------|---------|-----|
| 3 | Standards/RTM/ICD | Show requirements, ICD structure |
| 6 | Digital Twin intro | Live S1 demo, show logs/metrics |
| 7 | Safety standards | Show S3 safety evidence |
| 9 | PDR prep | Show complete RTM, plots |
| 11 | CDR prep | Show all scenarios, calibrate rubrics |

---

## 🔧 Controller Design Notes

**Architecture:** P+I control on lateral error (e_line)

**Key Features:**
- Proportional gain: Kp = 1.2
- Integral gain: Ki = 0.3  
- Anti-windup protection on integral term
- Speed modulation based on scenario:
  - S1 (nominal): base = 0.45
  - S2 (obstacle): base = 0.30 (reduced)
  - S3 (fault): base = 0.35 (capped ≤0.45)
- Line-loss recovery: amplified steering for |e_line| > 0.4

**Intentional limitations:**
- No feed-forward path
- Simple state machine (could be more sophisticated)
- Conservative gains (students can optimize)
- Energy proxy not explicitly minimized

This leaves room for student improvement while demonstrating competent baseline performance.

---

## 📝 Grading Calibration

Use this solution as **B+/A- reference**:

| Aspect | This Demo | A+ Work Would Add |
|--------|-----------|-------------------|
| Requirements | Clear, measurable | Hazard analysis, more standards |
| RTM | Complete traceability | Risk-based test prioritization |
| Controller | Stable, meets all reqs | Optimal tuning, advanced logic |
| Documentation | Structured, professional | Deeper analysis, sensitivity studies |
| Standards | Basic compliance | Multi-standard integration, trade-off analysis |

---

## 🔄 Maintenance

### Before each AY:
1. Re-run scenarios with current plant model
2. Verify all requirements still pass
3. Update metrics if thresholds changed
4. Regenerate plots if needed
5. Check ICD against project brief updates

### After plant model changes:
```
% Re-tune if necessary
edit instructor_controller.m  % Adjust gains
run_all_scenarios_demo();     % Re-verify
```

---

## 📚 Alignment with Course Materials

- **Project Brief:** Matches all requirements in Section 9.1
- **ICD:** Follows structure in Section 5
- **Logging Schema:** Uses exact format from Section 6
- **Metrics:** Implements all formulas from Section 7
- **Standards:**
  - VDI 2206: V-model structure, left-right pairing
  - ISO 26262: Safe-state (speed cap), controllability
  - ISO 14040/44: Energy proxy as use-phase metric

---

## 🔗 Related Files

- Main README: `../README.md` (root level)
- Student Guide: `../docs/DemoSteps.md`
- Project Brief: `../docs/Line-Follower-Project-Brief.md`
- ICD Schema: `../interfaces/ICD_linefollower.md`
- Log Schema: `../logging/log_schema.md`

---

## ⚠️ Security Reminder

This folder contains complete solutions including working controller code.

**Never:**
- Commit to main branch
- Share via email/LMS
- Show on screen during student labs
- Include in handouts

**Always:**
- Keep on demo-instructor-complete branch only
- Verify branch before screen sharing
- Use `git status` to confirm location

---

**Questions?** See `InstructorGuide.md` or contact asitha@uom.lk

---

_For instructor use only. MC3113 AY2025/26._
```

***

## Git Commands to Add These READMEs

```bash
# Make sure you're on the demo branch
cd /path/to/mc3113-line-follower-demo
git checkout demo-instructor-complete

# Create/update the root README
# (Copy the first README content above)
notepad README.md  # or nano/vim

# Create/update demo-solution README
# (Copy the second README content above)
notepad demo-solution/README.md

# Add and commit
git add README.md demo-solution/README.md
git commit -m "Add comprehensive README files for instructor demo branch"

# Push to remote
git push origin demo-instructor-complete
