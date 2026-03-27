function [t_arr, sp_arr] = stimulus_engine(stim_type, params)
% STIMULUS_ENGINE  Generate time vector and setpoint profile.
%
% INPUTS
%   stim_type : 'step' | 'ramp' | 'sustained_fault'
%   params    : struct with fields:
%                 t_amb    — ambient temperature °C (ramp start value)
%                 setpoint — target setpoint °C
%                 duration — total run time in seconds
%                 dt       — time step in seconds (default 0.1 s)
%
% OUTPUTS
%   t_arr  — time vector (N×1), seconds, starting at 0
%   sp_arr — setpoint profile (N×1), same length as t_arr

% PROVIDED — do not change this line.
t_arr = (0 : params.dt : params.duration)';   % N×1 time vector
N     = numel(t_arr);                          % number of time steps

if strcmp(stim_type, 'step')
    % ── TODO 2a — step: setpoint is held constant from t=0 ──────────
    % sp_arr should be an N×1 vector with every element = params.setpoint
    % Hint: ones(N, 1)
    % >>> YOUR CODE HERE <<<
    sp_arr = zeros(N, 1); % replace this line

elseif strcmp(stim_type, 'ramp')
    % ── TODO 2b — ramp: linear from t_amb at t=0 to setpoint at t=end
    % sp_arr starts at params.t_amb and ends at params.setpoint.
    % DO NOT start from 0°C — use params.t_amb as the start value.
    % Hint: linspace(startVal, endVal, N)  returns an N-element row;
    %       add a transpose (') to make it a column vector.
    % >>> YOUR CODE HERE <<<
    sp_arr = zeros(N, 1); % replace this line

elseif strcmp(stim_type, 'sustained_fault')
    % ── TODO 2c — sustained_fault: held at setpoint for full duration ─
    % Identical shape to 'step' — constant at params.setpoint.
    % (The distinction matters for the oracle metric selection upstream.)
    % >>> YOUR CODE HERE <<<
    sp_arr = zeros(N, 1); % replace this line

else
    % ── TODO 2d — unknown stimulus type: throw a named error ─────────
    % Hint: error('MC3113:UnknownStimulus', 'Unknown stim_type: %s', stim_type)
    % >>> YOUR CODE HERE <<<
    sp_arr = []; % replace this line
end

end