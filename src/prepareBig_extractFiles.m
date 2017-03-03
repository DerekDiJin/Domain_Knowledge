%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes the SF matrix
% The input is the struct containing variables related to the training
% datasets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [G_b theFiles_train_names_str] = prepareBig_extractFiles( theFiles_train, dataFolder, extra )

theFiles_train_names = {theFiles_train(:).name};
theFiles_train_names_str = char(theFiles_train_names);

N_train = length(theFiles_train_names);


for i=1:N_train
    
    curFile_name = strcat(dataFolder, theFiles_train_names_str(i,:))
    data = load(curFile_name);
    data_matrix = data.H;
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
    if extra == 0
        betweennes = centrality(G, 'betweenness');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % feature selection from MATLAB_BGL
    % totally 3 for directed graphs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data_matrix(all, all) = 0;
    cc = clustering_coefficients(data_matrix);
%     core = core_numbers(data_matrix);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Extra features
    % part of the 12 extra features are added here
    % should be processed using Scott's rule as well
    % note that some features might be less than $all
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    if extra == 1
        % Betweennes	EigenVector	NetworkConstraint
        extraFeature_dir = '../extra_Features/';
        temp = dlmread(strcat(extraFeature_dir, strrep(theFiles_train_names_str(i,:), '.mat', ''), '/node_centrality.out'));
        if size(temp, 1) < all
            temp(end+1:all,:) = zeros((all-size(temp,1)),3);
        end
        betweennes = temp(:,1);
        EigenVector = temp(:,2);
        NetworkConstraint = temp(:,3);

        % communities
        temp = dlmread(strcat(extraFeature_dir, strrep(theFiles_train_names_str(i,:), '.mat', ''), '/communities_fast.out'));
        if size(temp, 1) < all
            temp(end+1:all,:) = 0;
        end
        communities = temp;

        % wcc & scc
        temp = dlmread(strcat(extraFeature_dir, strrep(theFiles_train_names_str(i,:), '.mat', ''), '/wcc.out'));
        if size(temp, 1) < all
            temp(end+1:all,:) = zeros((all-size(temp,1)),2);
        end
        wcc = temp(:,2);

        temp = dlmread(strcat(extraFeature_dir, strrep(theFiles_train_names_str(i,:), '.mat', ''), '/scc.out')');
        if size(temp, 1) < all
            temp(end+1:all,:) = zeros((all-size(temp,1)),2);
        end
        scc = temp(:,2);

        % rolx
        temp = dlmread(strcat(extraFeature_dir, strrep(theFiles_train_names_str(i,:), '.mat', ''), '/roles.out'));
        if size(temp, 1) < all
            temp(end+1:all,:) = zeros((all-size(temp,1)),1);
        end
        rolx = temp;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Local patterns for egonets
    % total number of edges, total degree of the egonet, 
    % average number of neighbors of each egonet, number of nodes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    locals = localFeatures(all, data_matrix, src, dst, m, n, 'long');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if extra == 1
        temp = [indegree outdegree pr incloseness outcloseness hubs authorities cc betweennes EigenVector NetworkConstraint locals{1} locals{2} locals{3} locals{4} locals{5} locals{6} communities wcc scc rolx];
    elseif extra == 0
        temp = [indegree outdegree pr incloseness outcloseness hubs authorities cc betweennes locals{1} locals{2} locals{3} locals{4} locals{5} locals{6}];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 
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