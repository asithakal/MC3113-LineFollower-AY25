%% ICD_Definition.m - Interface Control Document v0.1
% MC3113 Mechatronic Systems Design - Line-Follower Digital Twin
%
% PURPOSE: Define all interface signals in one place (Single Source of Truth)
% This prevents confusion and enables parallel development of plant and controller
%
% DEMONSTRATES:
% - How ICD captures signal names, types, units, ranges, rates
% - Why having one authoritative definition matters for MBSE
% - Connection to requirements (signals drive what we can test)

clear ICD;

%% ===================================================================
%% INPUTS: Signals FROM plant/sensors TO controller
%% ===================================================================

% Sensor array: 5-element reflectance array for line detection
ICD.inputs.sensor_array.name = 'sensor[5]';
ICD.inputs.sensor_array.direction = 'IN';
ICD.inputs.sensor_array.type = 'float array (5 elements)';
ICD.inputs.sensor_array.units = 'normalized [0..1]';
ICD.inputs.sensor_array.rate_hz = 100;  % 100 Hz sampling
ICD.inputs.sensor_array.range = [0.0, 1.0];  % 0=no line, 1=on line
ICD.inputs.sensor_array.offsets_mm = [-40, -20, 0, 20, 40];  % Lateral positions
ICD.inputs.sensor_array.description = '5-element reflectance array for line tracking';

% Fault flag: Indicates sensor dropout (for Scenario S3)
ICD.inputs.fault_flag.name = 'fault_flag';
ICD.inputs.fault_flag.direction = 'IN';
ICD.inputs.fault_flag.type = 'boolean';
ICD.inputs.fault_flag.units = 'flag (0=normal, 1=fault)';
ICD.inputs.fault_flag.rate_hz = 100;
ICD.inputs.fault_flag.range = [0, 1];
ICD.inputs.fault_flag.description = 'Sensor dropout indicator (1 = sensors failed)';

%% ===================================================================
%% OUTPUTS: Signals FROM controller TO actuators/motors
%% ===================================================================

% Left motor drive command
ICD.outputs.u_L.name = 'u_L';
ICD.outputs.u_L.direction = 'OUT';
ICD.outputs.u_L.type = 'float';
ICD.outputs.u_L.units = 'normalized [-1..1]';
ICD.outputs.u_L.rate_hz = 100;  % Controller runs at 100 Hz
ICD.outputs.u_L.range = [-1.0, 1.0];  % -1=full reverse, 0=stop, 1=full forward
ICD.outputs.u_L.description = 'Left motor drive command (PWM equivalent)';

% Right motor drive command
ICD.outputs.u_R.name = 'u_R';
ICD.outputs.u_R.direction = 'OUT';
ICD.outputs.u_R.type = 'float';
ICD.outputs.u_R.units = 'normalized [-1..1]';
ICD.outputs.u_R.rate_hz = 100;
ICD.outputs.u_R.range = [-1.0, 1.0];
ICD.outputs.u_R.description = 'Right motor drive command (PWM equivalent)';

%% ===================================================================
%% TELEMETRY: Signals logged for verification and analysis
%% ===================================================================

% Forward velocity (computed from u_L, u_R)
ICD.telemetry.v.name = 'v';
ICD.telemetry.v.type = 'float';
ICD.telemetry.v.units = 'm/s';
ICD.telemetry.v.description = 'Forward velocity of robot';

% Angular rate (turn rate)
ICD.telemetry.w.name = 'w';
ICD.telemetry.w.type = 'float';
ICD.telemetry.w.units = 'rad/s';
ICD.telemetry.w.description = 'Angular velocity (yaw rate)';

% Line tracking error (lateral offset from track centerline)
ICD.telemetry.e_line.name = 'e_line';
ICD.telemetry.e_line.type = 'float';
ICD.telemetry.e_line.units = 'm';
ICD.telemetry.e_line.description = 'Lateral error from track centerline';

% Position X (global frame)
ICD.telemetry.x.name = 'x';
ICD.telemetry.x.type = 'float';
ICD.telemetry.x.units = 'm';
ICD.telemetry.x.description = 'X position (global frame)';

% Position Y (global frame)
ICD.telemetry.y.name = 'y';
ICD.telemetry.y.type = 'float';
ICD.telemetry.y.units = 'm';
ICD.telemetry.y.description = 'Y position (global frame)';

% Heading angle
ICD.telemetry.theta.name = 'theta';
ICD.telemetry.theta.type = 'float';
ICD.telemetry.theta.units = 'rad';
ICD.telemetry.theta.description = 'Heading angle (yaw)';

%% ===================================================================
%% ICD METADATA (ownership and version control)
%% ===================================================================

ICD.owner.name = 'MC3113 Teaching Team';
ICD.owner.role = 'ICD Owner (Demo)';
ICD.owner.email = 'asitha@uom.lk';
ICD.owner.last_updated = '25-11-2025';
ICD.version = 'v0.1';

%% Display summary
disp('[OK] ICD v0.1 loaded');
disp(['  Owner: ', ICD.owner.name]);
disp(['  Input signals: ', num2str(length(fieldnames(ICD.inputs)))]);
disp(['  Output signals: ', num2str(length(fieldnames(ICD.outputs)))]);
disp(['  Telemetry fields: ', num2str(length(fieldnames(ICD.telemetry)))]);
disp(['  Last updated: ', ICD.owner.last_updated]);

%% ICD:
% 1. ICD is the "contract" between subsystems
% 2. If you change a signal definition, you change ONE file
% 3. Controller developer and plant developer can work in parallel
% 4. Every signal has units, range, rate - this enables verification
% 5. ICD drives what metrics we can compute (v, e_line, etc.)
