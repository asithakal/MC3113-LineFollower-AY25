function run_scenario_hifi(scenario_id, controller_fn, run_id)
% RUN_SCENARIO_HIFI  High-fidelity line-follower simulation
%
%   Includes:
%   - Motor dynamics (first-order lag)
%   - Tire slip and friction model
%   - Inertia and acceleration limits
%   - Battery voltage drop
%   - More realistic sensor physics
%   - Surface roughness
%   - Temperature-dependent sensor drift

    % Scenario durations
    durations = struct('S1', 90, 'S2', 120, 'S3', 150);
    duration = durations.(scenario_id);
    
    dt = 0.01;  % 100 Hz
    n_steps = duration / dt;
    
    %% Plant parameters (high-fidelity)
    wheelbase = 0.15;  % m
    wheel_radius = 0.03;  % m
    robot_mass = 0.8;  % kg
    moment_of_inertia = 0.002;  % kg·m²
    
    % Motor parameters
    motor_time_constant = 0.05;  % s (50ms lag)
    v_max_nominal = 0.8;  % m/s at full battery
    omega_max = 3.0;  % rad/s
    
    % Battery model
    battery_voltage_initial = 12.0;  % V
    battery_capacity = 2.0;  % Ah
    battery_internal_resistance = 0.5;  % Ohm
    
    % Friction model
    mu_static = 0.8;
    mu_kinetic = 0.6;
    rolling_resistance = 0.02;
    
    % Sensor parameters
    sensor_response_time = 0.005;  % 5ms
    sensor_temperature_drift_rate = 0.001;  % per °C
    ambient_temp = 25;  % °C
    
    %% Initialize state with realistic disturbances
    x = 0;
    y = 0.08;  % 8cm off-center
    theta = 0.05;  % ~3° initial angle
    v = 0;
    omega = 0;
    
    % Motor states (actual wheel velocities vs commanded)
    v_left_actual = 0;
    v_right_actual = 0;
    v_left_commanded = 0;
    v_right_commanded = 0;
    
    % Battery state
    battery_charge = battery_capacity;  % Ah
    battery_voltage = battery_voltage_initial;
    
    % Sensor states (filtered)
    sensor_filtered = 0.5 * ones(5, 1);
    
    % Temperature (rises with motor use)
    robot_temperature = ambient_temp;
    
    %% Track definition (more complex)
    track_waypoints_x = [0, 8, 16, 24, 32, 40, 48, 56, 64, 72];
    track_waypoints_y = [0, 0, 0.05, 0.12, 0.15, 0.12, 0.05, 0, -0.03, 0];
    
    % Surface roughness profile (varies along track)
    surface_roughness = @(x_pos) 0.01 * sin(2 * pi * x_pos / 10);
    
    %% Preallocate logs
    log = init_log_struct(n_steps);
    
    fprintf('Running HIGH-FIDELITY scenario %s...\n', scenario_id);
    
    %% Random seed for reproducibility
    rng(54321);
    
    %% Simulation loop
    for k = 1:n_steps
        t = (k-1) * dt;
        
        %% Track and error computation
        track_y = interp1(track_waypoints_x, track_waypoints_y, x, 'pchip', 0);
        e_line = y - track_y;
        
        %% High-fidelity sensor model
        sensor_raw = compute_sensors_hifi(e_line, robot_temperature, ambient_temp);
        
        % Sensor dynamics (first-order filter)
        alpha_sensor = dt / (sensor_response_time + dt);
        sensor_filtered = alpha_sensor * sensor_raw + (1 - alpha_sensor) * sensor_filtered;
        
        % Add realistic noise
        sensor_noise = 0.01 * randn(5, 1);
        sensor_measured = sensor_filtered + sensor_noise;
        sensor_measured = max(0, min(1, sensor_measured));
        
        %% Scenario-specific events
        obstacle_flag = 0;
        fault_flag = 0;
        disturbance_force_y = 0;
        disturbance_torque = 0;
        
        % S2: Obstacle interaction
        if strcmp(scenario_id, 'S2')
            if t >= 12 && t <= 15
                obstacle_flag = 1;
                % Obstacle creates force and torque disturbances
                phase = (t - 12) / 3;
                disturbance_force_y = 0.5 * sin(pi * phase);
                disturbance_torque = 0.1 * sin(2 * pi * phase);
            end
        end
        
        % S3: Sensor fault (complete dropout)
        if strcmp(scenario_id, 'S3')
            if t >= 20 && t <= 30
                fault_flag = 1;
                % Sensors frozen or random
                sensor_measured = 0.5 + 0.05 * randn(5, 1);
                sensor_measured = max(0, min(1, sensor_measured));
            end
        end
        
        %% Surface disturbances
        surface_bump_y = surface_roughness(x) * randn();
        surface_bump_theta = 0.005 * randn();
        
        %% Pack inputs for controller
        inputs.sensor = sensor_measured;
        inputs.e_line = e_line;
        inputs.v = v;
        inputs.omega = omega;
        inputs.obstacle_flag = obstacle_flag;
        inputs.fault_flag = fault_flag;
        
        %% Call controller
        [u_L, u_R] = controller_fn(inputs);
        
        %% Battery dynamics
        % Current draw proportional to motor commands
        current_draw = 0.5 * (abs(u_L) + abs(u_R));  % A
        battery_charge = battery_charge - current_draw * dt / 3600;  % Ah
        
        % Voltage drop under load
        battery_voltage = battery_voltage_initial - ...
            (battery_internal_resistance * current_draw) - ...
            (battery_voltage_initial - 10.0) * (1 - battery_charge / battery_capacity);
        
        % Effective v_max drops with battery voltage
        v_max_effective = v_max_nominal * (battery_voltage / battery_voltage_initial);
        
        %% Motor dynamics (first-order lag)
        v_left_commanded = u_L * v_max_effective;
        v_right_commanded = u_R * v_max_effective;
        
        % Motor time constant
        alpha_motor = dt / (motor_time_constant + dt);
        v_left_actual = alpha_motor * v_left_commanded + (1 - alpha_motor) * v_left_actual;
        v_right_actual = alpha_motor * v_right_commanded + (1 - alpha_motor) * v_right_actual;
        
        %% Friction and slip model
        % Rolling resistance
        v_left_friction = v_left_actual - sign(v_left_actual) * rolling_resistance * 9.81 * dt;
        v_right_friction = v_right_actual - sign(v_right_actual) * rolling_resistance * 9.81 * dt;
        
        % Tire slip (asymmetric, load-dependent)
        slip_factor_L = 0.97 + 0.03 * randn();
        slip_factor_R = 0.97 + 0.03 * randn();
        
        v_left_final = v_left_friction * slip_factor_L;
        v_right_final = v_right_friction * slip_factor_R;
        
        %% Robot kinematics
        v_robot = (v_left_final + v_right_final) / 2;
        omega_robot = (v_right_final - v_left_final) / wheelbase;
        
        %% Inertial effects (limited acceleration)
        max_accel = 2.0;  % m/s²
        max_alpha = 5.0;  % rad/s²
        
        dv = (v_robot - v) / dt;
        domega = (omega_robot - omega) / dt;
        
        dv = max(min(dv, max_accel), -max_accel);
        domega = max(min(domega, max_alpha), -max_alpha);
        
        v = v + dv * dt;
        omega = omega + domega * dt;
        
        %% Pose integration (Runge-Kutta 2nd order)
        % Half-step
        x_half = x + 0.5 * v * cos(theta) * dt;
        y_half = y + 0.5 * v * sin(theta) * dt;
        theta_half = theta + 0.5 * omega * dt;
        
        % Full step
        x = x + v * cos(theta_half) * dt;
        y = y + v * sin(theta_half) * dt + surface_bump_y + disturbance_force_y * dt;
        theta = theta + omega * dt + surface_bump_theta + disturbance_torque * dt;
        
        %% Temperature model
        % Heating from motors
        heat_generation = 0.1 * (abs(u_L) + abs(u_R));
        % Cooling to ambient
        cooling = 0.05 * (robot_temperature - ambient_temp);
        robot_temperature = robot_temperature + (heat_generation - cooling) * dt;
        
        %% Logging
        line_loss_flag = abs(e_line) > 0.5;
        
        log.t(k) = t;
        log.x(k) = x;
        log.y(k) = y;
        log.theta(k) = theta;
        log.v(k) = v;
        log.omega(k) = omega;
        log.e_line(k) = e_line;
        log.sensor(k, :) = sensor_measured';
        log.u_L(k) = u_L;
        log.u_R(k) = u_R;
        log.obstacle_flag(k) = obstacle_flag;
        log.fault_flag(k) = fault_flag;
        log.line_loss_flag(k) = line_loss_flag;
        
        % Extra telemetry for high-fidelity
        log.battery_voltage(k) = battery_voltage;
        log.temperature(k) = robot_temperature;
        log.v_left_actual(k) = v_left_actual;
        log.v_right_actual(k) = v_right_actual;
    end
    
    %% Write CSV
    write_log_csv(log, run_id, scenario_id);
    
    fprintf('✓ Saved to logging/%s.csv\n', run_id);
    fprintf('  Final e_line: %.3f m\n', e_line);
    fprintf('  Max |e_line|: %.3f m\n', max(abs(log.e_line)));
    fprintf('  IAE: %.4f m·s\n', sum(abs(log.e_line)) * dt);
    fprintf('  Battery: %.1f V (%.1f%% charge)\n', ...
        battery_voltage, 100 * battery_charge / battery_capacity);
    fprintf('  Final temp: %.1f °C\n', robot_temperature);
