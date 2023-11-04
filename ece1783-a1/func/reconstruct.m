function recon_frame = reconstruct(approx_residuals, mvs, prev_frame, i, rows, cols)
% Inputs

% approx_residuals: loaded from approximated residuals files with
% size=(i, i, #_of_blocks)
% where first two diemnsions contain the
% approximated residual values (i x i)

% mvs: loaded from the mv file
% size=(2, #_of_blocks)
% where the first dimension contains the prediction block's coord as pred_block_x_start, pred_block_y_start]

% prev_frame

% Outputs
% recon_frame: reconstructred frame

% get all blocks within current "frame"
block_idx = 1;
    
% start from an empty frame
recon_frame = int32(zeros(size(prev_frame)));

for r = 1:idivide(rows,i,"ceil")
    for c = 1:idivide(cols,i,"ceil")
        % get the residual
        block_residual = approx_residuals(:, :, block_idx);
        % get the predictive block from the MV and the previous frame
        pred_block_start_x = max((1 + r * i - i) + mvs(1, block_idx), 1);
        pred_block_start_y = max((1 + c * i - i) + mvs(2, block_idx), 1);
        pred_block = prev_frame(pred_block_start_x:pred_block_start_x+i-1, pred_block_start_y:pred_block_start_y+i-1);
        % start overlaying the residual to reconstruct and current frame
        recon_frame((1 + r * i - i):(1 + r * i - i)+i-1, (1 + c * i - i):(1 + c * i - i)+i-1) = pred_block + block_residual;
        % move to next block in the next iteration in order to unroll
        block_idx = block_idx + 1;

    end
end
