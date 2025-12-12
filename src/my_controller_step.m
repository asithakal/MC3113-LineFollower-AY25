function [u_L, u_R] = my_controller_step(inputs)
% MY_CONTROLLER_STEP  Simple P controller on lateral error for demo.
%
%   [u_L, u_R] = my_controller_step(inputs)
%
% inputs fields (from ICD):
%   inputs.sensor        - 5x1 array of normalized sensor readings [0..1]
%   inputs.e_line        - lateral error [m]
%   inputs.v             - forward speed [m/s]
%   inputs.omega         - yaw rate [rad/s]
%   inputs.obstacle_flag - bool (0/1)
%   inputs.fault_flag    - bool (0/1)
%
% outputs:
%   u_L, u_R in [-1, 1]

    % Base forward command (normalized)
    base = 0.4;   % try to keep it modest for stability

    % Simple proportional term on lateral error
    Kp = -1.0;    % sign chosen so that positive error steers back

    steer = Kp * inputs.e_line;

    % Combine into left/right commands
    u_L = base - steer;
    u_R = base + steer;

    % Basic handling for S3: if fault_flag is 1, reduce speed
    if inputs.fault_flag == 1
        base_fault = 0.2;      % slower base during fault
        u_L = base_fault - steer;
        u_R = base_fault + steer;
    end

    % Saturate commands
    u_L = max(min(u_L, 1.0), -1.0);
    u_R = max(min(u_R, 1.0), -1.0);
end