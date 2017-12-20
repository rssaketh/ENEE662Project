clear all
close all
clc

color_thresh = 0.2;
params.colorspace = 'LUV';

main_path = 'example_images/3-car/';
path_g = sprintf('%sgray',main_path);
path_c = sprintf('%smarkings',main_path);
path_o = sprintf('%soutput',main_path);
start_idx = 1;
no_of_frames = 4;
%max_in_img_idx = start_idx-1+10;

% optical flow
opticFlow = opticalFlowLK('NoiseThreshold',0.01);

% output video : output

% imclose
%se = strel('disk',3);

% compute cI for each frame
for img_idx = start_idx : start_idx+no_of_frames-1
    gI = imread(sprintf('%s/output-%d.jpg',path_g,img_idx)); % output-%d.jpg % img%04d.jpg % img%04d.bmp 
    
    if img_idx == start_idx
        % send the input cI
        gI = double(gI)/255;
        Images.gI = gI;
        cI = imread(sprintf('%s/output-0.jpg',path_c)); % img%04d.jpg % img%04d.bmp % output-3()
        % TODO
%         tcI = zeros(size(Images.gI));
%         tcI(:,:,1) = [cI(:,:,1);Images.gI(end,:,1)];
%         tcI(:,:,2) = [cI(:,:,2);Images.gI(end,:,2)];
%         tcI(:,:,3) = [cI(:,:,3);Images.gI(end,:,3)];
%         cI = tcI;        
%         Images.gI = Images.gI(1:size(cI,1),:,:);
        Images.cI = double(cI)/255;
        % generate colorIm
        colorIm=(sum(abs(Images.gI-Images.cI),3)>color_thresh);
        Images.colorIm=medfilt2(double(colorIm));
        %Images.colorIm = imclose(Images.colorIm,se);
        % colorize first frame
        [nI, ~, lblInds] = colorize(params,Images);
        % output
        output = nI;
    else
        % change lblInds
        [lbl_i, lbl_j] = ind2sub([size(prev_cI,1),size(prev_cI,2)], lblInds);
        % gI
        gI=double(gI)/255;
        Images.gI = gI;
        %generate labels
        update_i = lbl_i + gI_flow.Vy(lblInds);
        update_j = lbl_j + gI_flow.Vx(lblInds);
        % bound check
        update_i(find(update_i < 1.0)) = 1;
        update_j(find(update_j < 1.0)) = 1;
        update_i(find(update_i > size(prev_cI,1))) = size(prev_cI,1);
        update_j(find(update_j > size(prev_cI,2))) = size(prev_cI,2);
        newlblInds = sub2ind([size(Images.gI, 1), size(Images.gI, 2)], floor(update_i), floor(update_j));
        % generate cI
        cI = Images.gI;
        %newlblInds = floor(newlblInds);
        for j = 1:3
            dumbIm = prev_cI(:,:,j);
            dumbcI = cI(:,:,j);
            dumbcI(newlblInds) = dumbIm(lblInds);
            cI(:,:,j) = dumbcI;
            %cI((size(cI,1)*size(cI,2))*(j-1) + newlblInds) = dumbIm(lblInds);
        end
%         cI(floor(newlblInds)) = prev_cI(lblInds);
%         cI(size(prev_cI,1)*size(prev_cI,2) + floor(newlblInds)) = prev_cI(size(prev_cI,1)*size(prev_cI,2) + floor(newlblInds));
%         cI(2*size(prev_cI,1)*size(prev_cI,2) + floor(newlblInds)) = prev_cI(size(2*prev_cI,1)*size(prev_cI,2) + floor(newlblInds));
%         cI(floor(newlblInds),2) = prev_cI(lblInds,2);
%         cI(floor(newlblInds),3) = prev_cI(lblInds,3);
        Images.cI = cI;
        % colorIm
        colorIm=(sum(abs(Images.gI-Images.cI),3)>color_thresh);
        Images.colorIm=medfilt2(double(colorIm));
        %Images.colorIm = imclose(Images.colorIm,se);
        
        % colorize frame
        [nI, ~, lblInds] = colorize(params,Images);
        % output
        output = cat(4,output,nI);
    end
    % for the next frame calc
    prev_cI = Images.cI;
    % optical flow
    gI_flow1 = rgb2gray(Images.gI);
    gI_flow = estimateFlow(opticFlow,gI_flow1);
    
end

% print output
for i = 1:no_of_frames
    imwrite(output(:,:,:,i), sprintf('%s/output-%d.jpg',path_o,i));
    pause(2);
end
% for i = 1:no_of_frames
%    imshow(output(:,:,:,i));
%    pause(2);
% end