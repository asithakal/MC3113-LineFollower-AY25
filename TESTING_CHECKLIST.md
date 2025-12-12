# MC3113 Branch Testing Checklist

## Pre-Testing Setup

```
cd D:\Documents\Work\Asitha\KDU\Mechatronics\2025_Nov\Demo\LineFollowerDemo
```

---

## Test 1: Main Branch (Student-Facing)

### Switch to Main
```
git checkout main
git status
```

### MATLAB Verification
```
cd 'D:\...\LineFollowerDemo'
addpath('src', 'scripts', 'metrics', 'testing');

% Run automated check
verify_branch()
```

### Expected Results
- [ ] Branch is `main`
- [ ] `demo-solution/` folder does NOT exist
- [ ] `src/my_controller_step.m` exists
- [ ] `instructor_controller.m` does NOT exist
- [ ] README.md is student-oriented
- [ ] All tests PASS

### Manual Checks
- [ ] README explains project for students
- [ ] No solution code visible
- [ ] Demo steps guide students through basics
- [ ] Project brief is complete

---

## Test 2: Demo Branch (Instructor Solution)

### Switch to Demo
```
git checkout demo-instructor-complete
git status
```

### MATLAB Verification
```
cd 'D:\...\LineFollowerDemo'
addpath('demo-solution', 'src', 'scripts', 'metrics', 'plotting', 'testing');

% Run automated check
verify_branch()
```

### Expected Results
- [ ] Branch is `demo-instructor-complete`
- [ ] `demo-solution/` folder EXISTS
- [ ] `instructor_controller.m` exists
- [ ] Plotting functions available
- [ ] All demo files present
- [ ] All tests PASS

### Functional Test
```
% Quick workflow test
quick_test_workflow()

% Full demo (takes ~30 sec)
run_all_scenarios_demo('simple')

% Check metrics
type metrics/Demo_metrics_simple.json

% Generate plots
generate_all_plots()
```

### Manual Checks
- [ ] InstructorGuide.md is comprehensive
- [ ] Controller runs without errors
- [ ] Metrics are computed correctly
- [ ] Plots generate successfully
- [ ] README explains demo branch purpose

---

## Test 3: Branch Comparison

```
% From either branch
compare_branches()
```

### Expected Results
- [ ] Common files exist on both branches
- [ ] Demo-only files ONLY on demo branch
- [ ] No instructor solution on main
- [ ] File structure consistent

---

## Test 4: Git Remote Security

### Check Remotes
```
git remote -v
```

### Expected Configuration
```
origin  https://github.com/asithakal/mc3113-line-follower-demo.git (PRIVATE)
student https://github.com/asithakal/MC3113-LineFollower-Student-AY25.git (PUBLIC/SHARED)
```

### Verify Privacy
- [ ] `origin` repo is PRIVATE
- [ ] `demo-instructor-complete` branch pushed to `origin` only
- [ ] `main` branch pushed to `student` repo
- [ ] Students cannot see demo branch

```
# Check what's pushed where
git branch -r
```

---

## Test 5: Student Repository

### Clone as Student Would
```
cd /tmp/test
git clone https://github.com/asithakal/MC3113-LineFollower-Student-AY25.git
cd MC3113-LineFollower-Student-AY25

# Check branches
git branch -a
```

### Expected Results
- [ ] Only `main` branch visible
- [ ] No `demo-instructor-complete` branch
- [ ] No `demo-solution/` folder
- [ ] README is student-friendly
- [ ] Getting started guide present

---

## Test 6: End-to-End Scenarios

### On Demo Branch
```
cd 'D:\...\LineFollowerDemo'
git checkout demo-instructor-complete
addpath('demo-solution', 'scripts', 'src', 'metrics', 'plotting');

% Test all fidelity levels
run_all_scenarios_demo('simple');    % ~5 sec
run_all_scenarios_demo('realistic'); % ~30 sec
run_all_scenarios_demo('hifi');      % ~60 sec

% Verify outputs
dir logging/Demo_*.csv
dir metrics/Demo_*.json

% Generate all plots
generate_all_plots();
dir plots/*.png
```

### Expected Results
- [ ] All 9 CSV files generated (3 scenarios × 3 fidelity)
- [ ] All 3 JSON metrics files generated
- [ ] All plots generated without errors
- [ ] No MATLAB errors or warnings

---

## Test 7: Documentation Complete

### Check All Docs Exist
```
# Common docs
ls README.md
ls docs/Line-Follower-Project-Brief.md
ls docs/DemoSteps.md

# Demo branch only
git checkout demo-instructor-complete
ls demo-solution/InstructorGuide.md
ls demo-solution/README.md
ls plotting/README.md
```

### Content Verification
- [ ] All READMEs have >500 characters
- [ ] Project brief is complete (~17KB)
- [ ] Instructor guide is detailed (~10KB+)
- [ ] No broken links or references

---

## Test 8: Clean Workspace

### Check for Leftover Files
```
% Check for temp files
dir logging/test*.csv
dir logging/temp*.csv

% Should be minimal or organized
```

### Cleanup if Needed
```
% Remove test files (keep Demo_* files)
delete('logging/test*.csv');
delete('logging/QuickTest*.csv');
```

---

## Final Checklist Summary

### Main Branch Ready for Students
- [ ] No solution code
- [ ] Clear documentation
- [ ] Template files present
- [ ] Can be cloned/shared safely

### Demo Branch Ready for Teaching
- [ ] Complete solution works
- [ ] All scenarios run
- [ ] Plots generate correctly
- [ ] Documentation complete

### Security Verified
- [ ] Demo branch is private
- [ ] Student repo has no solutions
- [ ] Git remotes configured correctly
- [ ] .gitignore protects sensitive files

---

## Troubleshooting

### If verify_branch() fails:
1. Check MATLAB path: `addpath('testing', 'src', 'scripts', 'metrics')`
2. Verify Git branch: `!git branch`
3. Check file permissions
4. Re-clone if corrupted

### If plots don't generate:
1. `addpath('plotting')`
2. Check CSV files exist: `dir logging/Demo_*.csv`
3. Check metrics files: `dir metrics/Demo_*.json`
4. Create plots/ folder: `mkdir plots`

### If controller errors:
1. Check controller file exists
2. Verify function signature
3. Test with dummy inputs
4. Check for persistent variable issues (clear all)

---

**Date Completed:** _______________  
**Tested By:** _______________  
**Status:** [ ] PASS  [ ] FAIL  
**Notes:** _______________________________________________
```

***

## Complete Testing Workflow

```bash
# === Terminal Commands ===

# 1. Test Main Branch
cd D:\Documents\Work\Asitha\KDU\Mechatronics\2025_Nov\Demo\LineFollowerDemo
git checkout main
git status
```

```matlab
% === MATLAB for Main Branch ===
cd 'D:\Documents\Work\Asitha\KDU\Mechatronics\2025_Nov\Demo\LineFollowerDemo'
addpath('testing', 'src', 'scripts', 'metrics');

% Run verification
results_main = verify_branch();

% Should show: "All tests PASSED - Branch is ready!"
```

```bash
# 2. Test Demo Branch
git checkout demo-instructor-complete
git status
```

```matlab
% === MATLAB for Demo Branch ===
addpath('demo-solution', 'plotting');

% Run verification
results_demo = verify_branch();

% Quick functional test
quick_test_workflow();

% Full test (optional, takes time)
run_all_scenarios_demo('simple');
generate_all_plots();
```

```matlab
% === Compare Branches ===
compare_branches();
% Shows differences and ensures security
```
