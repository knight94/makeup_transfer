% clear all; clc;
%%Input Parameters
InputFilePath_I = 'Images/target/05.jpg';
InputFilePath_R = 'Images/03.jpg';
alphaBlenda = 0.8;

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


I_large = I_c.large;
I_skin = I_c.skin;
I_a = I_c.a;
I_b = I_c.b;


R_large = R_c.large;
R_skin = R_c.skin;
R_a = R_c.a;
R_b = R_c.b;

%beta_arr
beta_arr = beta_gen(I_large,{C.reg1, C.reg3, C.reg2});

%highlight Transfer
FaceL_HighLight = highlight_transfer(C.reg1, R_large./100, I_large./100, beta_arr);

%Detail/skin Transfer
L_Detail = R_skin + 0*I_skin;

%Color transfer
[FaceColora, FaceColorb] = color_transfer(alphaBlenda, C.reg1, I_a, I_b, R_a, R_a);

%Lip transfer
lip_result = lip_makeup(C.reg2, uint8(warp_R), img_I);

%merge all the images
targetBackMask = img_I .* (~(C.reg1 + C.reg2));
imFinal_all = merge_layer(img_I, FaceL_HighLight, L_Detail, FaceColora, FaceColorb, lip_result, targetBackMask);
