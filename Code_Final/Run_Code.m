% clear all; clc;
%%Input Parameters
InputFilePath_I = 'Images/target/08.jpg';
InputFilePath_R = 'Images/02.jpg';

%%Landmarks Detection
[fpts_I] = GetLandMarks(InputFilePath_I);
[fpts_R] = GetLandMarks(InputFilePath_R);
img_I = imread(InputFilePath_I);
img_R = imread(InputFilePath_R);

%%Image warping R to I
[warp_R, C, I_c, R_c] = warp_segment(img_I, img_R, fpts_I, fpts_R);

%imshow(imfuse(I_c.large./100, C.reg1, 'blend'))
%imshow(imfuse(R_c.large./100, C.reg1, 'blend'))
% imshow(I_c.skin./255*40)
% imshow(R_c.skin./255*40)