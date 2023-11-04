function Output = rle_modified(Input)
    L = length(Input);
    k = 1;
    i = 1;

    Output = zeros(1, 2 * L);  % Initialize the output array with zeros

    while i <= L
        if Input(i) ~= 0
            count = 0;

            while i <= L && Input(i) ~= 0
                count = count + 1;
                i = i + 1;
            end

            Output(k) = -count;
            Output(k + 1:k + count) = Input(i - count:i - 1);
            k = k + count + 1;
        else
            count = 0;

            while i <= L && Input(i) == 0
                count = count + 1;
                i = i + 1;
            end

            if i <= L
                Output(k) = count;
                k = k + 1;
            elseif count > 1
                Output(k) = 0;
            end
        end
    end

    % Check if the input ends with a non-zero value
    if Input(L) ~= 0
        k = k - 1;  % Remove the trailing zero
    end

    % Trim the output array to remove trailing zeros
    Output = Output(1:k);
end


