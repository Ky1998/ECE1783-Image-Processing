function qt = rescalingBlock(qtcblock, qMatrix)
    [block_height, block_width] = size(qtcblock);
    qt = zeros(block_height, block_width);
    for x = 1:block_height
        for y = 1:block_width
            qt(x, y) = round(qtcblock(x, y) * qMatrix(x, y));
        end
    end
    qt=idct2(qt);
end
