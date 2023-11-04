function recon_full_frame = decode_iframe(encoded_iframe, encoded_mode, frame_size, i)

% Perform intra-frame decode from a compressed the current frame
% without dependance on previous frame

% Input
% encoded_iframe: a matrix to represent frame encoded with intra predictors
% in a dimension of [i+1, # of blocks], where i is the left-i or top i
% broader, and the additional integer to represent mode 0 - hortizontal, or
% 1 - vertical
% frame_size: in a format of[height, width]
% i: size of the ixi block (ex, 2, 8, 64)

% Output:
% recon_full_frame: is the frame (all pixals)

% encoded_iframe
% encoded_mode

frame_height = frame_size(1);
frame_width = frame_size(2);

padded_frame_height = i * idivide(int32(frame_height), i, 'ceil');
padded_frame_width = i * idivide(int32(frame_width), i, 'ceil');

padded_frame = int32(zeros([padded_frame_height, padded_frame_width]));

idx_block = 0;
for x = 1:i:padded_frame_height
    for y = 1:i:padded_frame_width
        % Increment block counter for this iteration
        idx_block = idx_block + 1;

        predictor = encoded_iframe(:,idx_block);
        mode = encoded_mode(1,idx_block);

        if mode == 0 % horizontal mode
            % remove mode digit and transpose
            left_i = predictor;
            % Now expand the left_i column vector horizontally to get predictive block 
            pred_block_0 = repmat(left_i, 1, i);
            padded_frame(x:x+i-1,y:y+i-1) = pred_block_0;
        else % vertical mode
            top_i = predictor'; 
            % Now expand the top_i row vector vertically to get predictive block 
            pred_block_1 = repmat(top_i, i, 1);
            padded_frame(x:x+i-1,y:y+i-1) = pred_block_1;
        end
    end
end

recon_full_frame = padded_frame(1:frame_height, 1:frame_width);



