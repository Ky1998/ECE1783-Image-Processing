function psnr = compute_psnr(A, B)

[rows, cols]=size(A);
MAX = 255;
SE = 0;
for r = 1:rows
    for c = 1:cols
        SE = SE + (A(r, c) - B(r, c)) ^ 2;
    end
end
MSE = double(SE) / double(rows*cols);
psnr = 10 * log10(double(MAX) ^ 2 / MSE);
