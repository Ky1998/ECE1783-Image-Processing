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

% Sample frames from Y
figure;
c = 0;  % counter
for frame = 1:15:num_frames
    c = c + 1;
    subplot(4,5,c), imshow(Y(:,:,frame));
    title(['frame #', num2str(frame)]);
end

% Upsample U and V channel from 4:2:0 to 4:4:4
[U_up, V_up] = upsample420(U, V);

% Test compute_Y_average
Y_avg = compute_Y_average(Y, 2);

% Conver to RGB
[R, G, B] = conv_YUV_RGB_444(Y_avg, U_up, V_up, 3);

% Sample frames
figure;
c = 0;  % counter
for frame = 1:15:num_frames
    c = c + 1;
    img_rgb = uint8(zeros(height, width, 3));
    img_rgb(:, :, 1) = R(:,:,frame);
    img_rgb(:, :, 2) = G(:,:,frame);
    img_rgb(:, :, 3) = B(:,:,frame);
    subplot(4,5,c), imshow(img_rgb);
    title(['frame #', num2str(frame)]);
end




