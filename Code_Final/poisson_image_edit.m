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

result = PoissonGaussSeidel(subject, s_gx, s_gy, mask);

end 
