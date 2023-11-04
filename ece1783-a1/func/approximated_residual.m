function [approximated_residual_block, reconstructed_block] = approximated_residual(curr_block, predicted_block, n)
    approximated_residual_block = round((curr_block - predicted_block)/ (2^n)) * (2^n);
    reconstructed_block = approximated_residual_block + predicted_block;
end