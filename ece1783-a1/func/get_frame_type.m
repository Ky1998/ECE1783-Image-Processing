function [frame_type] = get_frame_type(frame_num, frame_period)
    if rem(frame_num, frame_period) == 1
        frame_type = 'I';
    else
        frame_type = 'P';
    end

end

