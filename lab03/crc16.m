function crc = crc16(data_bytes)
% CRC16  Compute CRC-16/CCITT-FALSE checksum.
%   crc = crc16(data_bytes)
%
%   data_bytes : uint8 row or column vector (the bytes to protect)
%   crc        : uint16 scalar checksum
%
%   Parameters:
%     Polynomial : 0x1021
%     Init value : 0xFFFF
%     Reflect in : false
%     Reflect out: false
%     Final XOR  : 0x0000
%
%   INSTRUCTOR-PROVIDED — do not modify.
%   Students call:  crc = crc16(frame_bytes(1:7))
%                   and compare to the value stored in frame_bytes(8:9).
%
%   Example (Run 1, t=0, T_amb=20°C, SP=60°C):
%     bytes = [0xA5 0x0A 0x01 0x0F 0xA0 0x2E 0xE0];
%     crc16(bytes)  % should return 0xD080 = 53376

    crc = uint32(0xFFFF);
    poly = uint32(0x1021);
    for k = 1:numel(data_bytes)
        b = uint32(data_bytes(k));
        crc = bitxor(crc, bitshift(b, 8));
        for bit = 1:8
            if bitand(crc, uint32(0x8000))
                crc = bitand(bitxor(bitshift(crc, 1), poly), uint32(0xFFFF));
            else
                crc = bitand(bitshift(crc, 1), uint32(0xFFFF));
            end
        end
    end
    crc = uint16(crc);
end
