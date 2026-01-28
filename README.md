# MC3113 Line-Follower Demo - Student Release

**Course:** MC3113 Mechatronic Systems Design  
**Institution:** General Sir John Kotelawala Defence University  
**Academic Year:** 2025/26  
**Version:** AY25-Student-v1.0

---

## 📚 Overview

This repository provides the **simulation framework** for the MC3113 Line-Follower project. You will develop your own controller to meet specified requirements across three scenarios.

---

## 🎯 Project Objectives

1. Understand system requirements and interface control
2. Design and implement a line-following controller
3. Validate performance through simulation
4. Document your design process following MBSE principles

---

## 📁 Repository Structure

```
MC3113-LineFollower-AY25/
├── README.md                    ← This file
├── docs/                        ← Project documentation
│   ├── Line-Follower-Project-Brief.md
│   └── Student_Quick_Start.md
├── src/                         ← Your controller goes here
│   ├── my_controller_step.m    ← EDIT THIS FILE
│   ├── DemoMain.m              ← Main simulation entry
│   └── Scenario_*.m            ← Scenario definitions
├── config/                      ← Plant and scenario configurations
├── interfaces/                  ← ICD templates
├── logging/                     ← Your simulation logs
├── metrics/                     ← Performance metric computation
├── plotting/                    ← Visualization scripts
└── scripts/                     ← Helper scripts
```

---

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/asithakal/MC3113-LineFollower-AY25.git
cd MC3113-LineFollower-AY25
```

### 2. Open MATLAB
```matlab
% Add all folders to path
addpath(genpath(pwd));

% Run the demo
DemoMain();
```

### 3. Edit Your Controller
Open `src/my_controller_step.m` and implement your control logic.

---

## 📖 Getting Started

**Read these in order:**
1. **`docs/Student_Quick_Start.md`** — Setup and first run
2. **`docs/Line-Follower-Project-Brief.md`** — Full project requirements
3. **`interfaces/ICD_template.md`** — Interface control document

---

## 🧪 Running Scenarios

### Scenario S1: Basic Line Following
```matlab
run_scenario('S1', @my_controller_step, 'MyRun_S1');
```

### View Results
```matlab
% Load your log
data = readtable('logging/MyRun_S1.csv');

% Compute metrics
metrics = compute_metrics('logging/MyRun_S1.csv', 'S1');
disp(metrics);
```

---

## 📊 Performance Requirements

Your controller must meet these requirements (see Project Brief for details):

| Requirement | Metric | Target |
|-------------|--------|--------|
| **R-TIME-01** | Completion time | ≤ 75 s |
| **R-IAE-01** | Tracking error | ≤ 0.025 m·s |
| **R-ENERGY-01** | Energy consumption | ≤ 60 units |

---

## 🛠️ Development Workflow

1. **Design:** Plan your controller structure (P, PI, PID, etc.)
2. **Implement:** Edit `src/my_controller_step.m`
3. **Test:** Run scenarios and check logs
4. **Analyze:** Compute metrics, review plots
5. **Iterate:** Tune parameters, re-test
6. **Document:** Update your ICD and RTM

---

## 📝 Deliverables

- Controller implementation (`my_controller_step.m`)
- Completed ICD (from template)
- Requirements Traceability Matrix (RTM)
- Verification report with test logs
- Performance analysis plots

---

## ⚠️ Academic Integrity

- All controller code must be your own original work
- You may discuss concepts with peers, but not share code
- Document all references and external sources
- Plagiarism will result in disciplinary action

---

## 🆘 Support

- **Issues:** Use GitHub Issues tab
- **Office Hours:** See course schedule
- **Email:** asitha@uom.lk

---

## 📅 Important Dates

- **Week 6:** First simulation demonstration
- **Week 9:** Preliminary Design Review (PDR)
- **Week 12:** Critical Design Review (CDR)

---

**Good luck with your design!** 🚀
```

***

#### **C. Add `.gitignore` Protection**

Update `.gitignore` to prevent accidental solution commits:

```gitignore
# Instructor-only content
demo-solution/
*instructor*.m
*solution*.m
*complete*.m
InstructorGuide.*
Demo_metrics_summary.json

# Student working files
*_backup.m
*_old.m
scratch/
temp/

# MATLAB artifacts
*.asv
*.mat
slprj/
*.autosave

# Logs (keep structure, not data)
logging/*.csv
!logging/README.md

# Generated plots
plots/*.png
plots/*.jpg
!plots/README.md

# OS files
.DS_Store
Thumbs.db
```

***

#### **D. Create Student-Appropriate Guides**

