function run_scenario_realistic(scenarioId, controllerFcn, runId)
% RUN_SCENARIO  Execute a line-follower scenario and log results
% with a simple but realistic differential-drive plant.
%
%   run_scenario('S1', @my_controller_step, 'MC3113_AY25_Team01_S1_001')
%
% This version uses an internal discrete-time plant model:
%   - Kinematic differential drive
%   - First-order motor lag
%   - Straight-line track along y-axis (x = 0) for e_line
%
% Inputs:
%   scenarioId   - 'S1', 'S2', or 'S3'
%   controllerFcn- handle: [u_L, u_R] = controllerFcn(inputsStruct)
%   runId        - string run identifier for CSV

    if nargin < 2
        error('Usage: run_scenario(scenarioId, controllerFcn, runId)');
    end
    if nargin < 3 || isempty(runId)
        runId = sprintf('TEMP_%s_%03d', scenarioId, randi(999));
    end

    % Simulation parameters
    dt = 0.01;  % 100 Hz

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

    % Plant parameters (should match plant_params.yaml roughly)
    r   = 0.03;   % wheel radius [m]
    b   = 0.16;   % wheelbase [m]
    tau = 0.15;   % motor time constant [s]
    v_max = 0.60; % [m/s]
    w_max = 2.0;  % [rad/s]

    % Track model:
    %   - Assume the line is the y-axis (x = 0)
    %   - Robot starts slightly off to the side and pointing roughly forward
    xk     = 0.05;      % initial x [m]
    yk     = 0.0;       % initial y [m]
    thetak = 0.0;       % initial heading [rad]
    v_k    = 0.0;       % forward speed [m/s]
    w_k    = 0.0;       % yaw rate [rad/s]

    % Sensor geometry (consistent with plant_params.yaml)
    sensor_offsets = [-0.04, -0.02, 0.0, 0.02, 0.04];  % [m]
    num_sensors = numel(sensor_offsets);
    sensor_gain = 200;   % controls how fast the reflectance drops with distance
    sensor_noise_std = 0.02;

    % Helper for line distance: distance from sensor point to x=0 line
    line_x = 0.0;  % line is at x=0

    % Preallocate logs
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

    % Internal motor speeds [m/s] (left/right), with lag
    vL = 0.0;
    vR = 0.0;

    % Main simulation loop
    for k = 1:N
        tk = (k-1) * dt;

        % Scenario flags
        obstacle_flag = 0;
        fault_flag    = 0;

        switch upper(string(scenarioId))
            case "S2"
                % Simple obstacle: active in a time window
                if tk >= 12.0 && tk <= 12.0 + 2.0   % 2 s window
                    obstacle_flag = 1;
                end
            case "S3"
                % Sensor fault window
                if tk >= 20.0 && tk <= 30.0
                    fault_flag = 1;
                end
        end

        % Compute current e_line: distance from robot's projection to line
        % For simplicity, use robot centre x-position as lateral error
        e_line_k = xk - line_x;

        % Generate sensor readings:
        % For each sensor, compute its global position, then its distance to line.
        sensor_vals = zeros(num_sensors, 1);
        for i = 1:num_sensors
            % Sensor offset in robot frame (x-axis lateral, y-axis forward)
            sx_r = sensor_offsets(i);
            sy_r = 0.0;

            % Rotate into world frame
            sx_w = xk + cos(thetak)*sx_r - sin(thetak)*sy_r;
            sy_w = yk + sin(thetak)*sx_r + cos(thetak)*sy_r;

            % Distance from line x=0 (ignore y)
            d = abs(sx_w - line_x);

            % Convert distance to reflectance (1 on the line, decays off it)
            val = exp(-sensor_gain * d^2);   % Gaussian-like response
            % Add noise
            val = val + sensor_noise_std * randn();
            % Clamp to [0, 1]
            val = max(min(val, 1.0), 0.0);

            sensor_vals(i) = val;
        end

        % Determine line loss flag: if all sensors very low -> lost
        if all(sensor_vals < 0.05)
            line_loss_flag = 1;
        else
            line_loss_flag = 0;
        end

        % Build controller input struct
        inputs = struct();
        inputs.sensor        = sensor_vals;
        inputs.e_line        = e_line_k;
        inputs.v             = v_k;
        inputs.omega         = w_k;
        inputs.obstacle_flag = obstacle_flag;
        inputs.fault_flag    = fault_flag;

        % Call controller
        [u_L, u_R] = controllerFcn(inputs);

        % Saturate commands
        sat_flag_L = 0;
        sat_flag_R = 0;
        if u_L > 1.0
            u_L = 1.0;
            sat_flag_L = 1;
        elseif u_L < -1.0
            u_L = -1.0;
            sat_flag_L = 1;
        end
        if u_R > 1.0
            u_R = 1.0;
            sat_flag_R = 1;
        elseif u_R < -1.0
            u_R = -1.0;
            sat_flag_R = 1;
        end

        % Map normalized commands to desired wheel speeds (m/s)
        vL_des = u_L * v_max;
        vR_des = u_R * v_max;

        % First-order lag for motor velocities
        alpha = dt / max(tau, dt);
        vL = vL + alpha * (vL_des - vL);
        vR = vR + alpha * (vR_des - vR);

        % Convert wheel speeds to body velocities
        v_k = (vR + vL) / 2;          % forward speed
        w_k = (vR - vL) / b;          % yaw rate

        % Apply speed cap in S3 fault window (safety)
        safety_violation_flag = 0;
        if strcmpi(scenarioId, 'S3') && fault_flag == 1
            v_cap = 0.45;
            if v_k > v_cap
                % Cap forward speed by scaling wheel speeds
                scale = v_cap / max(v_k, 1e-6);
                vL = vL * scale;
                vR = vR * scale;
                v_k = (vR + vL) / 2;
                w_k = (vR - vL) / b;
                safety_violation_flag = 1;  % mark a violation if we had to cap
            end
        end

        % Integrate kinematics (unicycle model)
        xk = xk + v_k * cos(thetak) * dt;
        yk = yk + v_k * sin(thetak) * dt;
        thetak = thetak + w_k * dt;

        % Log everything
        run_id(k)       = string(runId);
        scenario_col(k) = string(scenarioId);
        t(k)            = tk;
        x(k)            = xk;
        y(k)            = yk;
        theta(k)        = thetak;
        v(k)            = v_k;
        omega(k)        = w_k;
        e_line(k)       = e_line_k;
        line_loss(k)    = line_loss_flag;
        sensor_1(k)     = sensor_vals(1);
        sensor_2(k)     = sensor_vals(2);
        sensor_3(k)     = sensor_vals(3);
        sensor_4(k)     = sensor_vals(4);
        sensor_5(k)     = sensor_vals(5);
        obstacle_f(k)   = obstacle_flag;
        fault_f(k)      = fault_flag;
        u_L_log(k)      = u_L;
        u_R_log(k)      = u_R;
        sat_L(k)        = sat_flag_L;
        sat_R(k)        = sat_flag_R;
        safety_violation(k) = safety_violation_flag;
        notes(k)        = "";
    end

    % Build table and write CSV
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

    if ~exist('logging','dir')
        mkdir('logging');
    end
    outFile = fullfile('logging', sprintf('%s.csv', runId));
    writetable(T, outFile);
    fprintf('Saved log to %s\n', outFile);
end
