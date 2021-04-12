function resultant = lip_makeup(targetLipCut, reflipmaskw, targetlipmask)

ref = rgb2lab(reflipmaskw);
target = rgb2lab(targetlipmask);
refl = ref(:,:,1);
refa = ref(:,:,2);
refb = ref(:,:,3);
targetl = target(:,:,1);

refleq = histeq(refl);
targetleq = histeq(targetl);

resultant = target;
% for l,a,b channel transfer
[rx, ry] = size(refl);
[tx, ty] = size(targetl);

h = waitbar(0,'Applying lip makeup...');
set(h,'Name','Lip makeup Progress');
for i = 1:tx
    for j = 1:ty
        I_l = targetleq(i,j);
        max_gaussian = -1;
        max_i = i;
        max_j = j;
        if (targetLipCut(i,j)>0)
            for m = 1:rx
                for n = 1:ry
                    if targetLipCut(m,n) > 0
                        E_l = refleq(m,n);
                        intensity_diff = abs(E_l - I_l);
                        dist_pixel = sqrt((i-m)^2 + (j-n)^2);   
                        gaussian_val = gaussian(dist_pixel) * gaussian(intensity_diff);
                        if (gaussian_val > max_gaussian) 
                            max_i = m;
                            max_j = n;
                            max_gaussian = gaussian_val;
                        end        
                    end 
                end
            end
        end
%         resultant(i,j,1) = refl(max_i, max_j);
        resultant(i,j,2) = refa(max_i, max_j);
        resultant(i,j,3) = refb(max_i, max_j);
    end
    waitbar(i/tx);
end
% Close waitbar.
close(h);

resultant(:,:,1) = resultant(:,:,1) .* targetLipCut;
resultant(:,:,2) = resultant(:,:,2) .* targetLipCut;
resultant(:,:,3) = resultant(:,:,3) .* targetLipCut;

figure; clf; 
imshow(resultant);
title('lip makeup');
imwrite(uint8(4.*resultant),'LipMakeup.jpg'); 

end

function res = gaussian(x) 
res = exp(-(x^2) / 2);
end 



