function [FaceColora, FaceColorb] = color_transfer(alphaBlenda, targetFaceCut, targetcolora, targetcolorb, refcolora, refcolorb)
    disp ('Color Layer, face color transfer'); 
    FaceColora = (1 - alphaBlenda) * targetcolora + alphaBlenda * refcolora;
    FaceColora = FaceColora .* targetFaceCut;
    figure;clf;
    subplot(1,2,1); imshow(FaceColora);
    title('Face Color channel a transfer');
    FaceColorb = (1 - alphaBlendb) * targetcolorb + alphaBlendb * refcolorb;
    FaceColorb = FaceColorb .* targetFaceCut;
    subplot(1,2,2); imshow(FaceColorb);
    title('Face Color channel b transfer');
    imwrite(uint8(4.*FaceColora),'faceColoraTransfer.jpg');
    imwrite(uint8(4.*FaceColorb),'faceColorbTransfer.jpg');
end