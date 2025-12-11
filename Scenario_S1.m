function [log, metrics] = Scenario_S1()
%% Scenario_S1 - Nominal Line Following Test
% MC3113 Mechatronic Systems Design
%
% PURPOSE: Simulate nominal (no faults, no obstacles) line following
%
% TESTS: R-TIME, R-TRACKING, R-IAE, R-ENERGY
%
% SCENARIO DEFINITION:
% - Duration: 40 seconds
% - No sensor faults (fault_flag = 0 throughout)
% - No obstacles
% - Line profile: simple sinusoidal lateral offset (simulates gentle curves)
% - Expected: All nominal performance requirements should PASS

dt = 0.01;  % 100 Hz control rate (matches ICD specification)
t_end = 40;
log.t = 0:dt:t_end;
N = length(log.t);

%% SIMULATED LINE ERROR (e_line)
% In a real digital twin, this would come from plant kinematics + sensor model
% Here we use a simple sinusoid to represent gentle track curvature
% Fail scenario
log.e_line = 0.02 * sin(2*pi*0.1*log.t);  % +/- 2 cm oscillation, 10 s period

% Pass scenario
% log.e_line = 0.01 * sin(2*pi*0.1*log.t);  % Reduce amplitude to 1 cm

%% SIMULATED VELOCITY
% Nominal speed chosen to balance R-TIME (completion) with R-IAE (accuracy)
log.v = 0.3 * ones(size(log.t));  % 0.3 m/s constant

%% SIMULATED MOTOR COMMANDS
% In a real simulation, u_L and u_R would come from PID controller
% Here we use constant forward drive for simplicity
log.u_L = 0.3 * ones(size(log.t));
log.u_R = 0.3 * ones(size(log.t));

%% SENSOR READINGS (for completeness, not used in this simple demo)
log.sensor = ones(N, 5) * 0.5;  % All sensors read 0.5 (nominal)

%% ===================================================================
%% COMPUTE METRICS (from RTM acceptance criteria)
%% ===================================================================

% METRIC 1: Completion Time (R-TIME)
% How long to complete a 5 m track?
% At v = 0.3 m/s constant, 5 m takes approximately 5/0.3 = 16.7 s
% But with tracking error and deceleration for curves, we use 35 s here
metrics.completion_time = 35;  % seconds

% METRIC 2: Max Line Error (R-TRACKING)
metrics.max_line_error = max(abs(log.e_line));

% METRIC 3: IAE - Integrated Absolute Error (R-IAE)
% IAE = sum(|e_line(t)| * dt) over the entire mission
% Lower IAE = better tracking quality
metrics.IAE = sum(abs(log.e_line)) * dt;

% METRIC 4: Energy Proxy (R-ENERGY)
% Energy = sum((|u_L| + |u_R|) * dt)
% This is a proxy for battery consumption
metrics.energy_proxy = sum(abs(log.u_L) + abs(log.u_R)) * dt;

%% ===================================================================
%% PASS/FAIL CHECKS (against RTM acceptance criteria)
%% ===================================================================

metrics.pass_R_TIME = (metrics.completion_time <= 45);  % Must be <= 45 s
metrics.pass_R_TRACKING = (metrics.max_line_error <= 0.05);  % Must be <= 5 cm
metrics.pass_R_IAE = (metrics.IAE <= 0.5);  % Must be <= 0.5 m*s
metrics.pass_R_ENERGY = (metrics.energy_proxy <= 20);  % Must be <= 20 units

%% Display results
fprintf('=== SCENARIO S1 (Nominal) RESULTS ===\n');
fprintf('  Completion Time: %0.1f s [Criterion: <= 45 s] --> %s\n', ...
    metrics.completion_time, passfail_str(metrics.pass_R_TIME));
fprintf('  Max Line Error: %0.3f m [Criterion: <= 0.05 m] --> %s\n', ...
    metrics.max_line_error, passfail_str(metrics.pass_R_TRACKING));
fprintf('  IAE: %0.2f m*s [Criterion: <= 0.5 m*s] --> %s\n', ...
    metrics.IAE, passfail_str(metrics.pass_R_IAE));
fprintf('  Energy: %0.1f units [Criterion: <= 20] --> %s\n', ...
    metrics.energy_proxy, passfail_str(metrics.pass_R_ENERGY));
fprintf('\n');

if all([metrics.pass_R_TIME, metrics.pass_R_TRACKING, metrics.pass_R_IAE, metrics.pass_R_ENERGY])
    disp('  STATUS: All S1 requirements VERIFIED');
else
    disp('  STATUS: Some S1 requirements FAILED');
end

end

function str = passfail_str(flag)
    if flag
        str = 'PASS';
    else
        str = 'FAIL';
    end
end
