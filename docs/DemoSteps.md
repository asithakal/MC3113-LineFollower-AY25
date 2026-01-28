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