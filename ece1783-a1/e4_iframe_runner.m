clc; clear; close all;

% Please ensure additional project paths aare added to the project config
% input/
% funct/

% Set the video information

% Sample 1 = y4m format with headers
% vid_seq = 'foreman_cif.y4m';
% width  = 352;
% height = 288;
% ratio = "4:2:0";
% num_frames = 300;
% format = ".y4m"

% Sample 2 - yuv sequence
vid_seq = 'foreman_cif.y4m';
width  = 352;
height = 288;
ratio = "4:2:0";
num_frames = 300;
format = ".y4m";


% Read the video sequence in to separate channels
% Each returns [channel_heights, channel_widths, num_frames]
[Y,U,V] = loadYUV(vid_seq, height, width, ratio, num_frames, format); 

% Sample frames from Y
figure;
c = 0;  % counter
for frame = 1:15:15
    c = c + 1;
    curr_frame = uint8(Y(:,:,frame));
    subplot(1,1,c), imshow(curr_frame);
    title(['frame #', num2str(frame)]);
end


% Sample frames from Y
figure;
c = 0;  % counter
i = 8;
for frame = 1:15:15
    c = c + 1;
    curr_frame = Y(:,:,frame);
    [encoded_iframe, encoded_mode] = encode_iframe(curr_frame, i);
    encoded_iframe
    encoded_mode
    recon_iframe = uint8(decode_iframe(encoded_iframe, encoded_mode, size(Y(:,:,frame)), i));
    subplot(1,1,c), imshow(recon_iframe);
    title(['frame #', num2str(frame)]);
end
