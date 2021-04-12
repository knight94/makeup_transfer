function [C] = calc_xdog(A)
if (size(A, 3) ==3)
    B = im2double(rgb2gray(A));
else
    B = im2double(A);
end

%Parameters
Sigma = 0.5;
k = 1.6;
tau = 0.98;
epsilon = 0.3;

Sigma_1 = Sigma;
Sigma_2 = Sigma*k;
B_Sigma_1 = imgaussfilt(B, Sigma_1);
B_Sigma_2 = imgaussfilt(B, Sigma_2);

B_xDoG_1 = B_Sigma_1 - tau*B_Sigma_2;
% scaled_DoG_1 = Scaled_image(B_xDoG_1, [1,0]);

for i = 1:length(epsilon)
        phi = 200;
        figure(i)
        [B_xDoG_T] = XDoG_T(B_xDoG_1, epsilon(i), phi);
        imshow(B_xDoG_T);
end

C = B_xDoG_T>=mean2(B_xDoG_T);
figure
imshow(C);

end

