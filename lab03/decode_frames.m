function decoded = decode_frames(filename)
% DECODE_FRAMES  Parse a binary sensor stream and return valid frames.
%
% ╔══════════════════════════════════════════════════════════════════╗
% ║  INSTRUCTOR-PROVIDED — DO NOT MODIFY THIS FILE.                 ║
% ║  This function is complete and fully tested.                    ║
% ║  Your task is to USE it in lab03_scaffold.m, not to edit it.    ║
% ╚══════════════════════════════════════════════════════════════════╝
%
% decoded = decode_frames(filename)
%
% Reads the binary file at `filename`, finds all 10-byte frames that pass
% the three validity checks, decodes engineering values, and returns a
% table with one row per valid frame.
%
% Output table columns:
%   run_id        uint8   Run identifier (1–255)
%   t             double  Reconstructed time (s), 0-indexed per run_id
%   t_amb_degC    double  Ambient temperature (°C)
%   setpoint_degC double  Setpoint (°C)
%
%   Frames are DISCARDED (not counted in output) if:
%     - byte 1 ~= 0xA5  (bad start byte)
%     - byte 10 ~= 0x5A (bad end byte)
%     - CRC-16 mismatch  (bytes 7–8 do not match crc16(bytes 1–7))
%
% ── TASK 1A: Frame boundary detection ────────────────────────────────────────
% ── TASK 1B: Byte extraction + engineering-unit scaling ──────────────────────
% ── TASK 1C: CRC-16 validation (crc16.m is provided) ─────────────────────────
% ── TASK 1D: Write decoded.csv from the returned table ───────────────────────

    START_BYTE = uint8(0xA5);
    END_BYTE   = uint8(0x5A);
    FRAME_LEN  = 10;
    SCALE      = 0.005;

    % ── Read entire file as uint8 ─────────────────────────────────────────────
    fid = fopen(filename, 'rb');
    if fid == -1
        error('FileNotFoundError:Cannot open "%s".', filename);
    end
    raw = fread(fid, Inf, 'uint8=>uint8');
    fclose(fid);
    raw = raw(:);   % ensure column vector

    n_bytes = numel(raw);
    expected_frames = floor(n_bytes / FRAME_LEN);

    % ── TASK 1A: Frame boundary detection ────────────────────────────────────
    % Frames are fixed-length (10 bytes) and start at byte offsets 0,10,20,...
    % No need to scan for start bytes — just stride through the file.
    % (If the file were variable-length, scanning would be required.)

    run_ids  = zeros(expected_frames, 1, 'uint8');
    t_ambs   = zeros(expected_frames, 1);
    setpts   = zeros(expected_frames, 1);
    valid    = false(expected_frames, 1);

    for k = 1:expected_frames
        base = (k-1) * FRAME_LEN + 1;   % MATLAB 1-indexed
        fb   = raw(base : base + FRAME_LEN - 1);   % 10-byte frame

        % Check start and end bytes
        if fb(1) ~= START_BYTE || fb(10) ~= END_BYTE
            continue   % discard — bad framing
        end

        % ── TASK 1C: CRC validation ───────────────────────────────────────────
        stored_crc = uint16(bitor(bitshift(uint16(fb(8)), 8), uint16(fb(9))));
        computed_crc = crc16(fb(1:7));
        if computed_crc ~= stored_crc
            continue   % discard — CRC error
        end

        % ── TASK 1B: Extract and scale ────────────────────────────────────────
        run_id   = fb(3);
        raw_amb  = uint16(bitor(bitshift(uint16(fb(4)), 8), uint16(fb(5))));
        raw_sp   = uint16(bitor(bitshift(uint16(fb(6)), 8), uint16(fb(7))));

        t_amb_degC   = double(raw_amb) * SCALE;
        setpt_degC   = double(raw_sp)  * SCALE;

        run_ids(k)  = run_id;
        t_ambs(k)   = t_amb_degC;
        setpts(k)   = setpt_degC;
        valid(k)    = true;
    end

    % Keep only valid rows
    run_ids = run_ids(valid);
    t_ambs  = t_ambs(valid);
    setpts  = setpts(valid);

    % ── Reconstruct time axis per run (dt = 0.1 s) ───────────────────────────
    t_vec = zeros(sum(valid), 1);
    for rid = unique(run_ids)'
        mask        = run_ids == rid;
        n           = sum(mask);
        t_vec(mask) = (0 : n-1)' * 0.1;
    end

    % ── Build output table ────────────────────────────────────────────────────
    decoded = table(run_ids, t_vec, t_ambs, setpts, ...
        'VariableNames', {'run_id','t','t_amb_degC','setpoint_degC'});

    fprintf('decode_frames: %d frames read, %d valid (%.1f%% rejected)\n', ...
            expected_frames, height(decoded), ...
            100*(1 - height(decoded)/expected_frames));
end
