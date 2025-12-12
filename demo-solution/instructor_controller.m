function [u_L, u_R] = instructor_controller(inputs)
% INSTRUCTOR_CONTROLLER  Demo solution controller for MC3113 line-follower
%
%   [u_L, u_R] = instructor_controller(inputs)
%
% This is the COMPLETE DEMO SOLUTION. DO NOT SHARE WITH STUDENTS.
%
% Features:
%   - P + I controller on e_line for nominal tracking (S1/S2)
%   - Speed reduction when obstacle_flag = 1 (S2)
%   - Speed cap enforcement when fault_flag = 1 (S3)
%   - Basic line-loss recovery logic
%
% Inputs (from ICD):
%   inputs.sensor        - 5x1 array [0..1]
%   inputs.e_line        - lateral error [m]
%   inputs.v             - forward velocity [m/s]
%   inputs.omega         - yaw rate [rad/s]
%   inputs.obstacle_flag - bool
%   inputs.fault_flag    - bool
%
% Outputs:
%   u_L, u_R in [-1, 1]

    persistent integral_error;
    if isempty(integral_error)
        integral_error = 0;
    end
    
    % Controller gains (tuned for demo)
    Kp = 1.2;
    Ki = 0.3;
    dt = 0.01;  % 100 Hz
    
    % Base speeds for different scenarios
    base_nominal = 0.45;      % S1 nominal
    base_obstacle = 0.30;     % S2 obstacle present
    base_fault = 0.35;        % S3 fault mode (≤ 0.45 required)
    
    % Select base speed based on flags
    if inputs.fault_flag == 1
        base = base_fault;
        % Clamp to safety limit
        if base > 0.45
            base = 0.45;
        end
    elseif inputs.obstacle_flag == 1
        base = base_obstacle;
    else
        base = base_nominal;
    end
    
    % P+I control on lateral error
    error = inputs.e_line;
    integral_error = integral_error + error * dt;
    
    % Anti-windup: clamp integral
    integral_max = 0.5;
    integral_error = max(min(integral_error, integral_max), -integral_max);
    
    % Compute steering correction
    steer = Kp * error + Ki * integral_error;
    
    % Line-loss recovery: if error is large, steer harder
    if abs(error) > 0.4
        steer = steer * 1.5;  % amplify steering
    end
    
    % Compute wheel commands
    u_L = base - steer;
    u_R = base + steer;
    
    % Saturate to [-1, 1]
    u_L = max(min(u_L, 1.0), -1.0);
    u_R = max(min(u_R, 1.0), -1.0);
    
end
