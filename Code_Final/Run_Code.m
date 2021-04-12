clear all; clc;
%%Input Parameters
InputFilePath_I = 'Images/target/08.jpg';
InputFilePath_R = 'Images/11.jpg';
addpath(genpath('C:\Users\nsahu\Documents\Semester-I\COL783\Assignment_2\code'))
alphaBlenda = 0.8;
num_pts = 73;

%%Landmarks Detection
img_I = imread(InputFilePath_I);
img_R = imread(InputFilePath_R);

img_I = imresize(img_I, [400 NaN]);
img_R = imresize(img_R, [400 NaN]);
I_resize = 'target_resize.jpg';
R_resize = 'ref_resize.jpg';
imwrite(img_I, I_resize);
imwrite(img_R, R_resize);
[fpts_I] = GetLandMarks(I_resize, num_pts);
% f1 = figure;
% imshow(img_I);
% hold on;
% plot(fpts_I(:,1),fpts_I(:,2),'o','MarkerEdgeColor', 'k', 'MarkerFaceColor','green');
% T_I = delaunay(fpts_I(:,1), fpts_I(:,2));
% trimesh(T_I, fpts_I(:,1), fpts_I(:,2));


[fpts_R] = GetLandMarks(R_resize, num_pts);
% figure
% imshow(img_R);
% hold on;
% plot(fpts_R(:,1),fpts_R(:,2),'o','MarkerEdgeColor', 'k', 'MarkerFaceColor','green');
%T_R = delaunay(fpts_R(:,1), fpts_R(:,2));
% trimesh(T_I, fpts_R(:,1), fpts_R(:,2));

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
% FaceL_HighLight = highlight_transfer(C.reg1, R_large, I_large, beta_arr);


FaceL_HighLight = PoissonGrayBlend (C.reg1, R_large.*C.reg1, I_large.*C.reg1);

%Detail/skin Transfer
L_Detail = R_skin + 0.5*I_skin;

%Color transfer
[FaceColora, FaceColorb] = color_transfer(alphaBlenda, C.reg1, I_a, I_b, R_a, R_a);

%Lip transfer
lip_result = lip_makeup(C.reg2 - bw3, warp_R, img_I);

%merge all the images
FaceL_HighLight_temp = FaceL_HighLight;
% FaceL_HighLight = I_large;
targetBackMask = double(img_I) .* (~(C.reg1 + C.reg2));
% imFinal_all = merge_layer(img_I, FaceL_HighLight, L_Detail, FaceColora, FaceColorb, lip_result, targetBackMask);

imFinal = zeros(size(img_I));

lip_rgb = lab2rgb(lip_result, 'OutputType', 'uint8');

imFinal(:,:,1) = (FaceL_HighLight + L_Detail).*C.reg1;
imFinal(:,:,2) = FaceColora.*C.reg1;
imFinal(:,:,3) = FaceColorb.*C.reg1;

imFinal = lab2rgb(imFinal, 'OutputType', 'uint8');
imshow(imFinal,[]);
imFinal_all = imFinal + uint8(targetBackMask) + lip_rgb; 
figure;clf;
imshow(imFinal_all, []);
title('Subject Make Up');
imwrite(imFinal_all,'Subject_Make_up_08_05.jpg'); 
