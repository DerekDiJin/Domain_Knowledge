%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes the SF matrix
% The input is the struct containing variables related to the training
% datasets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function G_b = prepareSmall_extractFiles( theFiles_train, dataFolder )

theFiles_train_names = {theFiles_train(:).name};
theFiles_train_names_str = char(theFiles_train_names);

N_train = length(theFiles_train_names);


for i=1:N_train
    
    curFile_name = strcat(dataFolder, theFiles_train_names_str(i,:));
    data = load(curFile_name);
    data_matrix = full(data.fibergraph);
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

    G_b{i} = temp;
end
    G_b;
    
end