function [encoded_iframe, encoded_mode] = encode_iframe(curr_full_frame, i)

% Perform intra-frame encoding as a way to compress the current frame
% without dependance on previous frame

% Input:
% curr_full_frame: is the frame (all pixals) at current time T
% i: size of the ixi block (ex, 2, 8, 64)

% Output:
% encoded_iframe: a matrix to represent frame encoded with intra predictors
% in a dimension of [i, # of blocks], where i is the left-i or top i
% broader, 
% encoded_mode: a matrix to represent mode of encoding in a dimension of
% [1, # of blocks], where mode 0 - hortizontal, or 1 - vertical

[frame_height, frame_width] = size(curr_full_frame);
padded_frame_height = i * idivide(int32(frame_height), i, 'ceil');
padded_frame_width = i * idivide(int32(frame_width), i, 'ceil');

% start with a padded frame with 128 on all pixals
padded_curr_full_frame = int32(zeros([padded_frame_height, padded_frame_width])) + 128;

% then transfer the values from the original full frame
padded_curr_full_frame(1:frame_height, 1:frame_width) = curr_full_frame;

num_blocks = size(1:i:frame_height, 2) * size(1:i:frame_width, 2);
encoded_iframe = int32(zeros([i, num_blocks]));
% encoded_iframe = cell(1, num_blocks);
encoded_mode = uint8(zeros([1, num_blocks]));
% encoded_mode = cell(1, num_blocks);

idx_block = 0;
for x = 1:i:padded_frame_height
    for y = 1:i:padded_frame_width
        % Increment block counter for this iteration
        idx_block = idx_block + 1;

        % setting up block boundary index position
        block_x_start = x;
        % block_x_end = min(block_x_start + i - 1, frame_height);
        block_x_end = block_x_start + i - 1;
        block_y_start = y;
        % block_y_end = min(block_y_start + i - 1, frame_width);
        block_y_end = block_y_start + i - 1;
        
        % get the content of blocks
        % recon_block = recon_full_frame(block_x_start:block_x_end, ...
        %     block_y_start:block_y_end);
        curr_block = padded_curr_full_frame(block_x_start:block_x_end, ...
            block_y_start:block_y_end);
        
        % set up intra-frame predictive block content with two modes
        % mode 0, horizontal, copy from left broader
        left_i = int32(zeros(i,1));
        if block_y_start == 1 % at left boundary
            left_i = left_i + 128; % set every pixal to 0+128 = 128
        else
            % copy from border of the block on current frame
            left_i = padded_curr_full_frame(block_x_start:block_x_end, block_y_start - 1);
        end
        % Now expand the left_i column vector horizontally to get predictive block 
        pred_block_0 = repmat(left_i, 1, i);
        % Compute MAE for mode 0 by using the actual current block to
        % subtract the pred_block_0 that expanded from left_i
        mae_0 = sum(abs(curr_block - pred_block_0), [1 2]);

        % mode 1, Vertical, copy from top broader
        top_i = int32(zeros(1,i));
        if block_x_start == 1 % at top boundary
            top_i = top_i + 128; % set every pixal to 0+128 = 128
        else
            % copy from border of the block on current frame
            top_i = padded_curr_full_frame(block_x_start - 1,block_y_start:block_y_end);
        end
        % Now expand the top_i row vector vertically to get predictive block 
        pred_block_1 = repmat(top_i, i, 1);
        % Compute MAE for mode 0 by using the actual current block to
        % subtract the pred_block_0 that expanded from left_i
        mae_1 = sum(abs(curr_block - pred_block_1), [1 2]);

        % Compare and decide on which mode to use
        % and depending on the mode, take the corresponding left_i or top_i
        % predictor pixals
        if mae_0 < mae_1 % mode 0
            predictor = [left_i']; % append predictor pixals with mode digit
            mode = 0;
        else % mode 1 , need to transpose
            predictor = [top_i]; % append predictor pixals with mode digit
            mode = 1;
        end

        % store the predictor, which is size i+1, to the proper block
        % number of the encoded iframe
        encoded_iframe(:, idx_block) = predictor;
        encoded_mode(1, idx_block) = mode;

    end
end


