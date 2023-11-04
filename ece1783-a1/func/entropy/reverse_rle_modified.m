function OriginalInput = reverse_rle_modified(Input, restore_size)
    L = length(Input);
    OriginalInput = zeros(1, restore_size);  % Initialize the output array with zeros
    i = 1;
    k = 1;

    while i <= L
        count = Input(i);

        if count < 0  % Negative count indicates a run of non-zero values
            count = -count;

            for j = 1:count
                if k <= numel(OriginalInput)
                    OriginalInput(k) = Input(i + j);
                    k = k + 1;
                else
                    % Expand the OriginalInput array if it's too small
                    OriginalInput = [OriginalInput, zeros(1, L)];
                end
            end

            i = i + count + 1;
        else  % Positive count indicates a run of zeros
            for j = 1:count
                if k <= numel(OriginalInput)
                    OriginalInput(k) = 0;
                    k = k + 1;
                else
                    % Expand the OriginalInput array if it's too small
                    OriginalInput = [OriginalInput, zeros(1, L)];
                end
            end

            i = i + 1;
        end
    end

    % % Trim the OriginalInput array to the actual length
    % OriginalInput = OriginalInput(1:k);
end


