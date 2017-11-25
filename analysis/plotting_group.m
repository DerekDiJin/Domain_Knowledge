
% G_o = reconstrcutG(G_b_Soc, {1, 2, 3});
G_o = reconstrcutG(G_b_Control, {1, 2, 3});
G_o{end+1} = G_t{1};

T = size(G_o,2);
F = 11%size(G_o{1},2);

figure('units','normalized','position',[.5 .5 1.0 1.0]);

handle = tight_subplot(T, F, [0.045 .004], [0.05 0.05], [0.05 0.05]);

features_b = {'degree', 'PageRank', 'closeness', 'eigenvector', 'cc', 'betweennes', ...
    'author', 'cc', 'betwe', 'EigenV', 'degree\_w'
    };

features = {'indeg', 'outdeg', 'pr', 'inclos', 'outclos', 'hubs', ...
    'author', 'cc', 'betwe', 'EigenV', 'NetCons', ...
    'EGO(outedge)', 'EGO(outnode)', 'EGO(inedge)', 'EGO(innode)', 'EGO(edge)', ...
    'EGO(node)', 'commu', 'wcc', 'scc', 'rolx', 'coda_in', 'coda_out', 'motifs', ...
    'ncp', 'sngVal', 'sngVecL', 'hop'
    };
% features = {'', '', '', '', '', '', '', '', '', '', ''};
% features = {'1.indegree', '2.outdegree', '3.pagerank', '4.incloseness', '5.outcloseness', '6.hubs', ...
%     '7.authority', '8.clustering coefficient', '9.betweeness', ...
%     '10.EGO(outedge)', '11.EGO(outnode)', '12.EGO(inedge)', '13.EGO(innode)', '14.EGO(edge)', ...
%     '15.EGO(node)', 'outdegree_w'
%     };

%indegree outdegree pr incloseness outcloseness hubs authorities cc betweennes 
% EigenVector NetworkConstraint locals{1} locals{2} locals{3} locals{4} locals{5} 
% locals{6} communities wcc scc rolx coda_in coda_out motifs ncp sngVal sngVecL hop


ax = {};
for i = 1:T
    
    G = G_o{i};   
    
    for j = 1:F
        
        curF = G(:,j);
        axes(handle(((i-1)*F+j)));
%         ax{i}{j} = subplot( T,F,((i-1)*F+j) );      % add the jth plot in F x 1 grid
%         [count value] = hist(curF, min(curF):(max(curF)-min(curF))/(149):max(curF));
%         plot(log10(value), log10(count), 'o')
        [N edges bin] = histcounts(curF, 'BinMethod', 'scott');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Linear fd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         edges_linear = (edges(1:end-1) + edges(2:end))/2;
%         plot(edges_linear, N/sum(N), 'o');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Log fd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        edges_log = log10((edges(1:end-1) + edges(2:end))/2);
        plot(edges_log, log10(N/sum(N)), 'o');
        xlim([min(edges_log), max(edges_log)])
        
%         xLimits = get(gca,'XLim');
%         set(gca, 'Xlim', ([0 xLimits(2)]));
%         display(min(curF))
%         display(max(curF))
        title(features_b(j))        
    end
    
end


% for i = 1:F
%     temp = [];
%     for j = 1:T
%         temp = [temp ax{j}{i}];
%     end
%     linkaxes(temp, 'xy');
% end
% 
