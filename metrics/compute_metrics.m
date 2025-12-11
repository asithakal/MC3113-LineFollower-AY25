function metrics = compute_metrics(csvFile, scenarioId)
% COMPUTE_METRICS  Compute key performance metrics from a log file.
%
%   metrics = compute_metrics('logging/MC3113_AY25_Team01_S1_001.csv','S1')
%
% Inputs:
%   csvFile   - path to a CSV log file (see log_schema.md)
%   scenarioId- 'S1', 'S2', or 'S3'
%
% Output:
%   metrics   - struct with fields:
%               run_id, scenario, t_final,
%               IAE, energy_proxy, finished,
%               obstacle_contacts (S2),
%               max_v_fault, speed_cap_ok (S3),
%               line_loss_events

    if nargin < 2
        error('Usage: metrics = compute_metrics(csvFile, scenarioId)');
    end

    T = readtable(csvFile);

    % Basic properties
    metrics.run_id   = string(T.run_id(1));
    metrics.scenario = string(scenarioId);

    t = T.t;
    dt = mean(diff(t));  % assume roughly constant sample time

    % Finish time (last timestamp)
    metrics.t_final = t(end);

    % Simple "finished" heuristic:
    % Use track.finish_y_m from config, or fallback to last y.
    metrics.finished = true;  % refine as needed

    % IAE: integral of absolute e_line
    e_line = T.e_line;
    metrics.IAE = sum(abs(e_line)) * dt;

    % Energy proxy: integral(|u_L| + |u_R|)
    uL = T.u_L;
    uR = T.u_R;
    metrics.energy_proxy = sum(abs(uL) + abs(uR)) * dt;

    % Line-loss events: count segments where line_loss_flag is 1 for >= 1 s
    lineLoss = T.line_loss_flag ~= 0;
    windowLen = round(1.0 / dt); % 1 second in samples
    if windowLen < 1
        windowLen = 1;
    end
    % Simple approach: count how many times a 1-second window is fully "lost"
    rollingSum = movsum(lineLoss, [windowLen-1 0]);
    metrics.line_loss_events = sum(rollingSum == windowLen);

    % Scenario-specific metrics
    metrics.obstacle_contacts = 0;
    metrics.max_v_fault       = NaN;
    metrics.speed_cap_ok      = true;

    switch upper(string(scenarioId))
        case "S2"
            % Interpret safety_violation == 1 as obstacle contact
            metrics.obstacle_contacts = sum(T.safety_violation == 1);

        case "S3"
            % Speed cap check during fault window:
            % The cap value should match scenarios.yaml
            v_cap = 0.45;
            isFault = T.fault_flag ~= 0;
            if any(isFault)
                v_fault = T.v(isFault);
                metrics.max_v_fault  = max(v_fault);
                metrics.speed_cap_ok = metrics.max_v_fault <= v_cap + 1e-6;
            else
                metrics.max_v_fault  = NaN;
                metrics.speed_cap_ok = true;
            end
    end
end
