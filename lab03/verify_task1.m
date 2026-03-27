% VERIFY_TASK1.M
% Run this to confirm decode_frames.m is working correctly.
% All checks must print PASS before proceeding to Task 2.
%
% Prerequisites: crc16.m, decode_frames.m, sensor_stream.bin
% in the same folder (or on the MATLAB path).

clear; clc;

% ── CHECK 1 — CRC helper ─────────────────────────────────────────────────
bytes_example = uint8([0xA5 0x0A 0x01 0x0F 0xA0 0x2E 0xE0]);
computed = crc16(bytes_example);
expected = uint16(0xD080);
fprintf('CHECK 1  — crc16 on example frame: 0x%04X  (expect 0xD080)  %s\n', ...
        computed, ternary('PASS','FAIL', computed == expected));

% ── CHECK 2 — File size ───────────────────────────────────────────────────
info = dir('sensor_stream.bin');
fprintf('CHECK 2  — File size: %d bytes  (expect 39030)  %s\n', ...
        info.bytes, ternary('PASS','FAIL', info.bytes == 39030));

% ── CHECK 3 — decode_frames row count ────────────────────────────────────
decoded = decode_frames('sensor_stream.bin');
fprintf('CHECK 3  — decode_frames returned table: %d rows  (expect 3741)  %s\n', ...
        height(decoded), ternary('PASS','FAIL', height(decoded) == 3741));

% ── CHECK 4 — Required columns present ───────────────────────────────────
expected_cols = {'run_id','t','t_amb_degC','setpoint_degC'};
cols_ok = all(ismember(expected_cols, decoded.Properties.VariableNames));
fprintf('CHECK 4  — All 4 columns present: %s\n', ternary('PASS','FAIL', cols_ok));

% ── CHECK 5 — Three run IDs ───────────────────────────────────────────────
run_ids = unique(decoded.run_id);
fprintf('CHECK 5  — Unique run_ids: %s  (expect [1 2 3])  %s\n', ...
        mat2str(run_ids), ternary('PASS','FAIL', isequal(run_ids, [1;2;3])));

% ── CHECK 6 — Run 1 row count ─────────────────────────────────────────────
n1 = sum(decoded.run_id == 1);
fprintf('CHECK 6  — Run 1 rows: %d  (expect 863 ±5)  %s\n', ...
        n1, ternary('PASS','FAIL', abs(n1 - 863) <= 5));

% ── CHECK 7 — Run 2 row count ─────────────────────────────────────────────
n2 = sum(decoded.run_id == 2);
fprintf('CHECK 7  — Run 2 rows: %d  (expect 1151 ±5)  %s\n', ...
        n2, ternary('PASS','FAIL', abs(n2 - 1151) <= 5));

% ── CHECK 8 — Run 3 row count (NEW) ──────────────────────────────────────
n3 = sum(decoded.run_id == 3);
fprintf('CHECK 8  — Run 3 rows: %d  (expect 1727 ±5)  %s\n', ...
        n3, ternary('PASS','FAIL', abs(n3 - 1727) <= 5));

% ── CHECK 9 — Run 1 first frame values ───────────────────────────────────
r1   = decoded(decoded.run_id == 1, :);
sp0  = r1.setpoint_degC(1);
amb0 = r1.t_amb_degC(1);
fprintf('CHECK 9  — Run 1 first setpoint: %.1f°C  (expect 60.0)  %s\n', ...
        sp0,  ternary('PASS','FAIL', abs(sp0  - 60.0) < 0.01));
fprintf('           Run 1 first t_amb:    %.1f°C  (expect 20.0)  %s\n', ...
        amb0, ternary('PASS','FAIL', abs(amb0 - 20.0) < 0.01));

% ── CHECK 10 — Run 2 final setpoint (ramp end value) ─────────────────────
r2   = decoded(decoded.run_id == 2, :);
sp_end = r2.setpoint_degC(end);
fprintf('CHECK 10 — Run 2 final setpoint: %.2f°C  (expect ~80.0)  %s\n', ...
        sp_end, ternary('PASS','FAIL', abs(sp_end - 80.0) < 0.5));

% ── CHECK 11 — Run 3 setpoint is sustained at 95°C ───────────────────────
r3       = decoded(decoded.run_id == 3, :);
sp3_min  = min(r3.setpoint_degC);
sp3_max  = max(r3.setpoint_degC);
fprintf('CHECK 11 — Run 3 setpoint range: [%.1f, %.1f]°C  (expect ~95.0)  %s\n', ...
        sp3_min, sp3_max, ternary('PASS','FAIL', abs(sp3_max - 95.0) < 1.0));

% ── CHECK 12 — decoded.csv written ───────────────────────────────────────
writetable(decoded, 'decoded.csv');
info2 = dir('decoded.csv');
fprintf('CHECK 12 — decoded.csv written: %d bytes  %s\n', ...
        info2.bytes, ternary('PASS','FAIL', info2.bytes > 1000));

fprintf('\n--- All checks complete ---\n');

% ── Helper ───────────────────────────────────────────────────────────────
function s = ternary(s_true, s_false, cond)
    if cond; s = s_true; else; s = s_false; end
end