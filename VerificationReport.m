function VerificationReport(log_S1, m1, log_S3, m3, RTM)
%% VerificationReport - RTM Verification Summary
% MC3113 Mechatronic Systems Design
%
% PURPOSE: Generate a verification report showing which requirements
%          have been verified against acceptance criteria
%
% DEMONSTRATES:
% - Traceability: Requirement -> Test -> Evidence -> Pass/Fail
% - How RTM is used in practice during CDR/final verification
% - Digital thread: Requirements defined in Requirements_RTM.m,
%   tested in Scenario_S1/S3, results compiled here

fprintf('\n');
disp('===============================================');
disp('  RTM VERIFICATION SUMMARY');
disp('  MC3113 Line-Follower Digital Twin');
disp('===============================================');
fprintf('\n');

%% Collect all pass/fail results
test_results = [
    m1.pass_R_TIME;        % T-S1-TIME
    m1.pass_R_TRACKING;    % T-S1-TRACK
    m1.pass_R_IAE;         % T-S1-IAE
    m1.pass_R_ENERGY;      % T-S1-ENERGY
    m3.pass_R_SAFE_STATE   % T-S3-SAFE
];

test_names = {
    'T-S1-TIME (Completion Time)';
    'T-S1-TRACK (Max Line Error)';
    'T-S1-IAE (Tracking Quality)';
    'T-S1-ENERGY (Energy Efficiency)';
    'T-S3-SAFE (Safe State Speed Cap)'
};

req_ids = {
    'R-TIME';
    'R-TRACKING';
    'R-IAE';
    'R-ENERGY';
    'R-SAFE-STATE'
};

%% Display table
fprintf('%-12s %-35s %s\n', 'Req ID', 'Test Name', 'Result');
disp('---------------------------------------------------------------');
for i = 1:length(test_results)
    result_str = 'PASS';
    if ~test_results(i)
        result_str = 'FAIL';
    end
    fprintf('%-12s %-35s %s\n', req_ids{i}, test_names{i}, result_str);
end

disp('---------------------------------------------------------------');
n_pass = sum(test_results);
n_total = length(test_results);
pct_pass = 100 * n_pass / n_total;

fprintf('  Tests passed: %d / %d (%0.1f%%)\n', n_pass, n_total, pct_pass);
fprintf('\n');

if n_pass == n_total
    disp('  *** STATUS: ALL REQUIREMENTS VERIFIED ***');
    disp('  System is ready for CDR (Critical Design Review)');
else
    disp('  *** STATUS: SOME REQUIREMENTS NOT MET ***');
    disp('  Design iteration required before CDR');
end

disp('===============================================');
fprintf('\n');

%% Reports:
% 1. RTM is not just a document - it drives verification activities
% 2. Each "PASS" means: requirement defined -> test executed -> evidence collected
% 3. "FAIL" triggers design iteration (this is the V-model feedback loop)
% 4. In CA1, students will do the same for their assigned standard
% 5. Digital thread: all data comes from ICD-compliant signals
end
