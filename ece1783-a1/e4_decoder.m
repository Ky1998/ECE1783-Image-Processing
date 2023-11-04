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

QTC_Coeff = load('QTC_Coeff.mat');
QTC_Coeff = getfield(QTC_Coeff, 'QTC_Coeff');

MDiff = load("MDiff.mat");
MDiff = getfield(MDiff, 'MDiff');

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
                
                egc_diff_encoding = MDiff(strcat(num2str(block_idx), '_', num2str(frame)));
                egc_diff_encoding = egc_diff_encoding{1}; % unwrap, and egc_diff_encoding is 1x2 cell array for P, 1x1 for I
                
                diff_encoding = cell2mat(arrayfun(@dec_golomb, egc_diff_encoding,'UniformOutput',false));
    
                % for P frame, input MVs in order as array [Last_MV, Curr_MV]
                if block_idx == 1
                    curr_MV_Mode = int32([0, 0]);
                else
                    last_MV_Mode = MV(:,block_idx-1,frame);
                    last_MV_Mode = last_MV_Mode{1};
                    curr_MV_Mode = inter_intra_diff_decoding(diff_encoding, frame_type, last_MV_Mode');
                end
    
                % save motion vector
                % >>>>>>>>>>>> IMPORTANT <<<<<<<<<<<<<<<<
                % We are using column vector [x ; y] here to make sure the when
                % we use cell2mat to translate, it does not merge the content
                % of all cell to a single vlaue
                MV(1,block_idx,frame) = {curr_MV_Mode'};
    
                % find residuals
                egc_rle_encoded_qt_coeff = QTC_Coeff(strcat(num2str(block_idx), '_', num2str(frame)));
                egc_rle_encoded_qt_coeff = egc_rle_encoded_qt_coeff{1}; % unwrap
    
                % reverse entropy
                rle_encoded_qt_coeff = cell2mat(arrayfun(@dec_golomb, egc_rle_encoded_qt_coeff,'UniformOutput',false));
                
                reordered_quant_transform_coeff = reverse_rle_modified(rle_encoded_qt_coeff, I*I);
                qt_coeff = restoreDiagonal(reordered_quant_transform_coeff, I, I);
    
                 % generate qMatrix
                qMatrix = generateQMatrix(I,I,QP);
    
                % rescaling / reverse transform
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
        
        % in order to process dictionaries we need to iterate block by
        % block and process both diff encoding and pred encoding
        num_block = numEntries(MDiff) / num_frames;
        encoded_mode = int32(zeros(1, num_block));
        encoded_iframe = int32(zeros(I, num_block));

        for block_idx = 1:num_block

            egc_diff_encoding = MDiff(strcat(num2str(block_idx), '_', num2str(frame)));
            egc_diff_encoding = egc_diff_encoding{1}; % unwrap, and egc_diff_encoding is 1x2 cell array for P, 1x1 for I

            diff_encoding = cell2mat(arrayfun(@dec_golomb, egc_diff_encoding,'UniformOutput',false));

            % for I frame, input MVs in order as array [Last_Mode, Curr_Mode]
            if block_idx == 1
                curr_Mode = uint8([0]);
            else
                last_Mode = MV(1,block_idx-1,frame);
                last_Mode = last_Mode{1};
                curr_Mode = inter_intra_diff_decoding(diff_encoding, frame_type, last_Mode);
            end

            % save mode into MV
            curr_Mode = uint8(curr_Mode);
            MV(1,block_idx,frame) = {curr_Mode};
            
            egc_block_pred = QTC_Coeff(strcat(num2str(block_idx), '_', num2str(frame)));
            egc_block_pred = egc_block_pred{1}; % unwrap

            block_pred = cell2mat(arrayfun(@dec_golomb, egc_block_pred,'UniformOutput',false));

            encoded_mode(block_idx) = curr_Mode;
            encoded_iframe(:, block_idx) = block_pred;

        end
        
        Y_recon(:,:,frame) = decode_iframe(encoded_iframe, encoded_mode, size(Y_recon(:,:,frame)), I);
        recon_full_frame = Y_recon(:,:,frame);

    end
end

figure;
c = 0;  % counter
for frame = 1:num_frames
    c = c + 1;
    subplot(3,4,c), imshow(uint8(Y_recon(:,:,frame)));
    title(['frame #', num2str(frame)]);
end

% mae_avg = mae / double(rows * cols * num_frames)
% 
% psnr_sum = 0.0;
% for frame = 1:num_frames
%     psnr_sum = psnr_sum + compute_psnr(Y(:,:,frame), Y_recon(:,:,frame));
% end
% psnr_avg = psnr_sum / num_frames

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