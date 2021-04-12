function [XDoG] = XDoG_T(DoG, epsilon, phi)
    XDoG = zeros(size(DoG));
    for i = 1:size(DoG,1)
        for j = 1:size(DoG,2)
            if (DoG(i,j) >= epsilon)
                XDoG(i,j) = 1;
            else
                XDoG(i,j) = 1 + tanh(phi*(DoG(i,j)));
            end
        end
    end
end

