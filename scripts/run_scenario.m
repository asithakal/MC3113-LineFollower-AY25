function run_scenario(scenarioId, controllerFcn, runId)
% RUN_SCENARIO  Execute a line-follower scenario and log results.
%
%   run_scenario('S1', @my_controller_step, 'MC3113_AY25_Team01_S1_001')
%
% This is a template. You must connect it to your plant model and
% implement the functions:
%   - load_plant_params()
%   - load_scenarios()
%   - step_plant()
%
% Inputs:
%   scenarioId   - 'S1', 'S2', or 'S3'
%   controllerFcn- handle to controller function:
%                  [u_L, u_R] = controllerFcn(inputsStruct)
%   runId        - string run identifier for log file naming

    if nargin < 2
        error('Usage: run_scenario(scenarioId, controllerFcn, runId)');
    end
    if nargin < 3 || isempty(runId)
        runId = sprintf('TEMP_%s_%03d', scenarioId, randi(999));
    end

    % --- Load configs (you will need YAML reader or equivalent) ---
    % For now, we assume dt = 0.01 and duration from scenarios.yaml is
    % manually mirrored here or you add parsing later.
    dt = 0.01;
    switch upper(string(scenarioId))
        case "S1"
            duration_s = 90;
        case "S2"
            duration_s = 120;
        case "S3"
            duration_s = 150;
        otherwise
            error('Unknown scenarioId: %s', scenarioId);
    end
    N = round(duration_s / dt);

    % --- Preallocate log arrays ---
    run_id       = strings(N, 1);
    scenario_col = strings(N, 1);
    t            = zeros(N, 1);
    x            = zeros(N, 1);
    y            = zeros(N, 1);
    theta        = zeros(N, 1);
    v            = zeros(N, 1);
    omega        = zeros(N, 1);
    e_line       = zeros(N, 1);
    line_loss    = zeros(N, 1);
    sensor_1     = zeros(N, 1);
    sensor_2     = zeros(N, 1);
    sensor_3     = zeros(N, 1);
    sensor_4     = zeros(N, 1);
    sensor_5     = zeros(N, 1);
    obstacle_f   = zeros(N, 1);
    fault_f      = zeros(N, 1);
    u_L_log      = zeros(N, 1);
    u_R_log      = zeros(N, 1);
    sat_L        = zeros(N, 1);
    sat_R        = zeros(N, 1);
    safety_violation = zeros(N, 1);
    notes        = strings(N, 1);

    % --- Initial state (simple placeholder) ---
    xk = 0; yk = 0; thetak = 0;
    vk = 0; omegak = 0;
    sensor = [0.1 0.2 0.8 0.2 0.1]'; % dummy initial values
    e_line_k = 0;

    % Main simulation loop
    for k = 1:N
        tk = (k-1) * dt;

        % Scenario flags (very simple placeholders)
        obstacle_flag = 0;
        fault_flag    = 0;
        if scenarioId == "S2"
            if tk >= 12.0 && tk <= 12.0 + 0.25 % naive condition
                obstacle_flag = 1;
            end
        end
        if scenarioId == "S3"
            if tk >= 20.0 && tk <= 30.0
                fault_flag = 1;
            end
        end

        % Build controller input struct
        inputs = struct();
        inputs.sensor        = sensor;
        inputs.e_line        = e_line_k;
        inputs.v             = vk;
        inputs.omega         = omegak;
        inputs.obstacle_flag = obstacle_flag;
        inputs.fault_flag    = fault_flag;

        % Controller call
        [u_L, u_R] = controllerFcn(inputs);

        % Saturation
        u_L = max(min(u_L, 1.0), -1.0);
        u_R = max(min(u_R, 1.0), -1.0);

        % --- Plant step (replace this with call to your plant model) ---
        % Here we just keep state constant for template purposes.
        % You should update:
        %   xk, yk, thetak, vk, omegak, sensor, e_line_k, line_loss_flag,
        %   sat_flag_L, sat_flag_R, safety_violation_flag

        line_loss_flag       = 0;
        sat_flag_L           = 0;
        sat_flag_R           = 0;
        safety_violation_flag= 0;

        % --- Log data ---
        run_id(k)       = string(runId);
        scenario_col(k) = string(scenarioId);
        t(k)            = tk;
        x(k)            = xk;
        y(k)            = yk;
        theta(k)        = thetak;
        v(k)            = vk;
        omega(k)        = omegak;
        e_line(k)       = e_line_k;
        line_loss(k)    = line_loss_flag;
        sensor_1(k)     = sensor(1);
        sensor_2(k)     = sensor(2);
        sensor_3(k)     = sensor(3);
        sensor_4(k)     = sensor(4);
        sensor_5(k)     = sensor(5);
        obstacle_f(k)   = obstacle_flag;
        fault_f(k)      = fault_flag;
        u_L_log(k)      = u_L;
        u_R_log(k)      = u_R;
        sat_L(k)        = sat_flag_L;
        sat_R(k)        = sat_flag_R;
        safety_violation(k) = safety_violation_flag;
        notes(k)        = "";
    end

    % --- Build table and write CSV ---
    T = table(run_id, scenario_col, t, x, y, theta, v, omega, ...
              e_line, line_loss, ...
              sensor_1, sensor_2, sensor_3, sensor_4, sensor_5, ...
              obstacle_f, fault_f, ...
              u_L_log, u_R_log, ...
              sat_L, sat_R, ...
              safety_violation, notes, ...
              'VariableNames', { ...
                'run_id','scenario_id','t','x','y','theta','v','omega', ...
                'e_line','line_loss_flag', ...
                'sensor_1','sensor_2','sensor_3','sensor_4','sensor_5', ...
                'obstacle_flag','fault_flag', ...
                'u_L','u_R', ...
                'sat_flag_L','sat_flag_R', ...
                'safety_violation','notes'});

    if ~exist('../logging','dir') && ~exist('logging','dir')
        mkdir('logging');
        outDir = 'logging';
    else
        if exist('logging','dir')
            outDir = 'logging';
        else
            outDir = '../logging';
        end
    end

    outFile = fullfile(outDir, sprintf('%s.csv', runId));
    writetable(T, outFile);
    fprintf('Saved log to %s\n', outFile);
end
