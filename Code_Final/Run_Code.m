clear all; clc;
%%Input Parameters
InputFilePath_I = 'Images/target/05.jpg';
InputFilePath_R = 'Images/03.jpg';
%%Landmarks Detection
[fpts_I] = GetLandMarks(InputFilePath_I);
[fpts_R] = GetLandMarks(InputFilePath_R);
%%Image warping R to I
T_I = delaunay(fpts_I(:,1), fpts_I(:,2));
T_R = delaunay(fpts_R(:,1), fpts_R(:,2));

img_I = imread(InputFilePath_I);
% f1 = figure;
% imshow(img_I);
% hold on;
% plot(fpts_I(:,1),fpts_I(:,2),'o','MarkerEdgeColor', 'k', 'MarkerFaceColor','green');
% trimesh(T_I, fpts_I(:,1), fpts_I(:,2));
img_R = imread(InputFilePath_R);
figure
imshow(img_R);
hold on;
plot(fpts_R(:,1),fpts_R(:,2),'o','MarkerEdgeColor', 'k', 'MarkerFaceColor','green');
trimesh(T_I, fpts_R(:,1), fpts_R(:,2));

%Affine transformatiion
% R = T*I
% [x y 1] = [a b c; f g h; 0 0 1] [u v 1]

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

%Checking the location of points in I for each triangle location T_I
%THen using calculated function, transform it to R and interpolate the
%pixel intensity to get the final image
warp_R = zeros(size(img_I));
for i = 1:size(img_I,1)
    for j = 1:size(img_I,2)
        P = [j, i];
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
            end
        end
    end
end


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
f = figure;
imshow(I_L./100);
std_R = round(wait(imrect(gca)));
close(f);
patch = imcrop(I_L, std_R);
DOS = 2*std2(sqrt(sum(patch.^2,3)));
I_large = imbilatfilt(I_L, DOS);
imshow(I_large./100);

I_skin = I_L - I_large;
imshow(I_skin*40);

f = figure;
imshow(R_L./100);
std_R = round(wait(imrect(gca)));
close(f);
patch = imcrop(R_L, std_R);
DOS = 2*std2(sqrt(sum(patch.^2,3)));
if (DOS == 0)
    DOS = 0.001;
end
R_large = imbilatfilt(R_L, DOS);
imshow(R_large./100);
R_skin = R_L - R_large;
imshow(R_skin*40);