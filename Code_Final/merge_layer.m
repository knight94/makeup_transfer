function imFinal_all = merge_layer(targetCIELab, FaceL_HighLight, L_Detail, FaceColora, FaceColorb, lip_makeup, targetBackMask)

    imFinal = zeros(size(targetCIELab));
    LipL_HighLight = lip_makeup(:,:,1);
    LipColora = lip_makeup(:,:,2); 
    LipColorb = lip_makeup(:,:,3); 
    imFinal(:,:,1) = FaceL_HighLight + LipL_HighLight + L_Detail;
    imFinal(:,:,2) = FaceColora + LipColora;
    imFinal(:,:,3) = FaceColorb + LipColorb;

    imFinal = lab2rgb(imFinal);
    imFinal_all = imFinal + targetBackMask; 
    figure;clf;
    imshow(imFinal_all);
    title('Subject Make Up');
    imwrite(imFinal_all,'Subject_Make_up.jpg'); 

end
