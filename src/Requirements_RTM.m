%% Requirements_RTM.m - Requirements and Traceability Matrix
% MC3113 Mechatronic Systems Design - Line-Follower Digital Twin
%
% PURPOSE: Define Functional and Non-Functional Requirements
%          Map each requirement to at least one test (RTM)
%
% DEMONSTRATES:
% - Difference between FR (what system does) and NFR (how well it does it)
% - How requirements link to scenarios (S1, S2, S3)
% - How RTM creates traceability: Requirement -> Test -> Evidence
% - How acceptance criteria are measurable and testable

clear REQ RTM;

%% ===================================================================
%% FUNCTIONAL REQUIREMENTS (What the system DOES)
%% ===================================================================

% FR1: Line Tracking Capability
REQ.FR1.id = 'R-TRACKING';
REQ.FR1.title = 'Line Tracking';
REQ.FR1.statement = 'In Scenario S1, the system shall detect and track the line position within +/- 0.05 m of centerline';
REQ.FR1.scenario = 'S1';
REQ.FR1.type = 'Functional';
REQ.FR1.acceptance_value = 0.05;
REQ.FR1.acceptance_units = 'm';
REQ.FR1.source = 'System definition: 5-element sensor array specification';
REQ.FR1.rationale = 'Sensor array must provide sufficient resolution for control';

% FR2: Control Output Rate
REQ.FR2.id = 'R-CTRL-RATE';
REQ.FR2.title = 'Control Loop Rate';
REQ.FR2.statement = 'The controller shall output motor commands at 100 Hz in all scenarios';
REQ.FR2.scenario = 'S1/S2/S3';
REQ.FR2.type = 'Functional';
REQ.FR2.acceptance_value = 100;
REQ.FR2.acceptance_units = 'Hz';
REQ.FR2.source = 'ICD specification (control rate requirement)';
REQ.FR2.rationale = 'Consistent timing enables predictable control response';

% FR3: Fault Detection and Safe State Entry
REQ.FR3.id = 'R-FAULT-DETECT';
REQ.FR3.title = 'Fault Detection';
REQ.FR3.statement = 'In Scenario S3, the system shall detect sensor fault and enter safe state within 50 ms';
REQ.FR3.scenario = 'S3';
REQ.FR3.type = 'Functional';
REQ.FR3.acceptance_value = 0.05;
REQ.FR3.acceptance_units = 's';
REQ.FR3.source = 'ISO 26262: Functional Safety (safe state requirement)';
REQ.FR3.rationale = 'Quick fault detection prevents unsafe operation';

%% ===================================================================
%% NON-FUNCTIONAL REQUIREMENTS (How WELL the system does it)
%% ===================================================================

% NFR1: Completion Time (Performance)
REQ.NFR1.id = 'R-TIME';
REQ.NFR1.title = 'Mission Completion Time';
REQ.NFR1.statement = 'In Scenario S1 (nominal), the system shall complete a 5 m track in <= 45 seconds';
REQ.NFR1.scenario = 'S1';
REQ.NFR1.type = 'Non-Functional (Performance)';
REQ.NFR1.acceptance_value = 45;
REQ.NFR1.acceptance_units = 's';
REQ.NFR1.source = 'Performance specification (mission requirement)';
REQ.NFR1.rationale = 'Balances speed with tracking accuracy';

% NFR2: Tracking Quality (IAE - Integrated Absolute Error)
REQ.NFR2.id = 'R-IAE';
REQ.NFR2.title = 'Tracking Error Quality';
REQ.NFR2.statement = 'In Scenario S1, the integrated absolute error (IAE) of line position shall be <= 0.5 m*s';
REQ.NFR2.scenario = 'S1';
REQ.NFR2.type = 'Non-Functional (Quality)';
REQ.NFR2.acceptance_value = 0.5;
REQ.NFR2.acceptance_units = 'm*s';
REQ.NFR2.source = 'Quality specification (control performance)';
REQ.NFR2.rationale = 'IAE measures cumulative tracking error over entire mission';

% NFR3: Energy Efficiency
REQ.NFR3.id = 'R-ENERGY';
REQ.NFR3.title = 'Energy Efficiency';
REQ.NFR3.statement = 'In Scenario S1, the normalized input effort (integral of |u_L| + |u_R|) shall be <= 20 units';
REQ.NFR3.scenario = 'S1';
REQ.NFR3.type = 'Non-Functional (Sustainability)';
REQ.NFR3.acceptance_value = 20;
REQ.NFR3.acceptance_units = 'units';
REQ.NFR3.source = 'ISO 14040/14044: LCA (environmental consideration)';
REQ.NFR3.rationale = 'Minimize battery consumption for sustainability';

