function diagonalElements = reorderDiagonal(matrix)
    % Get the size of the input matrix
    [rows, cols] = size(matrix);
    
    % Calculate the total number of elements
    totalElements = rows * cols;
    
    % Initialize an array to store the elements in diagonal order
    diagonalElements = zeros(1, totalElements);

    % Populate the diagonalElements array with the matrix elements in diagonal order
    index = 1;
    for sumIndices = 2:rows+cols
        for row = 1:rows
            col = sumIndices - row;
            if col >= 1 && col <= cols
                diagonalElements(index) = matrix(row, col);
                index = index + 1;
            end
        end
    end
    
    % Ensure the diagonal order is in increasing frequency
    [~, sortedIndices] = sort(1:totalElements);
    diagonalElements = diagonalElements(sortedIndices);

    % Convert the diagonal elements to a string
    % reorderedString = num2str(diagonalElements);
end


