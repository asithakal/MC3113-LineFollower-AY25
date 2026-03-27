function result = oracle(log, tc)
% ORACLE  Evaluate one test case against CUT output and return a verdict.
%
% INPUTS
%   log : table — CUT output log. Required columns:
%           t             — time vector (s)
%           setpoint_degC — stimulus setpoint profile
%           t_amb_degC    — ambient temperature (°C)
%           chamber_temp  — CUT output (from execute_test)
%   tc  : table row — one row from load_test_cases output
%
% OUTPUT
%   result : struct with fields:
%     test_id   — string, from tc.test_id
%     metric    — string, metric name
%     measured  — double, computed metric value
%     threshold — double, from tc.threshold
%     operator  — string, from tc.operator
%     verdict   — string, 'PASS' or 'FAIL'
%     margin    — double, threshold − measured  (positive = headroom)

% ── Extract columns from log ──────────────────────────────────────────
t            = log.t;
setpoint     = log.setpoint_degC;
chamber_temp = log.chamber_temp;
t_amb        = log.t_amb_degC(1);

% ── Compute the metric ────────────────────────────────────────────────
metric = char(tc.metric);

switch metric

    case 'rise_time_10_90'
        % Step response: time for chamber_temp to rise from 10% to 90%
        % of the full step magnitude.
        step_mag = setpoint(end) - t_amb;   % total step size in °C
        T_10     = t_amb + 0.10 * step_mag; % 10% threshold
        T_90     = t_amb + 0.90 * step_mag; % 90% threshold

        % ── TODO 3a — find the first time chamber_temp crosses T_10 and T_90
        % Use: idx = find(chamber_temp >= T_val, 1, 'first')
        % If idx is empty, the crossing was never reached — set measured = Inf
        % >>> YOUR CODE HERE <<<
        measured = Inf; % replace this line

    case 'ss_error_last20s'
        % Steady-state error: mean absolute error over the last 20 seconds.
        t_end  = t(end);
        window = t >= (t_end - 20.0);   % PROVIDED — time-anchored window

        % ── TODO 3b — compute mean absolute error over the window ─────
        % Hint: mean( abs( setpoint(window) - chamber_temp(window) ) )
        % >>> YOUR CODE HERE <<<
        measured = 0; % replace this line

    case 'max_heater_above_85'
        % Safety fraction: proportion of timesteps where chamber_temp > 85°C.

        % ── TODO 3c — compute fraction of samples above 85°C ──────────
        % Hint: sum(chamber_temp > 85) / length(chamber_temp)
        % >>> YOUR CODE HERE <<<
        measured = 0; % replace this line

    case 'ramp_tracking_lag'
        % Ramp following error: mean absolute error over the full run.

        % ── TODO 3d — compute mean absolute error over the full run ───
        % Hint: mean( abs( setpoint - chamber_temp ) )
        % >>> YOUR CODE HERE <<<
        measured = 0; % replace this line

    otherwise
        error('MC3113:UnknownMetric', 'Unknown metric: %s', metric);
end

% ── Evaluate verdict ─────────────────────────────────────────────────
% PROVIDED — operator dispatch. Do NOT modify.
op = char(tc.operator);
switch op
    case '<='
        pass = measured <= tc.threshold;
    case '>='
        pass = measured >= tc.threshold;
    case '<'
        pass = measured <  tc.threshold;
    case '>'
        pass = measured >  tc.threshold;
    case '=='
        pass = measured == tc.threshold;
    otherwise
        error('MC3113:UnknownOperator', 'Unknown operator: %s', op);
end

if pass
    verdict = 'PASS';
else
    verdict = 'FAIL';
end

% ── Assemble result struct ────────────────────────────────────────────
% PROVIDED — do NOT modify.
result.test_id   = char(tc.test_id);
result.metric    = metric;
result.measured  = measured;
result.threshold = tc.threshold;
result.operator  = op;
result.verdict   = verdict;
result.margin    = tc.threshold - measured;  % positive = headroom

end