clc; clear; close all;

% Please ensure additional project paths aare added to the project config
% input/
% funct/

% Set the video information
vid_seq = 'foreman_cif.y4m';
width  = 352;
height = 288;
ratio = "4:2:0";
num_frames = 10;
format = ".y4m";

% Read the video sequence in to separate channels
% Each returns [channel_heights, channel_widths, num_frames]
[Y,U,V] = loadYUV(vid_seq, height, width, ratio, num_frames, format); 

% Upsample U and V channel from 4:2:0 to 4:4:4
[U_up, V_up] = upsample420(U, V);

I = 8;
N = 3;
R = 4;
[rows, cols, num_frames]=size(Y);

mae = 0;

Y_new = int32(zeros(rows, cols, num_frames));
Grey_frame = int32(zeros(rows, cols)) + 128;
recon_full_frame = Grey_frame;
rows = int32(rows);
cols = int32(cols);
MV = int32(zeros(2, idivide(rows,I,"ceil") * idivide(cols,I,"ceil"), num_frames));
RES = int32(zeros(I, I, idivide(rows,I,"ceil") * idivide(cols,I,"ceil"), num_frames + 1));
for frame = 1:num_frames
    block_idx = 1;
    for r = 1:idivide(rows,I,"ceil")
        for c = 1:idivide(cols,I,"ceil")
            % Find predicted block
            [prediction_block_x_y, smallest_mae, curr_block, search_block] = find_predicted_block(Y(:,:,frame), 1 + r * I - I, 1 + c * I - I, I, recon_full_frame, R);
            mae = mae + smallest_mae;
            % Approximate residue
            [approximated_residual_block, reconstructed_block] = approximated_residual(curr_block, recon_full_frame(prediction_block_x_y(1):prediction_block_x_y(1)+I-1,prediction_block_x_y(2):prediction_block_x_y(2)+I-1), N);
            % Save motion vector and residue
            MV(1,block_idx,frame) = prediction_block_x_y(1) - (1 + r * I - I);
            MV(2,block_idx,frame) = prediction_block_x_y(2) - (1 + c * I - I);
            RES(:,:,block_idx,frame) = approximated_residual_block;
            block_idx = block_idx + 1;
        end
    end
    % Decode/Reconstruct this frame
    Y_new(:,:,frame) = reconstruct(RES(:,:,:,frame), MV(:,:,frame), recon_full_frame, I, rows, cols);
    recon_full_frame = Y_new(:,:,frame);
end

display(mae / double(rows * cols * num_frames));

psnr_sum = 0.0;
for frame = 1:num_frames
    psnr_sum = psnr_sum + compute_psnr(Y(:,:,frame), Y_new(:,:,frame));
end
psnr_avg = psnr_sum / num_frames;
display(psnr_avg);

% Exercise 3 part 3
A = uint8(Y(:,:,2) - Y_new(:,:,1));
figure;
c = 1;
subplot(1,1,c), imshow(A);
title('A');

D = reconstruct(RES(:,:,:,frame + 1), MV(:,:,2), Y_new(:,:,1), I, rows, cols);
B = uint8(Y(:,:,2) - D);
figure;
c = 1;
subplot(1,1,c), imshow(B);
title('B');

C = uint8(D);
figure;
c = 1;
subplot(1,1,c), imshow(C);
title('C');