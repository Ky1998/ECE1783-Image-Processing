function r = encodeExpGolombValue(value)
    value = double(value);
    if value > 0
        value = 2 * value - 1;
    else
        value = -2 * value;
    end
    r = '';
    M = floor(log2(value + 1));
    info = dec2bin(value + 1 - 2^M, M);
    for j = 1:M
        r = [r '0'];
    end
    r = [r '1'];
    r = [r info];
end