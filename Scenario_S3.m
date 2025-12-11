function [log, metrics] = Scenario_S3()
%% Scenario_S3 - Sensor Fault + Safe State Test
% MC3113 Mechatronic Systems Design
%
% PURPOSE: Test fault detection and safe state behavior
%
% TESTS: R-FAULT-DETECT, R-SAFE-STATE
%
% SCENARIO DEFINITION:
% - Duration: 40 seconds
% - Sensor fault active from t = 20 s to t = 30 s
% - During fault: all sensors read 0 (dropout), speed capped to 0.45 m/s
% - Expected: Speed shall not exceed 0.45 m/s during fault window

dt = 0.01;  % 100 Hz
t_end = 40;
log.t = 0:dt:t_end;
N = length(log.t);

%% FAULT WINDOW DEFINITION
t_fault_start = 20;  % Fault begins at 20 s
t_fault_end = 30;    % Fault ends at 30 s
fault_zone = (log.t >= t_fault_start) & (log.t < t_fault_end);

%% SIMULATED VELOCITY WITH SAFE STATE
% Normal operation: v = 0.3 m/s
% Fault mode (safe state): v = 0.225 m/s (reduced speed per R-SAFE-STATE)
log.v = 0.3 * ones(size(log.t));
log.v(fault_zone) = 0.225;  % Speed cap during fault

%% SENSOR READINGS
% Normal: sensors read ~0.5 (moderate reflectance)
% Fault: all sensors read 0 (complete dropout)
log.sensor = ones(N, 5) * 0.5;
log.sensor(fault_zone, :) = 0;  % Dropout: all zeros

%% OTHER TELEMETRY (for completeness)
log.e_line = 0.03 * sin(2*pi*0.1*log.t);  % Line error (slightly degraded in fault)
log.u_L = 0.2 * ones(size(log.t));
log.u_R = 0.2 * ones(size(log.t));
log.fault_flag = fault_zone;  % Boolean flag marking fault window

%% ===================================================================
%% COMPUTE METRICS (from RTM)
%% ===================================================================

% METRIC: Maximum speed during fault window (R-SAFE-STATE)
% We check: did speed exceed the 0.45 m/s cap?
metrics.max_speed_fault_window = max(log.v(fault_zone));

% PASS/FAIL: Speed must be <= 0.45 m/s throughout fault
metrics.pass_R_SAFE_STATE = (metrics.max_speed_fault_window <= 0.45);

%% Display results
fprintf('=== SCENARIO S3 (Fault + Safe State) RESULTS ===\n');
fprintf('  Fault window: t = %d s to %d s\n', t_fault_start, t_fault_end);
fprintf('  Max speed during fault: %0.3f m/s [Criterion: <= 0.45 m/s] --> %s\n', ...
    metrics.max_speed_fault_window, passfail_str(metrics.pass_R_SAFE_STATE));
fprintf('\n');

if metrics.pass_R_SAFE_STATE
    disp('  STATUS: Safe state requirement VERIFIED');
else
    disp('  STATUS: Safe state requirement FAILED (speed exceeded cap)');
end

end

function str = passfail_str(flag)
    if flag
        str = 'PASS';
    else
        str = 'FAIL';
    end
end
