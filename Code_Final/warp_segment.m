function [warp_R, C, I_c, R_c] = warp_segment(img_I, img_R, fpts_I, fpts_R)
%%Image warping R to I
disp('Doing triangulation...');
T_I = delaunay(fpts_I(:,1), fpts_I(:,2));
%T_R = delaunay(fpts_R(:,1), fpts_R(:,2));

%% 
%% 1:17 face boundary
%% 18:27 -> 18:22 23:27 -> eyebrows
%% 28:36 -> nose
%% 37:42 -> right eye
%% 43:48 -> left eye
%% 49:61 -> Lips
%% 62:68 -> mouth
%% 69:73 -> face boundary


% f1 = figure;
% imshow(img_I);
% hold on;
% plot(fpts_I(:,1),fpts_I(:,2),'o','MarkerEdgeColor', 'k', 'MarkerFaceColor','green');
% trimesh(T_I, fpts_I(:,1), fpts_I(:,2));

disp('Paritioning face region into eyes, mouth, lips and rest...');
%Eye+Mouth
bw1 = poly2mask(fpts_I(37:42,1), fpts_I(37:42,2), size(img_I,1), size(img_I,2));
bw2 = poly2mask(fpts_I(43:48,1), fpts_I(43:48,2), size(img_I,1), size(img_I,2));
bw3 = poly2mask(fpts_I(62:68,1), fpts_I(62:68,2), size(img_I,1), size(img_I,2));
C3_I = bw1+bw2+bw3;

%Lips
C2_I = poly2mask(fpts_I(49:61,1), fpts_I(49:61,2), size(img_I,1), size(img_I,2));

%Rest of face
% bw1 = poly2mask(fpts_I(18:22,1), fpts_I(18:22,2), size(img_I,1), size(img_I,2));
% bw2 = poly2mask(fpts_I(23:27,1), fpts_I(23:27,2), size(img_I,1), size(img_I,2));
bw3 = poly2mask([flipud(fpts_I(1:17,1)); fpts_I(69:73,1)], [flipud(fpts_I(1:17,2)); fpts_I(69:73,2)], size(img_I,1), size(img_I,2));
%bw4 = poly2mask(fpts_I(28:36,1), fpts_I(28:36,2), size(img_I,1), size(img_I,2));
C1_I = bw3 - (C3_I + C2_I);

C_T = bw3;

C = struct();
C.reg1 = C1_I;
C.reg2 = C2_I;
C.reg3 = C3_I;

% figure
% imshow(img_R);
% hold on;
% plot(fpts_R(:,1),fpts_R(:,2),'o','MarkerEdgeColor', 'k', 'MarkerFaceColor','green');
% trimesh(T_I, fpts_R(:,1), fpts_R(:,2));

%Affine transformatiion
% R = T*I
% [x y 1] = [a b c; f g h; 0 0 1] [u v 1]

