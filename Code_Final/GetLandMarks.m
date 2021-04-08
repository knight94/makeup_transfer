% =========================================================================
%         Landmark detector using TCDCN face alignment tool (68 points)
% =========================================================================
% [1] Zhanpeng Zhang, Ping Luo, Chen Change Loy, Xiaoou Tang. Facial Landmark Detection 
%     by Deep Multi-task Learning, in Proceedings of European Conference on Computer Vision (ECCV), 2014
% 
% [2] Zhanpeng Zhang, Ping Luo, Chen Change Loy, Xiaoou Tang. Learning Deep Representation for Face Alignment  
%     with Auxiliary Attributes. Technical report, arXiv:1408.3967v2, 2014.
% =========================================================================
function [fpts] = GetLandMarks(InputFilePath)
addpath('../TCDCN-face-alignment-master/TCDCN/');
addpath(genpath('../toolbox-master'))

%%IMage reading
path = InputFilePath;
im = imread(path);
f = figure;
imshow(im);
ax = gca;
A = round(wait(imrect(ax)));
close(f);


%% paramter setup
listFileName = 'list.txt';
modelFile = 'C:/Users/nsahu/Documents/Semester-I/COL783/Assignment_2/TCDCN-face-alignment-master/model.mat';
outputFileName = 'output.txt';

fileID = fopen('list.txt','w');
fprintf(fileID,'%s %d %d %d %d\n', path, A(1), A(2), A(3), A(4));
fclose(fileID);
%% run
main(listFileName,modelFile,outputFileName)

%%Visualization
fid = fopen('output.txt','rt');
for i = 1:1
    filename = fgetl(fid);
    fpts = fscanf(fid,'%f',136)+1;
    fgetl(fid);
    fpts = reshape(fpts,[2 68]);
    fpts = fpts';
    
    img = imread(filename);
    f = figure;
    imshow(img);
    hold on;
    plot(fpts(:,1),fpts(:,2),'o','MarkerEdgeColor', 'k', 'MarkerFaceColor','green');
    %Adding extra landmarks for upper face
    k = 5;
    for p = 1:k
        [x,y] = getpts(f);
        fpts(end+1,:) = [x,y];
    end
%     T = delaunay(fpts(:,1), fpts(:,2));
%     trimesh(T, fpts(:,1), fpts(:,2));
    hold off;
end
end

