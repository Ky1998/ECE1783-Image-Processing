function qMatrix = generateQMatrix(block_height, block_width, quantizationParameter)
    qMatrix = zeros(block_height, block_width);
    for x = 1:block_height
        for y = 1:block_width
            if (x + y - 2 < block_height - 1)
                qMatrix(x, y) = 2 ^ quantizationParameter;
            elseif (x + y - 2 == block_height - 1)
                qMatrix(x, y) = 2 ^ (quantizationParameter + 1);
            else
                qMatrix(x, y) = 2 ^ (quantizationParameter + 2);
            end
        end
    end
end