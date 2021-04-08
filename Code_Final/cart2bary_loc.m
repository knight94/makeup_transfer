function [loc] = cart2bary_loc(Tr,P)
% gamma = alpha - beta
% T = [x1 - x3, x2 - x3
%      y1 - y3, y2 - y3]
% b = [x - x3
%      y - y3]
% [alpha;beta] = T \ b;

% T = [Tr(1,1) - Tr(3,1), Tr(2,1) - Tr(3,1);
%      Tr(1,2) - Tr(3,2), Tr(2,2) - Tr(3,2)];
% b = [P(1) - Tr(3,1);
%      P(2) - Tr(3,2)];
% temp = T \ b;
% bary = [temp(1), temp(2), 1-temp(1)-temp(2)];
T = [[Tr(1,:) 1]', [Tr(2,:) 1]',[Tr(3,:) 1]'];
b = [P(1);
     P(2);
     1];
bary = T \ b;
if (sum(bary>=0) == 3)
    loc = 1;
else
    loc = 0;
end
end

