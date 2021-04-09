% The main file on transferring the makeup from the reference to the
% target. 
%
% EE 368: Digital Face Makeup Transfer
% Author: Wut Yee Oo
% Stanford University
% 12/5/2015
%
clc; clear; close all
warning('off','all')
load('map.mat');
addpath('./PoissonLaplaceEditingDemo');
addpath('./stasm4.1.0/vc10/x64/Debug');
addpath('./tpsWarp');
addpath('./WlsFilter');
addpath('./faceRecognition');
addpath('./test/input/reference');
addpath('./test/input/target');     
addpath('./test/output/textFiles');
makeupPath = './test/output/makeUpResults/';
outputPath = './test/output/MATLABimg/';
%% CHOOSE REF and TARGET IMG from test\input here
refno = '03';
targetno = '01';
mkdir(outputPath, ['ref',refno,'target',targetno]);
outputPath = [outputPath,'ref',refno,'target',targetno,'/']; 
%% CREATE FACIAL LANDMARK TEST DATABASE: RESIZE IMAGES
% Images need to be resized to be transformed from RGB color space to
% CIELab space
refface = im2double(imread(['.\test\input\reference\', refno, '.jpg']));
targetface = im2double(imread(['.\test\input\target\', targetno, '.jpg']));
refface = imresize(refface, [400 NaN]);
targetface = imresize(targetface, [400 NaN]);
imwrite(refface,strcat('./stasm4.1.0/vc10/x64/Debug/ref_', refno, '.jpg'));
imwrite(targetface,strcat('./stasm4.1.0/vc10/x64/Debug/target_', targetno,'.jpg'));

%% CREATE FACIAL LANDMARK TEST DATABASE: PERFORM FACIAL LANDMARK RECOGNIION
% Note: follow this step only to generate landmark files of your own image 
% Test images only have text files of landmarks
%
% Use the resized images in ./stasm4.1.0/vc10/x64/Debug/ folder to perform 
% facial landmark recognition of 77 data points by Active Shape Model which 
% was implemented in Stasm library by Stephen Milborrow. 
%
% Wut Yee already modified the Stasm executable file to generate a log file of 77 
% data points.
%
% To run the executable and get the log file of 77 datapoints, 
% 
% REFERENCE:
% In command line prompt, 
%   locate the directory to stasm4.1.0\vc10\x64\Debug. 
%   type "minimal ref_refno.jpg" to run
% Output:
%   stasm.log file of 77 data points
%   ref_refno_stasm.bmp
% Save stasm.log file as "ref_refno.txt" in
% test\output\textfiles
%
% TARGET:
% In command line prompt, 
%   locate the directory to stasm4.1.0\vc10\x64\Debug. 
%   type "minimal target_targetno.jpg" to run
% Output:
%   stasm.log file of 77 data points
%   target_targetno_stasm.bmp
% Save minimal.log file as "target_targetno.txt" in
% test\output\textfiles
% 
% Proceed to the rest of MATLAB code to get the final make up product

%% PERFORM MASKING and CUTTING
% Read textfile to get the face boundary (first 16 points). Save it in a
% struct file of p for contouring, masking and cutting

disp('Creating mask images');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reference %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
refFaceCut1 = createMask(refface,['ref_',refno],'face');
refLeftEyeCut = createMask(refface, ['ref_',refno],'leftEye');
refRightEyeCut = createMask(refface,['ref_',refno], 'rightEye');
refUpperLipCut = createMask(refface,['ref_',refno], 'upperLip');
refLowerLipCut = createMask(refface,['ref_',refno], 'lowerLip');

refFaceCut = refFaceCut1 - refLeftEyeCut - refRightEyeCut - refUpperLipCut - ...
    refLowerLipCut;
refEyeCut = refLeftEyeCut + refRightEyeCut;
refLipCut = (refUpperLipCut + refLowerLipCut) > 0;

refBackMask = zeros(size(refface));
refFaceMask = zeros(size(refface));
refLipMask = zeros(size(refface));
for i = 1:3
    refFaceMask(:,:,i) = refface(:,:,i) .* refFaceCut; 
    refBackMask(:,:,i) = refface(:,:,i) .* (~(refFaceCut1 - refEyeCut));
    refLipMask(:,:,i) = refface(:,:,i) .* refLipCut;
end

figure(1);clf; 
subplot(1,2,1); imshow(refFaceMask,[]);
subplot(1,2,2);imshow(refLipMask,[]);
imwrite(refFaceMask,strcat(outputPath, refno, 'FaceMask.jpg'));
imwrite(refLipMask,strcat(outputPath, refno, 'LipMask.jpg'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Target %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
targetFaceCut1 = createMask(targetface,['target_',targetno], 'face');
targetLeftEyeCut = createMask(targetface,['target_',targetno], 'leftEye');
targetRightEyeCut = createMask(targetface,['target_',targetno], 'rightEye');
targetUpperLipCut = createMask(targetface,['target_',targetno], 'upperLip');
targetLowerLipCut = createMask(targetface,['target_',targetno], 'lowerLip');

targetFaceCut = targetFaceCut1 - targetLeftEyeCut - targetRightEyeCut - ...
    targetUpperLipCut - targetLowerLipCut;
targetEyeCut = targetLeftEyeCut + targetRightEyeCut;
targetLipCut = (targetUpperLipCut + targetLowerLipCut) > 0;
imwrite(targetLipCut,'targetlipcut.jpg');

targetLipMask = zeros(size(targetface));
targetFaceMask = zeros(size(targetface));
for i = 1:3
    targetFaceMask(:,:,i) = targetface(:,:,i) .* targetFaceCut; 
    targetLipMask(:,:,i) = targetface(:,:,i) .* targetLipCut;
end

% threshold targetFaceCut and recreate targetFaceMask to remove make up 
% transfer in areas where target hair maybe present
targetgray = rgb2gray(targetFaceMask);
target_norm = targetgray./max(targetgray(:));
thresh = graythresh(target_norm);
targetFaceCut = targetgray > thresh;
% re-add any other facial details other than hair that get excluded in
% thresholding
targetFaceCut = imfill(targetFaceCut, 'holes');
targetFaceCut = targetFaceCut - targetLipCut-targetEyeCut;
figure(17)
imshow(targetFaceCut);

for i = 1:3
    targetFaceMask(:,:,i) = targetface(:,:,i) .* targetFaceCut; 
    targetBackMask(:,:,i) = targetface(:,:,i) .* (~(targetFaceCut + targetLipCut));
end

figure(2);clf; 
subplot(1,2,1); imshow(targetFaceMask,[]);
subplot(1,2,2);imshow(targetLipMask,[]);
imwrite(targetFaceMask,strcat(outputPath, 'targetFaceMask.jpg'));
imwrite(targetLipMask,strcat(outputPath, 'targetLipMask.jpg'));

%% WARP USING THIN PLATE SPLINE METHOD
% Read textfile and save it as landmark.mat 
disp ('Creating landmark file');
reftxt = dlmread(['ref_',refno,'.txt'], ' ',[7 0 83 1]);
targettxt = dlmread(['target_',targetno,'.txt'],' ',[7 0 83 1]);
Xp = reftxt(:,2)';
Xs = targettxt(:,2)';
Yp = reftxt(:,1)';
Ys = targettxt(:,1)';
save('landmark.mat','Xp','Xs','Yp','Ys');

%  W = warped without holes
%  Wr = warped with holes
disp ('Warping');
load('landmark.mat');
[refFaceW, refFaceWr] = tpsWarpDemo(refface,targetface,'map.mat','landmark.mat');
refFaceMaskW = zeros(size(refFaceW));
refLipMaskW = zeros(size(refFaceW)); 
for i = 1:3
refFaceMaskW (:,:,i)= refFaceW (:,:,i).* targetFaceCut;
refLipMaskW (:,:,i)= refFaceW (:,:,i).* targetLipCut;
end

% adjust color by using minimum least square error of three color channels
refFaceMaskW = coloradjust (refFaceMaskW, targetFaceMask);
%refLipMaskW = coloradjust (refLipMaskW, targetLipMask);

figure(3);clf;
subplot(1,2,1); imshow(refFaceMask,[]);
for ix = 1 : length(Xp),
	text(Yp(ix), Xp(ix), num2str(ix));
end
subplot(1,2,2); imshow(refFaceMaskW,[]);
for ix = 1 : length(Xs),
	impoint(gca,Ys(ix),Xs(ix));
end

figure(17);clf;
imshow(refface,[]);
for ix = 1 : length(Xp),
	text(Yp(ix), Xp(ix), ['+^{',num2str(ix),'}'],'Color','red','FontSize',12 );
end

figure(18);clf;
imshow(targetface,[]);
for ix = 1 : length(Xs),
	text(Ys(ix), Xs(ix), ['+^{',num2str(ix),'}'],'Color','blue','FontSize',10  );
end

imwrite(refFaceMaskW,strcat(outputPath, 'refWarped.jpg'));

%% SEPARATE INTO LIGHTNESS AND COLOR
disp ('Separate into lightness and color');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reference %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
refCIELab = rgb2lab (refFaceMaskW);
rLipCIELab = rgb2lab (refLipMaskW);
refLight = refCIELab(:,:,1);
rLipLight = rLipCIELab(:,:,1);
IRef = refLight;
refcolora = refCIELab(:,:,2);
refcolorb = refCIELab(:,:,3);
rLipcolora = rLipCIELab(:,:,2);
rLipcolorb = rLipCIELab(:,:,3);
figure (4);clf;
subplot(1,3,1); imshow (IRef,[]);title('Warped reference: Lightness Layer');
subplot(1,3,2); imshow (refcolora,[]);title('Warped reference: Color Layer a');
subplot(1,3,3); imshow (refcolorb,[]);title('Warped reference: Color Layer b');
imwrite(uint8(4.*IRef),strcat(outputPath, 'refFaceLight.jpg'));
imwrite(uint8(4.*refcolora),strcat(outputPath, 'refFaceColora.jpg'));
imwrite(uint8(4.*refcolora),strcat(outputPath, 'refFaceColorb.jpg'));
imwrite(uint8(4.*rLipLight),strcat(outputPath, 'refLipLight.jpg'));
imwrite(uint8(4.*rLipcolora),strcat(outputPath, 'refLipColora.jpg'));
imwrite(uint8(4.*rLipcolorb),strcat(outputPath,  'refLipColorb.jpg'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Target %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
targetCIELab = rgb2lab (targetFaceMask);
tLipCIELab = rgb2lab (targetLipMask);
targetLight = targetCIELab(:,:,1);
tLipLight = tLipCIELab(:,:,1);
ITarget = targetLight;
targetcolora = targetCIELab(:,:,2);
targetcolorb = targetCIELab(:,:,3);
tLipcolora = tLipCIELab(:,:,2);
tLipcolorb = tLipCIELab(:,:,3);
figure (5);clf;
subplot(1,3,1); imshow (ITarget,[]);title('Target: Lightness Layer');
subplot(1,3,2); imshow (targetcolora,[]);title('Target: Color Layer a');
subplot(1,3,3); imshow (targetcolorb,[]);title('Target: Color Layer b');
imwrite(uint8(4.*ITarget),strcat(outputPath, 'targetFaceLight.jpg'));
imwrite(uint8(4.*targetcolora),strcat(outputPath, 'targetFaceColora.jpg'));
imwrite(uint8(4.*targetcolora),strcat(outputPath, 'targetFaceColorb.jpg'));
imwrite(uint8(4.*tLipLight),strcat(outputPath, 'targetLipLight.jpg'));
imwrite(uint8(4.*tLipcolora),strcat(outputPath, 'targetLipColora.jpg'));
imwrite(uint8(4.*tLipcolorb),strcat(outputPath,  'targetLipColorb.jpg'));
%% SEPARATE LIGHTNESS INTO LARGE SCALE AND DETAIL LAYERS
tic
disp ('Reference, Separate lightness into large scale and detail layers');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reference %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

w = 17; % bilateral window size
sigma = [4 8]; % (sigma_s, sigma_r) % tune this ... 

l2Ref = bilateral_filter(IRef, w, sigma);
l2Ref = l2Ref .* targetFaceCut;
figure (7);clf;
subplot(1,2,1); imshow(l2Ref, []); 
imwrite(uint8(4.*l2Ref),strcat(outputPath,'refFaceLargeLayer_bilateral.jpg'));

s2Ref = IRef - l2Ref;
subplot(1,2,2); imshow(s2Ref, []);
imwrite(uint8(4.*s2Ref),strcat(outputPath,'refFaceDetailLayer_bilateral.jpg'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Target %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp ('Target, Separate lightness into large scale and detail layers');

l2Target = bilateral_filter(ITarget, w, sigma);
l2Target = l2Target .* targetFaceCut;
figure (10);clf;
subplot(1,2,1); imshow(l2Target, []); 
imwrite(uint8(4.*l2Target),strcat(outputPath,'targetFaceLargeLayer_bilateral.jpg'));
s2Target = ITarget - l2Target;
subplot(1,2,2); imshow(s2Target, []);
imwrite(uint8(4.*s2Target),strcat(outputPath,'targetFaceDetailLayer_bilateral.jpg'));
toc
%% LIGHTNESS LAYER, DETAIL TRANSFER
disp ('Lightness Layer, detail transfer');
coeffTarget = 1; coeffRef = 1;
L_Detail = coeffTarget * s2Target + coeffRef * s2Ref;
figure (12);
imshow(L_Detail, []);
title('Lightness layer, face detail transfer');
imwrite(uint8(4.*L_Detail),strcat(outputPath,'faceDetailTransfer.jpg'));

%% LIGHTNESS LAYER, LARGE SCALE TRANSFER
% Highlight transfer
tic
disp ('Lightness Layer, face highlight transfer');
FaceL_HighLight = PoissonGrayBlend (targetFaceCut, l2Ref, l2Target);
FaceL_HighLight = FaceL_HighLight .* targetFaceCut;
figure (13);
imshow(FaceL_HighLight,[]), 
axis image, title('Lightness Layer, highlight transfer');
imwrite(uint8(4.*FaceL_HighLight),strcat(outputPath,'faceHighLightTransfer.jpg'));
toc
%% COLOR LAYER, COLOR TRANSFER
% channel a
disp ('Color Layer, face color transfer');
alphaBlenda = 0.8;
FaceColora = (1 - alphaBlenda) * targetcolora + alphaBlenda * refcolora;
FaceColora = FaceColora .* targetFaceCut;
figure (14);
subplot(1,2,1); imshow(FaceColora,[]);
title('Face Color channel a transfer');
alphaBlendb = 0.8;
FaceColorb = (1 - alphaBlendb) * targetcolorb + alphaBlendb * refcolorb;
FaceColorb = FaceColorb .* targetFaceCut;
subplot(1,2,2); imshow(FaceColorb,[]);
title('Face Color channel b transfer');
imwrite(uint8(4.*FaceColora),strcat(outputPath,'faceColoraTransfer.jpg'));
imwrite(uint8(4.*FaceColorb),strcat(outputPath,'faceColorbTransfer.jpg'));

%% MERGE ALL LAYERS
disp ('Merge all layers');

imFinal = zeros(size(targetCIELab));

% lip transfer makeup 
resultant = lip_makeup(targetLipCut, refLipMaskW, targetLipMask);
LipL_HighLight = resultant(:,:,1);
LipColora = resultant(:,:,2); 
LipColorb = resultant(:,:,3); 
LipColora = LipColora .* targetLipCut;
LipColorb = LipColorb .* targetLipCut;
LipL_HighLight = LipL_HighLight .* targetLipCut;

imFinal(:,:,1) = FaceL_HighLight + LipL_HighLight + L_Detail;
imFinal(:,:,2) = FaceColora + LipColora;
imFinal(:,:,3) = FaceColorb + LipColorb;

imFinal = lab2rgb(imFinal);
imFinal_all = imFinal + targetBackMask; 
figure(16); imshow(imFinal_all);
imwrite(imFinal_all, 'makeup_target.jpg');
