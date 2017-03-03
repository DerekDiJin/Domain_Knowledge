function [ set ] = scalability_1_addNoise( set, times )
% set is the set of features with varied lengths, times is the amount
% of extension


F = size(set, 2);

for j = 1:1:times
    for i = 1:1:F
        curF = set{i};    
        newF = curF + (max(curF)-min(curF))*0.3*rand(size(curF,1),1);
        %curF + rand(size(curF,1),1);
        set{end+1} = newF;
    end
end
set;
end

