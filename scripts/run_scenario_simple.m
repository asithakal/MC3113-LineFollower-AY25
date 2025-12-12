function run_scenario_simple(scenario_id, controller_fn, run_id)
% RUN_SCENARIO_SIMPLE  Minimal-fidelity line-follower (fast execution)
%
%   For quick testing and structural verification only
%   No disturbances, noise, or complex physics

    durations = struct('S1', 90, 'S2', 120, 'S3', 150);
    duration = durations.(scenario_id);
    
    dt = 0.01;
    n_steps = duration / dt;
    
    wheelbase = 0.15;
    v_max = 0.8;
    
    % Perfect initial conditions
    x = 0; y = 0; theta = 0; v = 0; omega = 0;
    
    % Straight track
    track_y = 0;
    
    % Preallocate
    log = struct();
    fields = {'t','x','y','theta','v','omega','e_line','u_L','u_R', ...
              'obstacle_flag','fault_flag','line_loss_flag'};
    for f = fields
        log.(f{1}) = zeros(n_steps, 1);
    end
    log.sensor = zeros(n_steps, 5);
    
    fprintf('Running SIMPLE scenario %s...\n', scenario_id);
    
    for k = 1:n_steps
        t = (k-1) * dt;
        
        e_line = y - track_y;
        sensor = [0.2; 0.5; 1.0; 0.5; 0.2];  % Dummy centered reading
        
        obstacle_flag = 0;
        fault_flag = 0;
        
        inputs.sensor = sensor;
        inputs.e_line = e_line;
        inputs.v = v;
        inputs.omega = omega;
        inputs.obstacle_flag = obstacle_flag;
        inputs.fault_flag = fault_flag;
        
        [u_L, u_R] = controller_fn(inputs);
        
        % Perfect dynamics
        v = (u_L + u_R) * v_max / 2;
        omega = (u_R - u_L) * v_max / wheelbase;
        
        x = x + v * cos(theta) * dt;
        y = y + v * sin(theta) * dt;
        theta = theta + omega * dt;
        
        % Log
        log.t(k) = t;
        log.x(k) = x;
        log.y(k) = y;
        log.theta(k) = theta;
        log.v(k) = v;
        log.omega(k) = omega;
        log.e_line(k) = e_line;
        log.sensor(k,:) = sensor';
        log.u_L(k) = u_L;
        log.u_R(k) = u_R;
        log.obstacle_flag(k) = obstacle_flag;
        log.fault_flag(k) = fault_flag;
        log.line_loss_flag(k) = abs(e_line) > 0.5;
    end
    
    write_log_csv_simple(log, run_id, scenario_id);
    fprintf('Saved to logging/%s.csv\n', run_id);
end

function write_log_csv_simple(log, run_id, scenario_id)
    filename = sprintf('logging/%s.csv', run_id);
    fid = fopen(filename, 'w');
    
    fprintf(fid, 'run_id,scenario_id,t,x,y,theta,v,omega,e_line,line_loss_flag,');
    fprintf(fid, 'sensor_1,sensor_2,sensor_3,sensor_4,sensor_5,');
    fprintf(fid, 'obstacle_flag,fault_flag,u_L,u_R,sat_flag_L,sat_flag_R,safety_violation,notes\n');
    
    n = length(log.t);
    for k = 1:n
        fprintf(fid, '%s,%s,%.3f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%d,', ...
            run_id, scenario_id, log.t(k), log.x(k), log.y(k), log.theta(k), ...
            log.v(k), log.omega(k), log.e_line(k), log.line_loss_flag(k));
        fprintf(fid, '%.4f,%.4f,%.4f,%.4f,%.4f,', log.sensor(k,:));
        fprintf(fid, '%d,%d,%.4f,%.4f,0,0,0,SIMPLE\n', ...
            log.obstacle_flag(k), log.fault_flag(k), log.u_L(k), log.u_R(k));
    end
    fclose(fid);
end
