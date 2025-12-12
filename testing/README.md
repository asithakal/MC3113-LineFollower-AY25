# MC3113 Testing Suite

Branch verification and testing tools for MC3113 line-follower project.

## Purpose

This testing suite works on **both main and demo branches** to verify:
- Correct branch structure
- File integrity
- Function availability
- Security (no solution leaks on main)

## Quick Start

```
% Add to path
addpath('testing');

% Run verification
verify_branch();
```

## Available Tests

### 1. `verify_branch()`
Automated verification of current branch:
- Git branch detection
- Directory structure
- File existence
- Function availability
- Security checks

### 2. `compare_branches()`
Compare main vs demo branch:
- Common files
- Demo-only files
- Security audit

### 3. `quick_test_workflow()`
Quick end-to-end test:
- Run simulation
- Compute metrics
- Generate plots (demo only)

## Usage by Branch

### On Main Branch
```
cd '/path/to/LineFollowerDemo'
addpath('testing', 'src', 'scripts', 'metrics');
verify_branch();
```

Checks:
- Student template exists
- No solution files
- Documentation complete

### On Demo Branch
```
cd '/path/to/LineFollowerDemo'
addpath('testing', 'demo-solution', 'scripts', 'metrics', 'plotting');
verify_branch();
quick_test_workflow();
```

Checks:
- Instructor solution works
- All demo files present
- Plotting functions available

## Maintenance

Update testing suite on main branch first, then merge to demo:

```
git checkout main
# ... edit testing files ...
git add testing/
git commit -m "Update testing"
git push origin main

git checkout demo-instructor-complete
git merge main
git push origin demo-instructor-complete
```

---

**For questions:** asitha@uom.lk
```

***

## Summary: Where to Set Up Testing

| Aspect | Answer |
|--------|--------|
| **Which branch first?** | Main branch |
| **Available on which branches?** | Both main AND demo |
| **Safe for students?** | Yes - testing doesn't contain solutions |
| **How to maintain?** | Update on main, merge to demo |
| **Location** | `testing/` folder at repo root |

## Action Items (Do This Now)

1. **Switch to main branch**
   ```bash
   git checkout main
   mkdir testing
   ```

2. **Copy 3 .m files into testing/**
   - `verify_branch.m`
   - `compare_branches.m`
   - `quick_test_workflow.m`
   - `README.md`

3. **Commit on main**
   ```bash
   git add testing/
   git commit -m "Add testing and verification suite"
   git push origin main
   ```

4. **Merge to demo**
   ```bash
   git checkout demo-instructor-complete
   git merge main
   git push origin demo-instructor-complete
   ```

5. **Test both branches**
   ```matlab
   % From each branch:
   verify_branch()
   ```
