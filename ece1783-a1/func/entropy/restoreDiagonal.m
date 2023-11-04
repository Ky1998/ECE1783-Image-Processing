function originalMatrix = restoreDiagonal(diagonalElements, rows, cols)
    % Convert the reordered string back to a numeric array
    % diagonalElements = str2num(reorderedString);
    
    % Create an empty matrix of the specified size
    originalMatrix = zeros(rows, cols);

    % Calculate the total number of elements
    totalElements = rows * cols;
    
    % Initialize the index for accessing diagonal elements
    index = 1;
    
    % Populate the elements of the original matrix in diagonal order
    for sumIndices = 2:rows+cols
        for row = 1:rows
            col = sumIndices - row;
            if col >= 1 && col <= cols
                originalMatrix(row, col) = diagonalElements(index);
                index = index + 1;
            end
        end
    end
end
