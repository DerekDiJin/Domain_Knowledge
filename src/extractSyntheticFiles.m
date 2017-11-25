function [ G_b ] = syntheticFiles(N_train)

A_slice = randi([0 1], 70, 70);
for i = 1:N_train
    temp = find(A_slice==1);
    A_slice(datasample(temp,3)) = 0;
    A(:,:,i) = A_slice;
end
temp = find(A==1);
A(temp) = randi([1 2000],size(temp,1),size(temp,2));

for i=1:N_train
    
    data_matrix = A(:,:,i);
    [m n] = size(data_matrix);
    

    nodeIDs = cell(m,1);
    for j=1:m
        nodeIDs{j} = num2str(j);
    end
    [src,dst, wei] = find(data_matrix);
    edges = [src,dst];

    G = digraph(src,dst, wei, nodeIDs);
    % p = plot(G,'Layout','layered','EdgeLabel',wei);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % feature selection
    % totally 7 for directed graphs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    indegree = centrality(G,'indegree');
    outdegree = centrality(G,'outdegree');
    pr = centrality(G,'pagerank','FollowProbability',0.85);
    incloseness = centrality(G, 'incloseness');
    outcloseness = centrality(G, 'outcloseness');
    hubs = centrality(G, 'hubs');
    authorities = centrality(G, 'authorities');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    temp = [indegree outdegree pr incloseness outcloseness hubs authorities];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     G.Nodes.PageRank = pr;
%     G.Nodes.InDegree = indegree;
%     G.Nodes.OutDegree = outdegree;
%     G.Nodes.InClosseness = incloseness;
%     G.Nodes.OutClosseness = outcloseness;
%     G.Nodes.hubs = hubs;
%     G.Nodes.authorities = authorities;
%     G.Nodes;
%     G_b{end+1} = G;

    G_b(:,:,i) = temp;
end
    G_b;

end

