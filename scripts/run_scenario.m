function run_scenario(scenario_id, controller_fn, run_id)
% RUN_SCENARIO  Run line-follower scenario with realistic disturbances
%
%   Features:
%   - Initial lateral offset
%   - Track curvature (gentle curves)
%   - Sensor noise
%   - Process disturbances (bumps, friction variation)
%   - Obstacle interaction (S2)
%   - Sensor dropout (S3)

    % Scenario durations
    durations = struct('S1', 90, 'S2', 120, 'S3', 150);
    duration = durations.(scenario_id);
    
    dt = 0.01;  % 100 Hz
    n_steps = duration / dt;
    
    % Plant parameters
    wheelbase = 0.15;  % m
    v_max = 0.8;  % m/s
    
    % Initialize state with DISTURBANCE
    x = 0;
    y = 0.08;  % START OFF-CENTER (8cm to the right)
    theta = 0.05;  % START WITH SLIGHT ANGLE (3 degrees)
    v = 0;
    omega = 0;
    
    % Track definition (add some curves)
    track_waypoints_x = [0, 10, 20, 30, 40, 50, 60];
    track_waypoints_y = [0,  0,  0.1, 0.1, 0.05, 0, 0];  % Gentle S-curve
    
    % Preallocate logs
    log = struct();
    log.t = zeros(n_steps, 1);
    log.x = zeros(n_steps, 1);
    log.y = zeros(n_steps, 1);
    log.theta = zeros(n_steps, 1);
    log.v = zeros(n_steps, 1);
    log.omega = zeros(n_steps, 1);
    log.e_line = zeros(n_steps, 1);
    log.sensor = zeros(n_steps, 5);
    log.u_L = zeros(n_steps, 1);
    log.u_R = zeros(n_steps, 1);
    log.obstacle_flag = zeros(n_steps, 1);
    log.fault_flag = zeros(n_steps, 1);
    log.line_loss_flag = zeros(n_steps, 1);
    
    fprintf('Running scenario %s...\n', scenario_id);
    
    % Random disturbances (seeded for reproducibility)
    rng(12345);  % Fixed seed so results are repeatable
    
    % Simulation loop
    for k = 1:n_steps
        t = (k-1) * dt;
        
        % Track centerline at current x position (interpolate)
        track_y = interp1(track_waypoints_x, track_waypoints_y, x, 'pchip', 0);
        
        % Lateral error (distance from track centerline)
        e_line = y - track_y;
        
        % Add SENSOR NOISE
        sensor_noise_level = 0.02;
        sensor = compute_sensors(e_line) + sensor_noise_level * randn(5, 1);
        sensor = max(0, min(1, sensor));  % Clamp [0,1]
        
        % Scenario-specific flags and disturbances
        obstacle_flag = 0;
        fault_flag = 0;
        disturbance_force_y = 0;
        
        % S2: Obstacle forces robot away
        if strcmp(scenario_id, 'S2')
            if t >= 12 && t <= 14
                obstacle_flag = 1;
                % Obstacle pushes robot laterally
                disturbance_force_y = 0.3 * sin(pi * (t - 12) / 2);  % Peak at t=13
            end
        end
        
        % S3: Sensor fault
        if strcmp(scenario_id, 'S3')
            if t >= 20 && t <= 30
                fault_flag = 1;
                % Sensor readings become unreliable
                sensor = 0.5 * ones(5, 1) + 0.1 * randn(5, 1);
                sensor = max(0, min(1, sensor));
            end
        end
        
        % Random process noise (small bumps, friction variation)
        process_noise_y = 0.005 * randn();  % Lateral disturbance
        process_noise_theta = 0.01 * randn();  % Angular disturbance
        
        % Pack inputs for controller
        inputs.sensor = sensor;
        inputs.e_line = e_line;
        inputs.v = v;
        inputs.omega = omega;
        inputs.obstacle_flag = obstacle_flag;
        inputs.fault_flag = fault_flag;
        
        % Call controller
        [u_L, u_R] = controller_fn(inputs);
        
        % Plant dynamics with disturbances
        v_left = u_L * v_max;
        v_right = u_R * v_max;
        
        % Add wheel slip (asymmetric friction)
        slip_factor = 0.98 + 0.02 * randn();  % 2% random variation
        v_left = v_left * slip_factor;
        v_right = v_right / slip_factor;
        
        % Robot velocities
        v = (v_left + v_right) / 2;
        omega = (v_right - v_left) / wheelbase;
        
        % Integrate with disturbances
        x = x + v * cos(theta) * dt;
        y = y + v * sin(theta) * dt + process_noise_y + disturbance_force_y * dt;
        theta = theta + omega * dt + process_noise_theta;
        
        % Line loss detection
        line_loss_flag = abs(e_line) > 0.5;
        
        % Store in log
        log.t(k) = t;
        log.x(k) = x;
        log.y(k) = y;
        log.theta(k) = theta;
        log.v(k) = v;
        log.omega(k) = omega;
        log.e_line(k) = e_line;
        log.sensor(k, :) = sensor';
        log.u_L(k) = u_L;
        log.u_R(k) = u_R;
        log.obstacle_flag(k) = obstacle_flag;
        log.fault_flag(k) = fault_flag;
        log.line_loss_flag(k) = line_loss_flag;
    end
    
    % Write CSV
    write_log_csv(log, run_id, scenario_id);
    fprintf('Saved log to logging/%s.csv\n', run_id);
    fprintf('  Final e_line: %.3f m\n', e_line);
    fprintf('  Max |e_line|: %.3f m\n', max(abs(log.e_line)));
    fprintf('  IAE estimate: %.4f m·s\n', sum(abs(log.e_line)) * dt);
