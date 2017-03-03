function [ localFeatures ] = localFeatures( all, data_matrix, src, dst, m, n, mod )
%LOCALFEATURES Summary of this function goes here
%   Detailed explanation goes here
    localFeatures = {};
    if strcmp(mod, 'long') == 1
        egoFromEdges = zeros(all, 1);
        egoFromNodes = zeros(all, 1);
        egoToEdges = zeros(all, 1);
        egoToNodes = zeros(all, 1);

        egoEdges = zeros(all, 1);
        egoNodes = zeros(all, 1);
        for i=1:min(m, n)
            toNodes = find(data_matrix(i,:)~=0);
            fromNodes = find(data_matrix(:,i)~=0);
            allNodes = union(toNodes, fromNodes);
            allNodes_i = union(allNodes, i);
            outNodes = find(ismember((1:all), allNodes_i)==0);

            [egoToEdges(i), egoToNodes(i)] = findCrossEdges(allNodes_i, outNodes, src, dst, 'to');
            [egoFromEdges(i), egoFromNodes(i)] = findCrossEdges(allNodes_i, outNodes, src, dst, 'from');

            egoEdges(i) = findEgoEdges(allNodes_i, src, dst);
            egoNodes(i) = length(allNodes);
            i
        end
        for i=min(m, n)+1:max(m, n)
            if m > n
                allNodes = find(data_matrix(i,:)~=0);
                allNodes_i = union(allNodes, i);
                outNodes = find(ismember((1:all), allNodes_i)==0);

                [egoToEdges(i), egoToNodes(i)] = findCrossEdges(allNodes_i, outNodes, src, dst, 'to');
                [egoFromEdges(i), egoFromNodes(i)] = findCrossEdges(allNodes_i, outNodes, src, dst, 'from');

                egoEdges(i) = findEgoEdges(allNodes_i, src, dst);
                egoNodes(i) = length(allNodes);
            else
                allNodes = find(data_matrix(:,i)~=0);
                allNodes_i = union(allNodes, i);
                outNodes = find(ismember((1:all), allNodes_i)==0);

                [egoToEdges(i), egoToNodes(i)] = findCrossEdges(allNodes_i, outNodes, src, dst, 'to');
                [egoFromEdges(i), egoFromNodes(i)] = findCrossEdges(allNodes_i, outNodes, src, dst, 'from');

                egoEdges(i) = findEgoEdges(allNodes_i, src, dst);
                egoNodes(i) = length(allNodes);
            end
        end
        localFeatures{1} = egoToEdges;
        localFeatures{2} = egoToNodes;
        localFeatures{3} = egoFromEdges;
        localFeatures{4} = egoFromNodes;
        localFeatures{5} = egoEdges;
        localFeatures{6} = egoNodes;
        
        
    elseif strcmp(mod, 'short') == 1
        
        egoEdges = zeros(all, 1);
        egoNodes = zeros(all, 1);
        for i=1:min(m, n)
            toNodes = find(data_matrix(i,:)~=0);
            fromNodes = find(data_matrix(:,i)~=0);
            allNodes = union(toNodes, fromNodes);
            allNodes_i = union(allNodes, i);
            
            egoEdges(i) = findEgoEdges(allNodes_i, src, dst);
            egoNodes(i) = length(allNodes);
            i
        end
        for i=min(m, n)+1:max(m, n)
            if m > n
                allNodes = find(data_matrix(i,:)~=0);
                allNodes_i = union(allNodes, i);
                
                egoEdges(i) = findEgoEdges(allNodes_i, src, dst);
                egoNodes(i) = length(allNodes);
            else
                allNodes = find(data_matrix(:,i)~=0);
                allNodes_i = union(allNodes, i);
                
                egoEdges(i) = findEgoEdges(allNodes_i, src, dst);
                egoNodes(i) = length(allNodes);
            end
        end
        
        localFeatures{1} = egoEdges;
        localFeatures{2} = egoNodes;
        
    end
    
    

end

