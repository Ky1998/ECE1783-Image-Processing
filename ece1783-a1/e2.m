clc; clear; close all;

% Please ensure additional project paths aare added to the project config
% input/
% funct/

% Set the video information
vid_seq = 'foreman_cif-1.yuv';
width  = 352;
height = 288;
ratio = "4:2:0";
num_frames = 300;
format = ".yuv";

% Read the video sequence in to separate channels
% Each returns [channel_heights, channel_widths, num_frames]
[Y,U,V] = loadYUV(vid_seq, height, width, ratio, num_frames, format);
save("Y", "Y")

i_array = [2, 8, 64];
for n = 1:length(i_array)
    Y_avg = compute_Y_average(Y, i_array(n));
    save(strcat("Y_avg", int2str(i_array(n))), "Y_avg")
    psnr_sum = 0.0;
    for frame = 1:num_frames
        psnr_sum = psnr_sum + compute_psnr(Y(:,:,frame), Y_avg(:,:,frame));
    end
    psnr_avg = psnr_sum / num_frames;
    display(psnr_avg);
end