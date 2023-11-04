function [R, G, B] = conv_YUV_RGB_444(Y,U,V, mode)

% ITU-R BT.601, RGB full range, results in the following transform matrix:
%  1.164   0.000   1.596
%  1.164  -0.392  -0.813
%  1.164   2.017   0.000
% ITU-R BT.601, RGB limited range, results in the following transform matrix:
%  1.000   0.000   1.402
%  1.000  -0.344  -0.714
%  1.000   1.772   0.000
% ITU-R BT.709, RGB limited range, results in the following transform matrix:
%  1.000   0.000   1.570
%  1.000  -0.187  -0.467
%  1.000   1.856   0.000

if mode == 1
    R = (1.164 * (Y - 16)) + (1.596 * (V - 128));
    G = (1.164 * (Y - 16)) - (0.392 * (U - 128)) - (0.813 * (V - 128));
    B = (1.164 * (Y - 16)) + (2.017 * (U - 128));
elseif mode == 2
    R = (1. * (Y - 16)) + (1.402 * (V - 128));
    G = (1. * (Y - 16)) - (0.344 * (U - 128)) - (0.714 * (V - 128));
    B = (1. * (Y - 16)) + (1.772 * (U - 128));
elseif mode == 3
    R = (1. * (Y - 16)) + (1.570 * (V - 128));
    G = (1. * (Y - 16)) - (0.187 * (U - 128)) - (0.467 * (V - 128));
    B = (1. * (Y - 16)) + (1.856 * (U - 128));
end