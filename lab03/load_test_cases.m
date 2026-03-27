function cases = load_test_cases(filename)
% LOAD_TEST_CASES  Read and validate test_cases.csv
%
% INPUT : filename — path to CSV file
% OUTPUT: cases    — validated MATLAB table, Nx7
%
% Named errors this function must throw:
%   MC3113:FileNotFound    — file does not exist
%   MC3113:MissingColumn   — a required column is absent
%   MC3113:InvalidMetric   — metric string not in the valid set
%   MC3113:InvalidOperator — operator not in the valid set---
%
% Named error syntax:
%   error("MC3113:FileNotFound", "File not found: %s", filename)

VALID_METRICS   = ["rise_time_10_90", "ss_error_last20s", ...
                   "max_heater_above_85", "ramp_tracking_lag"];
VALID_OPERATORS = ["<=", ">=", "<", ">", "=="];
REQUIRED_COLS   = {'test_id','req_id','description', ...
                   'run_id','metric','operator','threshold'};

% ── TODO 1a — check file exists; throw MC3113:FileNotFound if not ────
% Hint: use isfile(filename)
% if ~isfile(filename)
%     error("MC3113:FileNotFound", "File not found: %s", filename);
% end
% >>> YOUR CODE HERE <<<


% ════════════════════════════════════════════════════════════════════
% PROVIDED — do NOT modify this block.
% Reads the CSV with correct column types and strips header whitespace.
opts = detectImportOptions(filename, "TextType", "string");
opts.VariableNames = strtrim(opts.VariableNames);   % guards against spaces after commas
opts = setvartype(opts, {"run_id","threshold"}, "double");
cases = readtable(filename, opts);
% END PROVIDED ════════════════════════════════════════════════════════


% ── TODO 1b — check all required columns are present ────────────────
% Loop over REQUIRED_COLS. For each column name, check whether it is
% in cases.Properties.VariableNames.
% Throw MC3113:MissingColumn if any column is absent.
% Hint: ismember(colName, cases.Properties.VariableNames)
% >>> YOUR CODE HERE <<<


% ── TODO 1c — validate metric and operator strings row by row ────────
% Loop over each row (1 : height(cases)).
% Check cases.metric(r) against VALID_METRICS.
% Check cases.operator(r) against VALID_OPERATORS.
% Throw MC3113:InvalidMetric / MC3113:InvalidOperator if invalid.
% Hint: ismember(cases.metric(r), VALID_METRICS)
% >>> YOUR CODE HERE <<<

end