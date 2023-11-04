function [U_up, V_up] = upsample420(U, V)

% Upsample U and V channel frp, 4:2:0 to 4:4:4
[rows, cols, num_frames]=size(U);
U_up = int32(zeros(rows*2, cols*2, num_frames));
V_up = int32(zeros(rows*2, cols*2, num_frames));

for frame = 1:num_frames
    for r = 1:rows
        for c = 1:cols 
            U_up(2*r-1, 2*c-1, frame) = U(r, c, frame);
            U_up(2*r-1, 2*c, frame) = U(r, c, frame);
            U_up(2*r, 2*c-1, frame) = U(r, c, frame);
            U_up(2*r, 2*c, frame) = U(r, c, frame);
    
            V_up(2*r-1, 2*c-1, frame) = V(r, c, frame);
            V_up(2*r-1, 2*c, frame) = V(r, c, frame);
            V_up(2*r, 2*c-1, frame) = V(r, c, frame);
            V_up(2*r, 2*c, frame) = V(r, c, frame);
        end
    end
end