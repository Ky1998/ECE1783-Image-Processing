clc; clear; close all;

% Please ensure additional project paths aare added to the project config
% input/
% funct/

I = 8
N = 3
R = 4
QP = 6
rows = 288
cols = 352
num_frames = 10
FRAME_PREIOD = 4

% Set the video information
vid_seq = 'foreman_cif.y4m';
width  = cols;
height = rows;
ratio = "4:2:0";
format = ".y4m";

% % Upsample U and V channel from 4:2:0 to 4:4:4
% [U_up, V_up] = upsample420(U, V);

% Read the video sequence in to separate channels
% Each returns [channel_heights, channel_widths, num_frames]
[Y,U,V] = loadYUV(vid_seq, height, width, ratio, num_frames, format); 

% initialization
mae = 0;
Y_recon = int32(zeros(rows, cols, num_frames));
Grey_frame = int32(zeros(rows, cols)) + 128;
recon_full_frame = Grey_frame;
rows = int32(rows);
cols = int32(cols);

% >>>>>>>>>>>>IMPORTANT<<<<<<<<<<<<<<
% We need to use cell matrix instead, to allow for I frame has
% different differential encoded value size. I frame has 1 digit for mode, P frame
% has 2 digits for motion vector
% MV = int32(zeros(1, idivide(rows,I,"ceil") * idivide(cols,I,"ceil"), num_frames));
MV = cell(1, idivide(rows,I,"ceil") * idivide(cols,I,"ceil"), num_frames);

RES = int32(zeros(I, I, idivide(rows,I,"ceil") * idivide(cols,I,"ceil"), num_frames + 1));

QTC_Coeff = dictionary();
MDiff = dictionary();

% check QP is within the range
qp_max = QPMax(I)
if QP > qp_max || QP < 0
    ME = MException('e4_encoder:InvalidInput', ...
        'QP is outofbound');
    throw(ME);
end

