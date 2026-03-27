function report_generator(cases, results, out_json, out_csv)
% REPORT_GENERATOR  Write lab03_report.json and lab03_coverage.csv.
%
% INPUTS
%   cases    : validated cases table (from load_test_cases)
%   results  : struct array of oracle results (one element per test case)
%   out_json : output filename string, e.g. 'lab03_report.json'
%   out_csv  : output filename string, e.g. 'lab03_coverage.csv'

n          = numel(results);
n_passed   = sum(strcmp({results.verdict}, 'PASS'));
n_failed   = n - n_passed;

% ── TODO 5a — build the per-result struct array for JSON ─────────────
% For each result in results(k), create a struct row(k) with these fields:
%
%   row(k).test_id     = results(k).test_id;        % string
%   row(k).req_id      = char(cases.req_id(k));      % string
%   row(k).description = char(cases.description(k)); % string
%   row(k).metric      = results(k).metric;          % string
%   row(k).measured    = results(k).measured;        % double
%   row(k).threshold   = results(k).threshold;       % double
%   row(k).operator    = results(k).operator;        % string
%   row(k).verdict     = results(k).verdict;         % string
%   row(k).margin      = results(k).margin;          % double
%
% IMPORTANT: DO NOT use req_id values (e.g. 'R-SAFE-01') as struct FIELD
% NAMES — hyphens crash jsonencode. Store them as STRING VALUES (as above).
%
% >>> YOUR CODE HERE <<<
% Example loop skeleton:
%   for k = 1:n
%       row(k).test_id = results(k).test_id;
%       ...
%   end


% ── TODO 5b — build the top-level report struct and encode to JSON ────
% The report struct must have these fields (in this order):
%   report.generated   = string(datetime('now','Format','yyyy-MM-dd''T''HH:mm:ss'));
%   report.total_cases = n;
%   report.passed      = n_passed;
%   report.failed      = n_failed;
%   report.results     = row;   % the struct array from TODO 5a
%
% Then encode and write to file.
% Hint: jsonencode(report, 'PrettyPrint', true)  — requires R2021b+
%
% >>> YOUR CODE HERE <<<
% Skeleton:
%   report.generated   = ...
%   report.total_cases = ...
%   report.passed      = ...
%   report.failed      = ...
%   report.results     = row;
%   json_str = jsonencode(report, 'PrettyPrint', true);
%   fid = fopen(out_json, 'w');
%   fprintf(fid, '%s\n', json_str);
%   fclose(fid);


% ── PROVIDED — write coverage CSV ────────────────────────────────────
% Builds a table from the results struct array and writes it.
% Do NOT modify this block.
req_ids      = string({cases.req_id(:)})';
descriptions = string({cases.description(:)})';
test_ids     = string({results.test_id})';
metrics      = string({results.metric})';
verdicts     = string({results.verdict})';
margins      = [results.margin]';

cov_table = table(req_ids, descriptions, test_ids, metrics, verdicts, margins, ...
    'VariableNames', {'req_id','description','test_id','metric','verdict','margin'});
writetable(cov_table, out_csv);
fprintf('      Coverage CSV written: %d row(s).\n', height(cov_table));

end