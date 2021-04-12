function result = poisson_image_edit(mask, example, subject, beta)

[x, y] = size(subject);
result = subject; 

[s_gx, s_gy] = imgrad(subject);
[e_gx, e_gy] = imgrad(example);
grad_mag_s = sqrt((s_gx).^2 + (s_gy).^2);
grad_mag_e = sqrt((e_gx).^2 + (e_gy).^2);

for i = 1:x
    for j = 1:y 
        if mask(i,j) > 0
            if abs(grad_mag_e(i,j))*beta(i,j) > abs(grad_mag_s(i,j))
                s_gx(i,j) = e_gx(i,j); 
                s_gy(i,j) = e_gy(i,j);
            end
        end 
    end 
end 

% subject(mask(:)) 
% subject(mask==1) = example(mask==1);

result = PoissonGaussSeidel(subject, s_gx, s_gy, mask);


% [x, y] = size(subject);
% result = subject; 
% 
% 
% % h = [0 -1 0; -1 4 -1; 0 -1 0];
% h = [[0, 0, -1, 0, 0], [0, -1, -2, -1, 0], [-1, -2, 16, -2, -1], [0, -1, -2, -1, 0], [0, 0, -1, 0, 0]]; 
% 
% LaplacianTarget = imfilter(double(subject), h, 'replicate');
% LaplacianSource = imfilter(double(example), h, 'replicate');
% grad_res = LaplacianTarget;
% 
% sigma = 2;
% guassianTarget = imgaussfilt(subject,sigma);
% 
% for i = 1:x 
%     for j = 1:y 
%         if abs(LaplacianSource(i,j))*beta(i,j) > abs(LaplacianTarget(i,j))
%             grad_res(i,j) = LaplacianSource(i,j);
%         end 
%     end 
% end 
% 
% result = grad_res + guassianTarget;

end 