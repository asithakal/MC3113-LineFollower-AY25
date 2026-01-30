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
├── LICENSE                      ← MIT License with Academic Integrity Notice
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

## 📚 Documentation

- **[Performance Tier Guide](docs/Performance-Tier-Guide.md)** - Understand performance expectations and development pathway
- **[Quick Start Guide](docs/Student_Quick_Start.md)** - Get started in 5 minutes
- **[Demo Steps](docs/DemoSteps.md)** - Step-by-step tutorial
- **[Project Brief](docs/Line-Follower-Project-Brief.md)** - Full requirements and specifications

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

## 📄 License

This project is licensed under the MIT License with Academic Integrity Notice - see the [LICENSE](LICENSE) file for details.

**Note for Students:** While this code is open source, your controller implementation must be your own original work. Sharing solutions with other students violates academic integrity policies and will result in disciplinary action.

---

**Good luck with your design!** 🚀