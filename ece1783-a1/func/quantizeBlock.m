function quant_transform = quantizeBlock(residual, qMatrix)
    TC=dct2(residual);
    [block_height, block_width] = size(TC);
    quant_transform = zeros(block_height, block_width);
    for x = 1:block_height
        for y = 1:block_width
            quant_transform(x, y) = round(TC(x, y) / qMatrix(x, y));
        end
    end
end