Add to `docs/` folder:

**`docs/DemoSteps.md`** (Student version):
```markdown
# Line-Follower Demo — Student Guide

## Overview
This guide walks you through running your first simulation of the line-follower system.

## Prerequisites
- MATLAB R2020a or later
- Repository cloned and path configured

## Step 1: Understand the Plant Configuration

The line-follower plant is configured in `config/plant_config.yaml`:

```yaml
# Key parameters (DO NOT MODIFY for CA1/CA2)
wheelbase: 0.15    # meters
max_speed: 0.60    # m/s
motor_time_constant: 0.05  # seconds
sensor_noise: 0.002  # meters
```

## Step 2: Review the Interface Control Document (ICD)

Open `interfaces/ICD_template.md` and read:
- **Controller Input:** What data your controller receives
- **Controller Output:** What commands you must produce
- **Timing:** Sample rate (50 Hz = 0.02s)

Key ICD structure:
```matlab
function [u_L, u_R] = my_controller_step(plant_state, scenario_info)
    % Inputs:
    %   plant_state.e_line   - Lateral error (meters)
    %   plant_state.v        - Forward velocity (m/s)
    %   plant_state.theta_e  - Heading error (radians)
    %   plant_state.t        - Simulation time (seconds)
    %
    % Outputs:
    %   u_L - Left motor command [-1, +1]
    %   u_R - Right motor command [-1, +1]
    
    % YOUR CONTROL LOGIC HERE
end
```

## Step 3: Run Scenario S1 (Straight Line)

### Using the Main Script
```matlab
% From MATLAB command window
cd 'path/to/MC3113-LineFollower-AY25'
addpath(genpath(pwd));
DemoMain();
```

### Using Scenario Runner Directly
```matlab
% Run S1 with your controller
run_scenario('S1', @my_controller_step, 'Test_S1_v1');
```

### What You'll See
- Real-time plot of lateral error `e_line`
- Console output showing time steps
- Final metrics summary

## Step 4: Examine the Log File

Your simulation generates `logging/Test_S1_v1.csv`:

```csv
t,x,y,theta,e_line,v,u_L,u_R,scenario
0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,S1
0.02,0.00,0.00,0.00,0.01,0.05,0.30,0.30,S1
...
```

**Key columns:**
- `t`: Time (seconds)
- `e_line`: Lateral tracking error (meters)
- `v`: Forward velocity (m/s)
- `u_L`, `u_R`: Your controller commands

## Step 5: Compute Performance Metrics

```matlab
% Load metrics computation
metrics_S1 = compute_metrics('logging/Test_S1_v1.csv', 'S1');

% Display results
fprintf('Completion Time: %.2f s\n', metrics_S1.t_final);
fprintf('IAE (tracking):  %.4f m·s\n', metrics_S1.IAE);
fprintf('Energy:          %.2f units\n', metrics_S1.energy);
fprintf('Line Loss:       %d events\n', metrics_S1.line_loss_count);
```

**Target values (Requirements):**
- Time: ≤ 75 s
- IAE: ≤ 0.025 m·s
- Energy: ≤ 60 units
- Line Loss: 0 events

## Step 6: Visualize Results

```matlab
% Plot trajectories
plot_scenario_results('logging/Test_S1_v1.csv', 'S1');

% Compare multiple runs
plot_controller_comparison({'Test_S1_v1.csv', 'Test_S1_v2.csv'}, ...
                           {'Version 1', 'Version 2'});
```

---

## Next Steps for CA1

1. **Baseline controller:** Start with simple proportional control
   ```matlab
   Kp = 2.0;  % Tune this value
   u_steer = -Kp * e_line;
   u_L = u_base - u_steer;
   u_R = u_base + u_steer;
   ```

2. **Iterative tuning:** Adjust `Kp` until S1 requirements met

3. **Document:** Update your ICD with final parameter values

4. **Validate:** Run 3 times, ensure consistency

---

## Troubleshooting

### Issue: "Undefined function 'run_scenario'"
**Solution:** Ensure all folders are on MATLAB path
```matlab
addpath(genpath(pwd));
```

### Issue: Controller diverges (e_line → ∞)
**Solution:** Reduce gain values, add saturation
```matlab
u_steer = max(min(-Kp * e_line, 0.5), -0.5);
```

### Issue: Log file not generated
**Solution:** Check write permissions in `logging/` folder

---

## Academic Integrity Reminder

- Implement your own controller logic
- Do not copy code from peers
- Document all sources and references
- Seek help from instructors if stuck

---

**For detailed requirements, see `docs/Line-Follower-Project-Brief.md`**