end

function sensor = compute_sensors(e_line)
    % 5-element reflectance sensor array
    % Positions relative to robot center: [-40, -20, 0, 20, 40] mm
    positions = [-0.04, -0.02, 0, 0.02, 0.04];  % meters
    sensor = zeros(5, 1);
    
    % Line width: ~30mm, so sensors see line when within ~15mm
    line_half_width = 0.015;  % 15mm
    
    for i = 1:5
        % Distance from this sensor to the line
        sensor_global_y = positions(i) - e_line;  % If e_line=0, center sensor sees line
        
        % Higher reading when sensor is over the line
        dist = abs(sensor_global_y);
        
        if dist < line_half_width
            % Over the line: high reading
            sensor(i) = 1.0 - (dist / line_half_width)^2;
        else
            % Off the line: exponential decay
            sensor(i) = exp(-(dist - line_half_width)^2 / 0.001);
        end
        
        sensor(i) = max(0, min(1, sensor(i)));
    end
end

function write_log_csv(log, run_id, scenario_id)
    % Write log to CSV following the standard schema
    filename = sprintf('logging/%s.csv', run_id);
    
    fid = fopen(filename, 'w');
    
    % Header (23 mandatory columns)
    fprintf(fid, 'run_id,scenario_id,t,x,y,theta,v,omega,e_line,line_loss_flag,');
    fprintf(fid, 'sensor_1,sensor_2,sensor_3,sensor_4,sensor_5,');
    fprintf(fid, 'obstacle_flag,fault_flag,u_L,u_R,sat_flag_L,sat_flag_R,safety_violation,notes\n');
    
    % Data rows
    n = length(log.t);
    for k = 1:n
        % Detect saturation
        sat_L = (abs(log.u_L(k)) >= 0.99);
        sat_R = (abs(log.u_R(k)) >= 0.99);
        
        % Detect safety violation (simplified)
        safety_viol = 0;
        if strcmp(scenario_id, 'S3') && log.fault_flag(k) && log.v(k) > 0.45
            safety_viol = 1;
        end
        if strcmp(scenario_id, 'S2') && log.obstacle_flag(k) && abs(log.e_line(k)) < 0.05
            safety_viol = 1;  % "Collision" if obstacle present and very close to line
        end
        
        fprintf(fid, '%s,%s,%.3f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%d,', ...
            run_id, scenario_id, log.t(k), log.x(k), log.y(k), log.theta(k), ...
            log.v(k), log.omega(k), log.e_line(k), log.line_loss_flag(k));
        
        fprintf(fid, '%.4f,%.4f,%.4f,%.4f,%.4f,', log.sensor(k,:));
        
        fprintf(fid, '%d,%d,%.4f,%.4f,%d,%d,%d,\n', ...
            log.obstacle_flag(k), log.fault_flag(k), ...
            log.u_L(k), log.u_R(k), sat_L, sat_R, safety_viol);
    end
    
    fclose(fid);
end
