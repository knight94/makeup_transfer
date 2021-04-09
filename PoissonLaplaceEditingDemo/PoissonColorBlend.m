function targFilled = PoissonColorBlend (refCut, refLight, targetLight)

TargImPasteR = double(targetLight(:,:,1));
TargImPasteG = double(targetLight(:,:,2));
TargImPasteB = double(targetLight(:,:,3));
%Calulating divergance of Guiding vectors: div((Gx,Gy))=Laplacian(G)
h = [0 -1 0; -1 4 -1; 0 -1 0];
LaplacianSource = imfilter(double(refLight), h, 'replicate');
VR = LaplacianSource(:, :, 1);
VG = LaplacianSource(:, :, 2);
VB = LaplacianSource(:, :, 3);

TargImPasteR(logical(refCut(:))) = VR(logical(refCut(:)));
TargImPasteG(logical(refCut(:))) = VG(logical(refCut(:)));
TargImPasteB(logical(refCut(:))) = VB(logical(refCut(:)));

adjacencyMat = calcAdjancency(refCut);
targBoundry = bwboundaries(refCut, 8);

targFilledR = PoissonGrayImEditor(TargImPasteR, refCut, adjacencyMat, targBoundry);
targFilledG = PoissonGrayImEditor(TargImPasteG, refCut, adjacencyMat, targBoundry);
targFilledB = PoissonGrayImEditor(TargImPasteB, refCut, adjacencyMat, targBoundry);

targFilled = cat(3,targFilledR, targFilledG, targFilledB);
end
