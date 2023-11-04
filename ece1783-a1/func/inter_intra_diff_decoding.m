function curr_MV_Mode = inter_intra_diff_decoding(diff_encoding, frame_type, last_MV_Mode)
% Differential encoding for both P-frame or I-frame

% Input:
% 
% diff_encoding: 1 value of I-frame, 2 values for P-frame
%
% frame_type: P (Inter), or I (Intra)
% 
% last_MV_Mode:
% for P frame, input Last_MV, in the form of [x y]
% for I frame, input Mode: 0 - horizontal, 1 - vertical

% Output:
% curr_MV_Mode: return either next MV, or Mode
% 

diff_encoding = int32(diff_encoding);
last_MV_Mode = int32(last_MV_Mode);

if frame_type == "P"
    if size(last_MV_Mode, 2) ~= 2 || size(diff_encoding, 2) ~= 2
        ME = MException('inter_intra_diff_decoding:InputSizeMissMatched', ...
            'for P frame differential, diff_encoding and last_MV_Mode both should a matrix of 1x2, in the form of [x y]');
        throw(ME);
    end

elseif frame_type == "I"
    if size(last_MV_Mode, 2) ~= 1 || size(diff_encoding, 2) ~= 1
        ME = MException('inter_intra_diff_decoding:InputSizeMissMatched', ...
            'for I frame differential, diff_encoding and last_MV_Mode both should a matrix of 1x1, in the form of [x]');
        throw(ME);
    end
end

curr_MV_Mode = last_MV_Mode + diff_encoding;

end

