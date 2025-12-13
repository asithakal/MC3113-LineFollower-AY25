# Bronze Tier Quick Start Guide

## 🎯 Objective

Achieve Bronze tier performance (6/6 requirements) with a realistic, undergraduate-level line-follower controller.

## ✅ Bronze Tier Requirements

| ID | Requirement | Target | Your Result |
|----|-------------|--------|-------------|
| R-TIME-01 | S1 completion time | ≤ 90 s | _____ |
| R-IAE-01 | S1 tracking accuracy | ≤ 2.1 m·s | _____ |
| R-ENERGY-01 | S1 energy efficiency | ≤ 80 units | _____ |
| R-OBS-01 | S2 obstacle response | ≤ 15 contacts | _____ |
| R-CAP-01 | S3 speed cap | ≤ 0.45 m/s | _____ |
| R-FAULT-01 | S3 line loss | ≤ 5 s | _____ |

## 🚀 Quick Test

```
% Clear and test
clear all
clc

% Run all scenarios
run_all_scenarios_demo('realistic', 'tuned');

% Check Bronze tier
metrics = jsondecode(fileread('metrics/Demo_metrics_final.json'));

% Your results:
fprintf('S1 IAE: %.2f m·s (target: ≤2.1)\n', metrics.S1.IAE);
fprintf('S1 Energy: %.1f units (target: ≤80)\n', metrics.S1.energy_proxy);
fprintf('S2 Contacts: %d (target: ≤15)\n', metrics.S2.obstacle_contacts);
fprintf('S3 Speed cap: %.2f m/s (target: ≤0.45)\n', metrics.S3.max_v_fault);
```

## 📁 Key Files

- **Controller**: `demo-solution/instructor_controller.m`
- **Scenario**: `run_scenario.m` (disturbance = 0.12 m/s²)
- **Requirements**: `docs/Line-Follower-Project-Brief.md`
- **Implementation Notes**: `docs/Bronze-Tier-Implementation-Summary.md`

## 🎓 For Students

1. **Copy** `instructor_controller.m` to your workspace
2. **Study** the controller structure and comments
3. **Experiment** with gain tuning (Kp, Ki, Kd)
4. **Document** your tuning process and results
5. **Achieve** Bronze tier (6/6 requirements)

## 👨‍🏫 For Instructors

1. **Demonstrate** untuned vs tuned vs Bronze-compliant controllers
2. **Emphasize** difference between performance and safety
3. **Use** tier progression to teach advanced techniques
4. **Assess** based on evidence (logs, metrics, RTM)

## 📊 Tier Comparison

| Tier | S1 IAE | S2 Contacts | Techniques Required |
|------|--------|-------------|---------------------|
| **Bronze** | ≤ 2.1 m·s | ≤ 15 | PID tuning, reactive avoidance |
| Silver | ≤ 0.5 m·s | ≤ 3 | Predictive, adaptive control |
| Gold | ≤ 0.1 m·s | 0 | Optimal control, prediction |

## 🐛 Troubleshooting

**IAE too high (>2.1)**:
- Increase |Kp| slightly (try -2.65)
- Check integral anti-windup limit

**Too many obstacle contacts (>15)**:
- Verify disturbance = 0.12 in `run_scenario.m` line 80
- Check collision threshold = 0.02 in line 171
- Ensure obstacle reverse = -0.8 in controller

**Energy too high (>80)**:
- Reduce base_speed (try 0.36)
- Increase adaptive speed thresholds

## 📞 Support

See `docs/Bronze-Tier-Implementation-Summary.md` for detailed teaching notes and student FAQs.

---

**Status**: ✓ Bronze Tier Validated (6/6 requirements)  
**Date**: December 2025  
**Ready for**: Week 3 demonstration and student use
