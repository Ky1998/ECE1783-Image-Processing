function Y_avg = compute_Y_average(Y, i)

[rows, cols, num_frames]=size(Y);

Y_avg = int32(zeros(rows, cols, num_frames));
rows = int32(rows);
cols = int32(cols);
for frame = 1:num_frames %num_frames
    for r = 1:idivide(rows,i,"ceil")
        for c = 1:idivide(cols,i,"ceil")
            sum = 0;
            for x = 1:i
                for y = 1:i
                    if r*i+x-i <= rows && c*i+y-i <= cols
                        sum = sum + Y(r*i+x-i, c*i+y-i, frame);
                    else
                        sum = sum + 128;
                    end
                end
            end
            avg = idivide(sum,i*i,"round");
            for x = 1:i
                for y = 1:i
                    if r*i+x-i <= rows && c*i+y-i <= cols
                        Y_avg(r*i+x-i, c*i+y-i, frame) = avg;
                    end
                end
            end
        end
    end
end