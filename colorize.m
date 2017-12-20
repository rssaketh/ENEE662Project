% close all
% clear all
% params.colorspace = 'LUV'; % 'HSV' or 'LUV' or 'Lab'
% g_name='example.bmp';
% c_name='example_marked.bmp';
% out_name='example_res.bmp';

function [nI, snI, lblInds] = colorize(params,Images)
%set solver=1 to use a multi-grid solver 
%and solver=2 to use an exact matlab "\" solver
solver=2; 

% gI=double(imread(names.g_name))/255;
% cI=double(imread(names.c_name))/255;


if ~strcmp(params.colorspace,'HSV')
    sgI=rgb2ntsc(Images.gI); %convert to LUV Space
    scI=rgb2ntsc(Images.cI);
    ntscIm(:,:,1)=sgI(:,:,1); % luminance
    ntscIm(:,:,2)=scI(:,:,2); % chrominance 1 - u
    ntscIm(:,:,3)=scI(:,:,3); % chrominance 1 - v
else
    sgI = rgb2hsv(Images.gI);
    scI = rgb2hsv(Images.cI);
    ntscIm(:,:,1) = scI(:,:,1);
    ntscIm(:,:,2) = scI(:,:,2);
    ntscIm(:,:,3) = sgI(:,:,3);


end



max_d=floor(log(min(size(ntscIm,1),size(ntscIm,2)))/log(2)-2);
% TODO = what are iu, ju?
iu=floor(size(ntscIm,1)/(2^(max_d-1)))*(2^(max_d-1));
ju=floor(size(ntscIm,2)/(2^(max_d-1)))*(2^(max_d-1));
id=1; jd=1;
% figure,imshow(colorIm)
% TODO - why are they disregarding the 3rd channel? Isn't that v?
colorIm=Images.colorIm(id:iu,jd:ju,:);
% figure,imshow(colorIm)
ntscIm=ntscIm(id:iu,jd:ju,:);

if (solver==1)
  nI=getVolColor(colorIm,ntscIm,[],[],[],[],5,1);
  nI=ntsc2rgb(nI);
else
  [nI,snI,lblInds] =getColorExact(colorIm,ntscIm,params);
end
%figure, imshow(nI)
% figure, imshow(nI)

%imwrite(nI,names.out_name)
end
   
  

%Reminder: mex cmd
%mex -O getVolColor.cpp fmg.cpp mg.cpp  tensor2d.cpp  tensor3d.cpp