end

function sensor = compute_sensors_hifi(e_line, current_temp, ambient_temp)
    % High-fidelity sensor model with temperature drift
    positions = [-0.04, -0.02, 0, 0.02, 0.04];
    sensor = zeros(5, 1);
    
    line_half_width = 0.015;
    
    % Temperature drift
    temp_drift = 0.001 * (current_temp - ambient_temp);
    
    for i = 1:5
        sensor_y = positions(i) - e_line;
        dist = abs(sensor_y);
        
        if dist < line_half_width
            sensor(i) = 1.0 - (dist / line_half_width)^2;
        else
            sensor(i) = exp(-(dist - line_half_width)^2 / 0.001);
        end
        
        % Apply temperature drift
        sensor(i) = sensor(i) + temp_drift;
        sensor(i) = max(0, min(1, sensor(i)));
    end
end

function log = init_log_struct(n_steps)
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
    log.battery_voltage = zeros(n_steps, 1);
    log.temperature = zeros(n_steps, 1);
    log.v_left_actual = zeros(n_steps, 1);
    log.v_right_actual = zeros(n_steps, 1);
end

function write_log_csv(log, run_id, scenario_id)
    filename = sprintf('logging/%s.csv', run_id);
    fid = fopen(filename, 'w');
    
    % Standard 23 columns + extras
    fprintf(fid, 'run_id,scenario_id,t,x,y,theta,v,omega,e_line,line_loss_flag,');
    fprintf(fid, 'sensor_1,sensor_2,sensor_3,sensor_4,sensor_5,');
    fprintf(fid, 'obstacle_flag,fault_flag,u_L,u_R,sat_flag_L,sat_flag_R,safety_violation,notes,');
    fprintf(fid, 'battery_voltage,temperature,v_left_actual,v_right_actual\n');
    
    n = length(log.t);
    for k = 1:n
        sat_L = (abs(log.u_L(k)) >= 0.99);
        sat_R = (abs(log.u_R(k)) >= 0.99);
        
        safety_viol = 0;
        if strcmp(scenario_id, 'S3') && log.fault_flag(k) && log.v(k) > 0.45
            safety_viol = 1;
        end
        if strcmp(scenario_id, 'S2') && log.obstacle_flag(k) && abs(log.e_line(k)) < 0.05
            safety_viol = 1;
        end
        
        fprintf(fid, '%s,%s,%.3f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%d,', ...
            run_id, scenario_id, log.t(k), log.x(k), log.y(k), log.theta(k), ...
            log.v(k), log.omega(k), log.e_line(k), log.line_loss_flag(k));
        
        fprintf(fid, '%.4f,%.4f,%.4f,%.4f,%.4f,', log.sensor(k,:));
        
        fprintf(fid, '%d,%d,%.4f,%.4f,%d,%d,%d,HIFI,', ...
            log.obstacle_flag(k), log.fault_flag(k), ...
            log.u_L(k), log.u_R(k), sat_L, sat_R, safety_viol);
        
        fprintf(fid, '%.2f,%.2f,%.4f,%.4f\n', ...
            log.battery_voltage(k), log.temperature(k), ...
            log.v_left_actual(k), log.v_right_actual(k));
    end
    
    fclose(fid);
end
