function [y, u, v] = loadYUV(vid_seq, height, width, ratio, num_frames, format)

% set offsets for file and frame
if format==".y4m"
    off_set = [44 6];
else % assuming to be yuv sequence without file and frame header
    off_set = [0 0];
end

% Loading a YUV video sequence files and return all individual channels
% subsampling ratio supported are "4:4:4" (default), "4:2:2", and "4:2:0"
vid_file = fopen(vid_seq,'r');
vid = fread(vid_file,'*uchar');
vid = vid(off_set(1)+1:length(vid));

% Set up dimensions for each channel, start with no subsampling
channel_heights = dictionary('y', height, 'u', height, 'v', height);
channel_widths = dictionary('y', width, 'u', height, 'v', height);
% In case subsampled, update the heights and width for chroma channels
if ratio=="4:2:0"
    channel_heights('u') = height/2;
    channel_heights('v') = height/2;
    channel_widths('u') = width/2;
    channel_widths('v') = width/2;
elseif ratio=="4:2:2"
    channel_heights('u') = height;
    channel_heights('v') = height;
    channel_widths('u') = width/2;
    channel_widths('v') = width/2;
end

% Total frame_length should be just the sum of 3 channels sizes
% each frame with first 5 bytes as frame header
frame_length = off_set(2) + channel_heights('y') * channel_widths('y') + channel_heights('u') * channel_widths('u') + channel_heights('v') * channel_widths('v');

% Initialize all channels to zero's
y = int32(zeros(channel_heights('y'), channel_widths('y'), num_frames));
u = int32(zeros(channel_heights('u'), channel_widths('u'), num_frames));
v = int32(zeros(channel_heights('v'), channel_widths('v'), num_frames));

% frame_length
for curr_frame = 1:num_frames
    % curr_frame
    % Tokenizing the whole vid files into individual frames
    frame_content = vid((curr_frame-1)*frame_length+1:curr_frame*frame_length);
    y_start_idx = off_set(2)+1; % offset by 5 b/c the first 5 bytes are frame header
    y_end_idx = off_set(2) + channel_widths('y')*channel_heights('y');
    u_start_idx = y_end_idx+1;
    u_end_idx = y_end_idx+channel_widths('u')*channel_heights('u');
    v_start_idx = u_end_idx+1;
    v_end_idx = u_end_idx+channel_widths('v')*channel_heights('v');
    % Note that individual frames are "vertically placed", therefore we
    % need to inverse the frame

    y_image = reshape( ...
        frame_content(y_start_idx:y_end_idx), ...
        channel_widths('y'), ...
        channel_heights('y'))';
    u_image = reshape( ...
        frame_content(u_start_idx:u_end_idx),...
        channel_widths('u'), ...
        channel_heights('u'))';
    v_image = reshape( ...
        frame_content(v_start_idx:v_end_idx), ...
        channel_widths('v'), ...
        channel_heights('v'))';


    % y_image = reshape( ...
    %     frame_content(y_start_idx:y_end_idx), ...
    %     channel_heights('y'), ...
    %     channel_widths('y'));
    % u_image = reshape( ...
    %     frame_content(u_start_idx:u_end_idx),...
    %     channel_heights('u'), ...
    %     channel_widths('u'));
    % v_image = reshape( ...
    %     frame_content(v_start_idx:v_end_idx), ...
    %     channel_heights('v'), ...
    %     channel_widths('v'));
    % Assign the individual images per channel
    y(:,:,curr_frame) = int32(y_image);
    u(:,:,curr_frame) = int32(u_image);
    v(:,:,curr_frame) = int32(v_image);
end