for frame = 1:num_frames

    frame_type = get_frame_type(frame, FRAME_PREIOD);
    % frame_type = 'P';

    if frame_type == 'P'

        block_idx = 1;
        for r = 1:idivide(rows,I,"ceil")
            for c = 1:idivide(cols,I,"ceil")
                % find predicted block
                [prediction_block_x_y, smallest_mae, curr_block, search_block] = find_predicted_block(Y(:,:,frame), 1 + r * I - I, 1 + c * I - I, I, recon_full_frame, R);
                mae = mae + smallest_mae;
    
                prediction_block = recon_full_frame( ...
                    prediction_block_x_y(1):prediction_block_x_y(1)+I-1, ...
                    prediction_block_x_y(2):prediction_block_x_y(2)+I-1);
                
                % save motion vector
                % >>>>>>>>>>>> IMPORTANT <<<<<<<<<<<<<<<<
                % We are using column vector [x ; y] here to make sure the when
                % we use cell2mat to translate, it does not merge the content
                % of all cell to a single vlaue
                MV(1,block_idx,frame) = {[prediction_block_x_y(1) - (1 + r * I - I); prediction_block_x_y(2) - (1 + c * I - I)]};
    
                % perform entropy on MVs or Modes
                % for P frame, input MVs in order as array [Last_MV, Curr_MV]
                if block_idx == 1
                    Last_MV = [0, 0];
                    Curr_MV = MV(:, block_idx, frame);
                    Curr_MV = Curr_MV{1}; %unwrap cell to get matrix
                    MVs_Modes = [Last_MV, Curr_MV'];
                else
                    Last_MV = MV(:, block_idx-1, frame);
                    Last_MV = Last_MV{1}; %unwrap cell to get matrix
                    Curr_MV = MV(:, block_idx, frame);
                    Curr_MV = Curr_MV{1}; %unwrap cell to get matrix
                    MVs_Modes = [Last_MV', Curr_MV'];
                end

                diff_encoding = inter_intra_diff_encoding(frame_type, MVs_Modes);
    
                % apply ExpGolomb element wide
                egc_diff_encoding = arrayfun(@encodeExpGolombValue, diff_encoding,'UniformOutput',false);
                % egc_diff_encoding = diff_encoding;
    
                MDiff(strcat(num2str(block_idx), '_', num2str(frame))) = {egc_diff_encoding}; % cache
    
                % residuals
                residual_block = curr_block - prediction_block;
           
                % generate qMatrix
                qMatrix = generateQMatrix(I,I,QP);
    
                % dct2, and quant transform
                qt_coeff = quantizeBlock(residual_block, qMatrix);
                
                % perform entropy on transf/quant. coeff
                reordered_quant_transform_coeff = reorderDiagonal(qt_coeff);
                rle_encoded_qt_coeff = rle_modified(reordered_quant_transform_coeff);
                % apply ExpGolomb element wide
                egc_rle_encoded_qt_coeff = arrayfun(@encodeExpGolombValue, rle_encoded_qt_coeff,'UniformOutput',false);
                % egc_rle_encoded_qt_coeff = rle_encoded_qt_coeff;
    
                QTC_Coeff(strcat(num2str(block_idx), '_', num2str(frame))) = {egc_rle_encoded_qt_coeff}; % cache
    
                % rescale & inv. transform
                restored_residual_block = rescalingBlock(qt_coeff, qMatrix);
                RES(:,:,block_idx,frame) = restored_residual_block; % cache
                
                % increment block idx to next block in the following iteration
                block_idx = block_idx + 1;
            end
        end
    
        % Decode/Reconstruct this frame
        % need to apply cell2mat on MV to get matrix back
        Y_recon(:,:,frame) = reconstruct(RES(:,:,:,frame), cell2mat(MV(:,:,frame)), recon_full_frame, I, rows, cols);
        recon_full_frame = Y_recon(:,:,frame);

    else % for I-frame

        curr_full_frame = Y(:,:,frame);

        % encoded_iframe: a matrix to represent frame encoded with intra predictors
        % in a dimension of [i, # of blocks], where i is the left-i or top i
        % broader, 
        % encoded_mode: a matrix to represent mode of encoding in a dimension of
        % [1, # of blocks], where mode 0 - hortizontal, or 1 - vertical
        [encoded_iframe, encoded_mode] = encode_iframe(curr_full_frame, I);
        
        % in order to populate the dictionaries we need to iterate block by
        % block and process both diff encoding and pred encoding
        for block_idx = 1:size(encoded_iframe, 2)

            block_pred = encoded_iframe(:, block_idx);
            block_mode = encoded_mode(block_idx);

            MV(1,block_idx,frame) = {block_mode}; % In case of I frame, MV is the mode

            % for I frame, input Modes in order as array [Last_Mode, Curr_Mode],
            % for first block, enter Last_Mode as [0]
            % Note that for mode, 0 - horizontal, 1 - vertical
            if block_idx == 1
                Last_Mode = [0];
                Curr_Mode = MV(1, block_idx, frame);
                Curr_Mode = Curr_Mode{1}; %unwrap cell to get matrix
                MVs_Modes = [Last_Mode, Curr_Mode];
            else
                Last_Mode = MV(1, block_idx-1, frame);
                Last_Mode = Last_Mode{1}; %unwrap cell to get matrix
                Curr_Mode = MV(1, block_idx, frame);
                Curr_Mode = Curr_Mode{1}; %unwrap cell to get matrix
                MVs_Modes = [Last_Mode, Curr_Mode];
            end
            diff_encoding = inter_intra_diff_encoding(frame_type, int32(MVs_Modes));
            
            % apply ExpGolomb element wide
            egc_diff_encoding = arrayfun(@encodeExpGolombValue, diff_encoding,'UniformOutput',false);

            MDiff(strcat(num2str(block_idx), '_', num2str(frame))) = {egc_diff_encoding}; % cache
            
            % apply ExpGolomb element wide
            egc_block_pred = arrayfun(@encodeExpGolombValue, block_pred,'UniformOutput',false);

            QTC_Coeff(strcat(num2str(block_idx), '_', num2str(frame))) = {egc_block_pred}; % cache

        end

        Y_recon(:,:,frame) = decode_iframe(encoded_iframe, encoded_mode, size(Y(:,:,frame)), I);
        recon_full_frame = Y_recon(:,:,frame);
    end
end

% Output files
save('MDiff', 'MDiff')
save('QTC_Coeff','QTC_Coeff')


% Showing before and after for comparison
figure;
c = 0;  % counter
for frame = 1:num_frames
    c = c + 1;
    subplot(3,4,c), imshow(uint8(Y(:,:,frame)));
    title(['frame #', num2str(frame)]);
end

figure;
c = 0;  % counter
for frame = 1:num_frames
    c = c + 1;
    subplot(3,4,c), imshow(uint8(Y_recon(:,:,frame)));
    title(['frame #', num2str(frame)]);
end

mae_avg = mae / double(rows * cols * num_frames)

psnr_sum = 0.0;
for frame = 1:num_frames
    psnr_sum = psnr_sum + compute_psnr(Y(:,:,frame), Y_recon(:,:,frame));
end
psnr_avg = psnr_sum / num_frames

% % Exercise 3 part 3
% A = uint8(Y(:,:,2) - Y_recon(:,:,1));
% figure;
% c = 1;
% subplot(1,1,c), imshow(A);
% title('A');
% 
% D = reconstruct(RES(:,:,:,frame + 1), MV(:,:,2), Y_recon(:,:,1), I, rows, cols);
% B = uint8(Y(:,:,2) - D);
% figure;
% c = 1;
% subplot(1,1,c), imshow(B);
% title('B');
% 
% C = uint8(D);
% figure;
% c = 1;
% subplot(1,1,c), imshow(C);
% title('C');