% NFR4: Safe State Behavior (Speed Cap in Fault Mode)
REQ.NFR4.id = 'R-SAFE-STATE';
REQ.NFR4.title = 'Safe State Speed Limit';
REQ.NFR4.statement = 'In Scenario S3 (sensor fault), the system shall not exceed 0.45 m/s speed during fault';
REQ.NFR4.scenario = 'S3';
REQ.NFR4.type = 'Non-Functional (Safety)';
REQ.NFR4.acceptance_value = 0.45;
REQ.NFR4.acceptance_units = 'm/s';
REQ.NFR4.source = 'ISO 26262: Functional Safety (degraded mode operation)';
REQ.NFR4.rationale = 'Reduced speed in fault mode maintains safe operation';

%% ===================================================================
%% REQUIREMENTS-TO-TEST MATRIX (RTM)
%% Each requirement MUST map to at least one test
%% ===================================================================

% RTM Row 1: Tracking accuracy
RTM(1).req_id = 'R-TRACKING';
RTM(1).test_id = 'T-S1-TRACK';
RTM(1).scenario = 'S1';
RTM(1).method = 'Test';  % T=Test, I=Inspection, A=Analysis, S=Simulation
RTM(1).metric = 'max|e_line|';
RTM(1).acceptance_criterion = '<= 0.05 m';
RTM(1).evidence = 'CSV log: e_line time series + plot';

% RTM Row 2: Control rate
RTM(2).req_id = 'R-CTRL-RATE';
RTM(2).test_id = 'T-S1-RATE';
RTM(2).scenario = 'S1/S3';
RTM(2).method = 'Inspection';
RTM(2).metric = 'dt between samples';
RTM(2).acceptance_criterion = '= 0.01 s (100 Hz)';
RTM(2).evidence = 'Log timestamp analysis';

% RTM Row 3: Fault detection
RTM(3).req_id = 'R-FAULT-DETECT';
RTM(3).test_id = 'T-S3-FAULT';
RTM(3).scenario = 'S3';
RTM(3).method = 'Test';
RTM(3).metric = 'time to speed cap';
RTM(3).acceptance_criterion = '<= 0.05 s';
RTM(3).evidence = 'CSV log: t_fault -> t_speed_cap';

% RTM Row 4: Completion time
RTM(4).req_id = 'R-TIME';
RTM(4).test_id = 'T-S1-TIME';
RTM(4).scenario = 'S1';
RTM(4).method = 'Test';
RTM(4).metric = 'mission completion time';
RTM(4).acceptance_criterion = '<= 45 s';
RTM(4).evidence = 'Log: final timestamp';

% RTM Row 5: Tracking quality (IAE)
RTM(5).req_id = 'R-IAE';
RTM(5).test_id = 'T-S1-IAE';
RTM(5).scenario = 'S1';
RTM(5).method = 'Analysis';
RTM(5).metric = 'IAE = sum(|e_line|*dt)';
RTM(5).acceptance_criterion = '<= 0.5 m*s';
RTM(5).evidence = 'CSV log: e_line -> post-process integral';

% RTM Row 6: Energy efficiency
RTM(6).req_id = 'R-ENERGY';
RTM(6).test_id = 'T-S1-ENERGY';
RTM(6).scenario = 'S1';
RTM(6).method = 'Analysis';
RTM(6).metric = 'effort = sum((|u_L|+|u_R|)*dt)';
RTM(6).acceptance_criterion = '<= 20 units';
RTM(6).evidence = 'CSV log: u_L, u_R -> integral';

% RTM Row 7: Safe state speed cap
RTM(7).req_id = 'R-SAFE-STATE';
RTM(7).test_id = 'T-S3-SAFE';
RTM(7).scenario = 'S3';
RTM(7).method = 'Test';
RTM(7).metric = 'max(v) during fault window';
RTM(7).acceptance_criterion = '<= 0.45 m/s';
RTM(7).evidence = 'CSV log: v time series during fault';

%% Display summary
disp('[OK] Requirements and RTM loaded');
disp(['  Functional Requirements (FR): 3']);
disp(['  Non-Functional Requirements (NFR): 4']);
disp(['  Total Requirements: 7']);
disp(['  RTM rows (Req -> Test mapping): ', num2str(length(RTM))]);
disp(' ');

% Display RTM table for inspection
disp('RTM Table (Requirements to Tests):');
RTM_table = table({RTM.req_id}', {RTM.test_id}', {RTM.scenario}', ...
    {RTM.method}', {RTM.metric}', {RTM.acceptance_criterion}', ...
    'VariableNames', {'ReqID', 'TestID', 'Scenario', 'Method', 'Metric', 'Acceptance'});
disp(RTM_table);

%% RTM:
% 1. FRs describe FUNCTIONS (what), NFRs describe QUALITIES (how well)
% 2. Every requirement has a scenario, value, units, and source
% 3. RTM ensures every requirement is testable (no orphan requirements)
% 4. Evidence types: CSV logs, plots, calculations (post-processing)
% 5. Standards (ISO 26262, ISO 14040) drive some requirements
