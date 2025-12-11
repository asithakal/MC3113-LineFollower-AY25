%% DemoMain.m - Complete MBSE Demo: FR/NFR -> RTM -> Verification
% MC3113 Mechatronic Systems Design - Lecture 3 Live Demo
%
% PURPOSE: Demonstrate the complete MBSE workflow:
%   1. Define interfaces (ICD)
%   2. Define requirements and tests (RTM)
%   3. Run scenarios (S1, S3)
%   4. Verify requirements against evidence
%   5. Visualize results
%
% DEMONSTRATES:
% - How ICD, Requirements, RTM, and digital twin work together
% - Traceability from standards -> requirements -> tests -> evidence
% - Why MBSE discipline prevents "design by gut feel"
%
% TO RUN: Type "DemoMain" in MATLAB command window

clear; clc; close all;

fprintf('\n');
disp('=================================================');
disp('  MC3113 MBSE DEMO');
disp('  From FR/NFR -> RTM -> Verification');
disp('  Line-Follower Digital Twin');
disp('=================================================');
fprintf('\n');

%% ===================================================================
%% STEP 1: Load ICD (Single Source of Truth for all signals)
%% ===================================================================
disp('STEP 1: Loading ICD (Interface Control Document)');
disp('-------------------------------------------------');
ICD_Definition;
fprintf('\n');
pause;

%% ===================================================================
%% STEP 2: Load Requirements and RTM
%% ===================================================================
disp('STEP 2: Loading Requirements and RTM');
disp('-------------------------------------------------');
Requirements_RTM;
fprintf('\n');
pause;

%% ===================================================================
%% STEP 3: Run Scenario S1 (Nominal Line Following)
%% ===================================================================
disp('STEP 3: Running Scenario S1 (Nominal)');
disp('-------------------------------------------------');
[log_S1, metrics_S1] = Scenario_S1();
pause;

%% ===================================================================
%% STEP 4: Run Scenario S3 (Sensor Fault + Safe State)
%% ===================================================================
disp('STEP 4: Running Scenario S3 (Fault + Safe State)');
disp('-------------------------------------------------');
[log_S3, metrics_S3] = Scenario_S3();
pause;

%% ===================================================================
%% STEP 5: Generate RTM Verification Report
%% ===================================================================
disp('STEP 5: RTM Verification Report');
disp('-------------------------------------------------');
VerificationReport(log_S1, metrics_S1, log_S3, metrics_S3, RTM);
pause;

%% ===================================================================
%% STEP 6: Plot Results (Visual Evidence)
%% ===================================================================
disp('STEP 6: Plotting Results');
disp('-------------------------------------------------');

fig = figure('Name', 'MC3113 Demo Results', 'NumberTitle', 'off', ...
    'Position', [100, 100, 1200, 800]);

%% Subplot 1: S1 Line Tracking Error
subplot(2, 3, 1);
plot(log_S1.t, log_S1.e_line, 'b', 'LineWidth', 1.5);
hold on;
yline(0.05, 'r--', 'LineWidth', 1.5);
yline(-0.05, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Line Error (m)');
title('S1: Tracking Error (R-TRACKING)');
legend('e_{line}', 'Acceptance bound', 'Location', 'best');
grid on;

%% Subplot 2: S1 Energy Consumption
subplot(2, 3, 2);
energy_cumulative = cumsum((abs(log_S1.u_L) + abs(log_S1.u_R)) * 0.01);
plot(log_S1.t, energy_cumulative, 'b', 'LineWidth', 1.5);
hold on;
yline(20, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Energy (units)');
title('S1: Energy Consumption (R-ENERGY)');
legend('Cumulative energy', 'Acceptance limit', 'Location', 'best');
grid on;

%% Subplot 3: S1 IAE Over Time
subplot(2, 3, 3);
IAE_cumulative = cumsum(abs(log_S1.e_line)) * 0.01;
plot(log_S1.t, IAE_cumulative, 'b', 'LineWidth', 1.5);
hold on;
yline(0.5, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('IAE (m*s)');
title('S1: Integrated Absolute Error (R-IAE)');
legend('Cumulative IAE', 'Acceptance limit', 'Location', 'best');
grid on;

%% Subplot 4: S3 Speed During Fault
subplot(2, 3, 4);
plot(log_S3.t, log_S3.v, 'r', 'LineWidth', 1.5);
hold on;
yline(0.45, 'b--', 'LineWidth', 1.5);
% Shade fault window
t_fault = [20, 30];
patch([t_fault(1) t_fault(2) t_fault(2) t_fault(1)], ...
      [0 0 0.6 0.6], 'yellow', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
xlabel('Time (s)');
ylabel('Velocity (m/s)');
title('S3: Speed During Fault (R-SAFE-STATE)');
legend('Velocity', 'Speed cap', 'Fault window', 'Location', 'best');
grid on;

%% Subplot 5: S3 Sensor Dropout
subplot(2, 3, 5);
plot(log_S3.t, log_S3.sensor, 'LineWidth', 1.2);
hold on;
patch([20 30 30 20], [0 0 1 1], 'red', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
xlabel('Time (s)');
ylabel('Reflectance (normalized)');
title('S3: Sensor Array (Fault 20-30 s)');
legend('S1', 'S2', 'S3', 'S4', 'S5', 'Fault window', 'Location', 'best');
grid on;

%% Subplot 6: RTM Pass/Fail Summary
subplot(2, 3, 6);
test_names_short = {'TIME', 'TRACK', 'IAE', 'ENERGY', 'SAFE'};
pass_flags = [metrics_S1.pass_R_TIME, metrics_S1.pass_R_TRACKING, ...
              metrics_S1.pass_R_IAE, metrics_S1.pass_R_ENERGY, ...
              metrics_S3.pass_R_SAFE_STATE];
colors_matrix = repmat([0 0.7 0], 5, 1);  % Green
colors_matrix(~pass_flags, :) = repmat([0.9 0 0], sum(~pass_flags), 1);  % Red
bar(1:5, pass_flags, 'FaceColor', 'flat', 'CData', colors_matrix);
set(gca, 'XTick', 1:5, 'XTickLabel', test_names_short);
ylabel('Pass (1) / Fail (0)');
title('RTM Verification Status');
ylim([0, 1.2]);
grid on;

sgtitle('MC3113 Line-Follower: Requirements to Verification', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('[OK] Plots generated\n');
fprintf('\n');

%% ===================================================================
%% DEMO COMPLETE
%% ===================================================================
disp('=================================================');
disp('  DEMO COMPLETE');
disp('=================================================');
fprintf('\n');

disp('WHAT YOU HAVE SEEN:');
disp('  1. ICD defines all signals (one source of truth)');
disp('  2. Requirements (FR/NFR) are measurable and testable');
disp('  3. RTM links every requirement to at least one test');
disp('  4. Scenarios (S1, S3) execute tests and generate evidence');
disp('  5. Verification report shows pass/fail against criteria');
disp('  6. Plots provide visual evidence for RTM rows');
fprintf('\n');

disp('FOR CA1, YOUR TEAM WILL:');
disp('  - Pick one standard (VDI 2206, ISO 26262, etc.)');
disp('  - Derive 2-3 requirements from that standard');
disp('  - Build RTM rows linking requirements to S1/S2/S3 tests');
disp('  - Show design implications (architecture, process changes)');
disp('  - Present all this in a digital poster + 8-min pitch');
fprintf('\n');

disp('=================================================');