disp('Calculating transformation matrix from target to reference');
A_T_table = zeros(size(T_I,1),9);
for i = 1:size(T_I, 1)
    X = [fpts_I(T_I(i,1), :), 1, 0, 0, 0;0, 0, 0, fpts_I(T_I(i,1), :), 1;
        fpts_I(T_I(i,2), :), 1, 0, 0, 0;0, 0, 0, fpts_I(T_I(i,2), :), 1;
        fpts_I(T_I(i,3), :), 1, 0, 0, 0;0, 0, 0, fpts_I(T_I(i,3), :), 1];
    b = [fpts_R(T_I(i,1), :), fpts_R(T_I(i,2), :), fpts_R(T_I(i,3), :)]';
    %using mdivide to solve linear equation
    temp = X\b;
    A_T_table(i, :) = [temp', 0, 0, 1];
end

disp('Performing inverse mapping, transform pixel coordinates from I to E');
disp('Calculate pixel intensity using bilinear interpolatin');
%Checking the location of points in I for each triangle location T_I
%THen using calculated function, transform it to R and interpolate the
%pixel intensity to get the final image
warp_R = zeros(size(img_I));
for i = 1:size(img_I,1)
    for j = 1:size(img_I,2)
        P = [j, i];
        if (C_T(i,j) == 1)
            for k = 1:size(T_I,1)
                Tr = [fpts_I(T_I(k,1), :); fpts_I(T_I(k,2), :); fpts_I(T_I(k,3), :)];
                if (cart2bary_loc(Tr,P) == 1)
                %Transform and interpolate
                    new_P = [A_T_table(k, 1:3); A_T_table(k, 4:6); A_T_table(k, 7:9)] * [P';1];
                    P_nn = [floor(new_P(1)), ceil(new_P(1)), floor(new_P(2)), ceil(new_P(2))];
                    for kk = 1:3
                        Q = [img_R(P_nn(3), P_nn(1), kk), img_R(P_nn(4), P_nn(1), kk), img_R(P_nn(4), P_nn(2), kk), img_R(P_nn(3), P_nn(2), kk)];
                        [warp_R(i,j,kk)] = bilinear_inter(Q, P_nn, new_P(1), new_P(2));
                    end
                    %warp_R(i,j,:) = img_R(floor(new_P(2)),floor(new_P(1)),:);
                    break;
                end
            end
        end
    end
end
disp('Image warping/alginment done');
% % %%Landmarks for warped image
% % InputFilePath_Wr = './images/warped_im.jpg';
% % imwrite(warp_R./255, InputFilePath_Wr);
% % [fpts_Wr] = GetLandMarks(InputFilePath_Wr);
% % 
% % %Eye+Mouth
% % bw1 = poly2mask(fpts_Wr(37:42,1), fpts_Wr(37:42,2), size(warp_R,1), size(warp_R,2));
% % bw2 = poly2mask(fpts_Wr(43:48,1), fpts_Wr(43:48,2), size(warp_R,1), size(warp_R,2));
% % bw3 = poly2mask(fpts_Wr(62:68,1), fpts_Wr(62:68,2), size(warp_R,1), size(warp_R,2));
% % C3_E = bw1+bw2+bw3;
% % 
% % %Lips
% % C2_E = poly2mask(fpts_Wr(49:61,1), fpts_Wr(49:61,2), size(warp_R,1), size(warp_R,2));
% % 
% % %Rest of face
% % bw1 = poly2mask(fpts_Wr(18:22,1), fpts_Wr(18:22,2), size(warp_R,1), size(warp_R,2));
% % bw2 = poly2mask(fpts_Wr(23:27,1), fpts_Wr(23:27,2), size(warp_R,1), size(warp_R,2));
% % bw3 = poly2mask([flipud(fpts_Wr(1:17,1)); fpts_Wr(69:73,1)], [flipud(fpts_Wr(1:17,2)); fpts_Wr(69:73,2)], size(warp_R,1), size(warp_R,2));
% % %bw4 = poly2mask(fpts_I(28:36,1), fpts_I(28:36,2), size(img_I,1), size(img_I,2));
% % C1_E = bw3 - (C3_I + C2_I);

disp('Convering to LAB space');
%%convert images to CIELAB space
img_I_lab = rgb2lab(img_I);
img_R_lab = rgb2lab(uint8(warp_R));

I_L = img_I_lab(:,:,1);
I_a = img_I_lab(:,:,2);
I_b = img_I_lab(:,:,3);

R_L = img_R_lab(:,:,1);
R_a = img_R_lab(:,:,2);
R_b = img_R_lab(:,:,3);

%%Separation of the components into detail and large layer using bilateral
%%filter. Large scale layer = output of bilateral filter on L image.
%%Subtract/divide previous from L to get skin/detail layer.
disp('Extracting structure and skin components');
w = 17;
sigma = [3, 8];
% f = figure;
% imshow(I_L./100);
% std_R = round(wait(imrect(gca)));
% close(f);
% patch = imcrop(I_L, std_R);
% DOS = 2*std2(sqrt(sum(patch.^2,3)));
% I_large = imbilatfilt(I_L, DOS);
I_large = bilateral_filter(I_L, w, sigma);
% imshow(I_large./100);

I_skin = I_L - I_large;
% imshow(I_skin*40);

% f = figure;
% imshow(R_L./100);
% std_R = round(wait(imrect(gca)));
% close(f);
% patch = imcrop(R_L, std_R);
% DOS = 2*std2(sqrt(sum(patch.^2,3)));
% if (DOS == 0)
%     DOS = 0.001;
% end
% R_large = imbilatfilt(R_L, DOS);
R_large = bilateral_filter(R_L, w, sigma);
% imshow(R_large./100);
R_skin = R_L - R_large;
% imshow(R_skin*40);

I_c = struct();
I_c.large = I_large;
I_c.skin = I_skin;
I_c.a = I_a;
I_c.b = I_b;

R_c = struct();
R_c.large = R_large;
R_c.skin = R_skin;
R_c.a = R_a;
R_c.b = R_b;

%summary plot
figure
title('Subject image');
subplot(1,4,1)
imshow(I_large./100);
subplot(1,4,2)
imshow(I_skin./255*40);
subplot(1,4,3)
imshow(I_a./100);
subplot(1,4,4)
imshow(I_b./100);

figure
title('Reference image')
subplot(1,4,1)
imshow(R_large./100);
subplot(1,4,2)
imshow(R_skin./255*40);
subplot(1,4,3)
imshow(R_a./100);
subplot(1,4,4)
imshow(R_b./100);
end

