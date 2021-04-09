function targFilled = PoissonGrayBlend (refCut, refLight, targetLight)

TargImPaste = double(targetLight);
%Calulating divergance of Guiding vectors: div((Gx,Gy))=Laplacian(G)
h = [0 -1 0; -1 4 -1; 0 -1 0];
LaplacianSource = imfilter(double(refLight), h, 'replicate');
TargImPaste(logical(refCut (:))) = LaplacianSource(logical(refCut(:)));
adjacencyMat = calcAdjancency(refCut);
targBoundry = bwboundaries(refCut, 8);

targFilled = PoissonGrayImEditor(TargImPaste, refCut, adjacencyMat, targBoundry);
end
