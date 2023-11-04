function [prediction_block_x_y, smallest_mae, curr_block, search_block] = find_predicted_block( ...
    curr_full_frame, ...
    curr_block_x_start, ...
    curr_block_y_start, ...
    i, ...
    recon_full_frame, ...
    r)
% Input:
% curr_full_frame: is the frame (all pixals) at current time T
% curr_block_x_start: start x coord of the current ixi block of curr_full_frame
% curr_block_y_start: start y coord of the current ixi block of curr_full_frame
% i: size of the ixi block (ex, 2, 8, 64)
% recon_full_frame: is the reconstructed frame at time T-1
% r: search range centered around the collocated block of reconstructed previous frame (1, 4, 8)
% Output:
% prediction_block_x_y: x & y coord of the predicted pixal in the recon previous frame
% curr_block: current block (content, not coord)
% search_block: search block (content, not coord)

frame_size = size(curr_full_frame);

% curr_full_frame is the complete frame of the current time step
% to locate the current block from teh frame, we need the to use
% curr_block_x_start, curr_block_x_end, and the size of the block i

% Submatrix to find the current block, make sure it does not go outside of
% the frame 
curr_block_x_end = curr_block_x_start+i-1;
if curr_block_x_end > frame_size(1)
    curr_block_x_end = frame_size(1);
end
curr_block_y_end = curr_block_y_start+i-1;
if curr_block_y_end > frame_size(2)
    curr_block_y_end = frame_size(2);
end

% curr_block = curr_full_frame( ...
%     curr_block_x_start:curr_block_x_end, ...
%     curr_block_y_start:curr_block_y_end);

% recon_full_frame is the reconstructed frame of the last time step
% to locate the searching range, we need either increase or reduce base of
% the current size i and the search range r

search_block_x_start = curr_block_x_start;
search_block_x_end = curr_block_x_end;
search_block_y_start = curr_block_y_start;
search_block_y_end = curr_block_y_end;

% In case search range is not matching with the block, let's adjust the
% boundaries
if r ~= 0
    offset = r;
    
    search_block_x_start = curr_block_x_start - offset;
    if search_block_x_start < 1
        search_block_x_start = 1;
    end
    
    search_block_x_end = curr_block_x_end + offset;
    if search_block_x_end > frame_size(1)
        search_block_x_end = frame_size(1);
    end

    search_block_y_start = curr_block_y_start - offset;
    if search_block_y_start < 1
        search_block_y_start = 1;
    end

    search_block_y_end = curr_block_y_end + offset;
    if search_block_y_end > frame_size(2)
        search_block_y_end = frame_size(2);
    end
end

search_block = recon_full_frame( ...
    search_block_x_start:search_block_x_end, ...
    search_block_y_start:search_block_y_end);

curr_block = curr_full_frame( ...
    curr_block_x_start:curr_block_x_end, ...
    curr_block_y_start:curr_block_y_end);

% For each reference block (within the search range), find the 
% MAE (Mean absolute Error) of the current block
candidates = [];
smallest_mae = Inf;
for ref_block_x = search_block_x_start:search_block_x_end - i + 1
    for ref_block_y = search_block_y_start:search_block_y_end - i + 1

        ref_block = recon_full_frame(ref_block_x:ref_block_x + i - 1, ref_block_y:ref_block_y+ i - 1);
        mae = sum(abs(curr_block - ref_block), [1 2]);

        if mae < smallest_mae
            %"Updateing smallest_mae"
            smallest_mae = mae;
            candidates = [ref_block_x, ref_block_y];
        elseif mae == smallest_mae
            %"Adding to candidates"
            candidates = [candidates; [ref_block_x, ref_block_y]];
        end
        % "======================="

    end
end

% With more than 1 possible candidates to return, go through the sequence
% to find the unique one

% Step 1: Find the smallest l1
candidates_w_smallest_l1 = [];
smallest_l1 = Inf;
for i = 1:size(candidates, 1) % row level
    if sum(candidates(i, :)) < smallest_l1
        smallest_l1 = sum(candidates(i, :));
        candidates_w_smallest_l1 = [candidates(i, :)];
    elseif sum(candidates(i, :)) == smallest_l1
        candidates_w_smallest_l1 = [candidates_w_smallest_l1; candidates(i, :)];
    end
end

% Step 2: Then find the smallest y
candidates_w_smallest_y = [];
smallest_y = Inf;
for i = 1:size(candidates_w_smallest_l1, 1) % row level
    if candidates_w_smallest_l1(i, 2) < smallest_y
        smallest_y = candidates_w_smallest_l1(i, 2);
        candidates_w_smallest_y = [candidates_w_smallest_l1(i, :)];
    elseif candidates_w_smallest_l1(i, 2) == smallest_y
        candidates_w_smallest_y = [candidates_w_smallest_y; candidates_w_smallest_l1(i, :)];
    end
end

% Step 3: Then find the smallest y
candidates_w_smallest_x = [];
smallest_x = Inf;
for i = 1:size(candidates_w_smallest_y, 1) % row level
    if candidates_w_smallest_y(i, 1) < smallest_x
        smallest_x = candidates_w_smallest_y(i, 1);
        candidates_w_smallest_x = [candidates_w_smallest_y(i, :)];
    elseif candidates_w_smallest_y(i, 1) == smallest_x
        candidates_w_smallest_x = [candidates_w_smallest_x; candidates_w_smallest_y(i, :)];
    end
end

prediction_block_x_y = candidates_w_smallest_x(1,:);

% "==========Done============="
% candidates
% candidates_w_smallest_l1
% candidates_w_smallest_y
% candidates_w_smallest_x

