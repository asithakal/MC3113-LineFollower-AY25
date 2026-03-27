function log = execute_test(log)
% EXECUTE_TEST  Run the sealed thermal controller CUT on a prepared log slice.
%
%   log = execute_test(log)
%
%   Runs thermal_controller.p step-by-step over the log's time vector,
%   feeding setpoint and ambient temperature from the log table at each step.
%   Appends three output columns to the log table:
%     .chamber_temp  (double) — simulated chamber temperature °C
%     .heater_cmd    (double) — heater command signal [0, 1]
%     .cooler_cmd    (double) — cooler command signal [0, 1]
%
%   INPUTS
%     log : table — one run slice from decoded.csv, already stimulus-corrected.
%                   Required columns:
%                     t              — time vector (seconds)
%                     setpoint_degC  — setpoint profile (from stimulus_engine)
%                     t_amb_degC     — ambient temperature (°C)
%
%   OUTPUT
%     log : same table with three columns appended (chamber_temp, heater_cmd,
%           cooler_cmd). Original columns are preserved unchanged.
%
%   ERRORS (named, catchable)
%     MC3113:MissingColumnError  — required input column absent
%     MC3113:CUTNotFoundError    — thermal_controller.p not on MATLAB path
%     MC3113:CUTRuntimeError     — thermal_controller threw an error mid-run

    % ── Validate required columns ─────────────────────────────────────────
    required_cols = {'t', 'setpoint_degC', 't_amb_degC'};
    for c = required_cols
        if ~ismember(c{1}, log.Properties.VariableNames)
            error('MC3113:MissingColumnError', ...
                  'execute_test: log is missing required column "%s".', c{1});
        end
    end

    % ── Check CUT is available ────────────────────────────────────────────
    if ~(exist('thermal_controller', 'file') == 6 || ...   % .p file
         exist('thermal_controller', 'file') == 2)          % .m file
        error('MC3113:CUTNotFoundError', ...
              'thermal_controller.p not found. Add its folder to the MATLAB path.');
    end

    % ── Extract time series ───────────────────────────────────────────────
    N          = height(log);
    t          = log.t;
    setpoints  = log.setpoint_degC;
    amb_temps  = log.t_amb_degC;

    % Infer dt from time vector (median of diffs — robust to missing frames)
    if N > 1
        dt = median(diff(t));
    else
        dt = 0.1;
    end

    % ── Pre-allocate output arrays ────────────────────────────────────────
    chamber_temp = zeros(N, 1);
    heater_cmd   = zeros(N, 1);
    cooler_cmd   = zeros(N, 1);

    % ── Step CUT through the log ──────────────────────────────────────────
    state = [];   % initialise CUT state — opaque, passed back each step

    for k = 1:N
        inputs.setpoint     = setpoints(k);
        inputs.ambient_temp = amb_temps(k);
        inputs.dt           = dt;

        try
            [out, state] = thermal_controller(inputs, state);
        catch ME
            error('MC3113:CUTRuntimeError', ...
                  'thermal_controller error at step %d (t=%.2f s): %s', ...
                  k, t(k), ME.message);
        end

        chamber_temp(k) = out.chamber_temp;
        heater_cmd(k)   = out.heater_cmd;
        cooler_cmd(k)   = out.cooler_cmd;
    end

    % ── Append output columns to log ─────────────────────────────────────
    log.chamber_temp = chamber_temp;
    log.heater_cmd   = heater_cmd;
    log.cooler_cmd   = cooler_cmd;

end