function FaceL_HighLight = highlight_transfer(targetFaceCut, l2Ref, l2Target, beta_arr)
    disp ('Lightness Layer, face highlight transfer');
    FaceL_HighLight = poisson_image_edit(targetFaceCut, l2Ref, l2Target, beta_arr); 
    FaceL_HighLight = FaceL_HighLight .* targetFaceCut;
    figure; clf;
    imshow(FaceL_HighLight);
    title('Lightness Layer, highlight transfer');
    imwrite(uint8(4.*FaceL_HighLight),'faceHighLightTransfer.jpg');
end




