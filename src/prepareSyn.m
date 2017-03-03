%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes the SF matrix
% The input is the struct containing variables related to the training
% datasets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [G_b G_t] = prepareSyn(N_train, M, N)


for i=1:N_train+1
    i
    data_matrix = ceil(sprand(M,N,0.01));
    
    [m n] = size(data_matrix);
    all = max(m,n);
    
    nodeIDs = cell(all,1);
    for j=1:all
        nodeIDs{j} = num2str(j);
    end
    [src,dst, wei] = find(data_matrix);
    edges = [src,dst];

    G = digraph(src,dst, wei, nodeIDs);
    % p = plot(G,'Layout','layered','EdgeLabel',wei);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % feature selection from MATLAB
    % totally F for directed graphs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    indegree = centrality(G,'indegree');
    outdegree = centrality(G,'outdegree');
    pr = centrality(G,'pagerank','FollowProbability',0.85);
    incloseness = centrality(G, 'incloseness');
    outcloseness = centrality(G, 'outcloseness');
    hubs = centrality(G, 'hubs');
    authorities = centrality(G, 'authorities');
    
    
        
    temp = [indegree outdegree pr incloseness outcloseness hubs authorities];
    
    if i == N_train+1
        G_t{1} = temp;
    else
        G_b{i} = temp;
    end
end
    G_b;
    
end