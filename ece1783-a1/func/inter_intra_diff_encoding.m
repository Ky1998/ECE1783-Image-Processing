function diff_encoding = inter_intra_diff_encoding(frame_type, MVs_Modes)
% Differential encoding for both P-frame or I-frame

% Input:
% 
% frame_type: P (Inter), or I (Intra)
% 
% MVs_Modes: 
% for P frame, input MVs in order as array [Last_MV, Curr_MV],
% for first block, enter Last_MV as [0,0]
% 
% for I frame, input Modes in order as array [Last_Mode, Curr_Mode],
% for first block, enter Last_Mode as [0]
% Note that for mode, 0 - horizontal, 1 - vertical

% Output:
% 
% diff_encoding: 1 value of I-frame, 2 values for P-frame

MVs_Modes = int32(MVs_Modes);

if frame_type == "P"
    if size(MVs_Modes, 2) ~= 4
        ME = MException('inter_intra_diff_encoding:InputSizeMissMatched', ...
            'for P frame differential, MVs_Modes should a matrix of 1x4, in the form of [[x_0 y_0] [x_1 y_1]]');
        throw(ME);
    end
    Last_MV = MVs_Modes(1:2);
    Curr_MV = MVs_Modes(3:4);
    diff_encoding = Curr_MV - Last_MV;
elseif frame_type == "I"
    if size(MVs_Modes, 2) ~= 2
        ME = MException('inter_intra_diff_encoding:InputSizeMissMatched', ...
            'for I frame differential, MVs_Modes should a matrix of 1x2, in the form of [m_0 m_1]');
        throw(ME);
    end
    Last_Mode = MVs_Modes(1);
    Curr_Mode = MVs_Modes(2);
    diff_encoding = Curr_Mode - Last_Mode;
end

