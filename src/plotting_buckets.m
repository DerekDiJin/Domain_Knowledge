
G_o = G_b;
G_o{size(G_b,2)+1} = G_t{1};
G = G_o{2};

F = [];
F(:,1) = G(:,2);
F(:,2) = G(:,3);

M = 2;
P = 5;

figure('units','normalized','position',[.5 .5 .7 .7]);
handle = tight_subplot(M, P, [0.045 .04], [0.05 0.05], [0.05 0.05]);
% handle = figure('units','normalized','position',[.5 .5 .7 .7])
% features = {'indegree', 'outdegree', 'pr', 'incloseness', 'outcloseness', 'hubs', 'authorities', 'cc'};
labels = {'10^{-1} Range', '10^{-2} Range', '10^{-4} Range', 'unique', 'Scott'};
properties = {'Out-degree', 'PageRank'};

ax = {};
for i = 1:M
    
    curF = F(:,i);
    
    for j = 1:P
        
        
%         ax{i}{j} = subplot( M, P, ((i-1)*P+j) );      % add the jth plot in F x 1 grid       
        axes(handle(((i-1)*P+j)));
        if j == 1
            [count value] = hist(curF, min(curF):(max(curF)-min(curF))/(9):max(curF));
            loglog(value, count/sum(count), 'o')
%             xt = xlabel(labels(j));
            xt.FontSize = 12;
            xt.FontWeight = 'bold';
            yt = ylabel(strcat('Probability (', properties(i), ')'));
            yt.FontSize = 12;
            yt.FontWeight = 'bold';

        end
        if j == 2
            [count value] = hist(curF, min(curF):(max(curF)-min(curF))/(99):max(curF));
            loglog(value, count/sum(count), 'o')
%             xt = xlabel(labels(j));
            xt.FontSize = 12;
            xt.FontWeight = 'bold';
%             yt = ylabel('Probability');
            yt.FontSize = 12;
            yt.FontWeight = 'bold';

        end
        if j == 3
            [count value] = hist(curF, min(curF):(max(curF)-min(curF))/(9999):max(curF));
            loglog(value, count/sum(count), 'o')
%             xt = xlabel(labels(j));
            xt.FontSize = 12;
            xt.FontWeight = 'bold';
%             yt = ylabel('Probability');
            yt.FontSize = 12;
            yt.FontWeight = 'bold';
        end
        if j == 4
            [count value] = hist(curF, unique(curF));
            loglog(value, count/sum(count), 'o')
%             xt = xlabel(labels(j));
            xt.FontSize = 12;
            xt.FontWeight = 'bold';
%             yt = ylabel('Probability');
            yt.FontSize = 12;
            yt.FontWeight = 'bold';
        end
        
        if j == 5
            [N edges bin] = histcounts(curF, 'BinMethod', 'scott');
            edges = (edges(1:end-1) + edges(2:end))/2;
            loglog(edges, (N/sum(N)), 'o');
%             xt = xlabel(labels(j));
            xt.FontSize = 12;
            xt.FontWeight = 'bold';
%             yt = ylabel('Probability');
            yt.FontSize = 12;
            yt.FontWeight = 'bold';
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Linear fd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         edges_linear = (edges(1:end-1) + edges(2:end))/2;
%         plot(edges_linear, N/sum(N), 'o');
        if i == 1
            title(labels(j))   
        end
    end
    
end

set(findall(gcf,'type','text'),'FontSize',17,'fontWeight','bold')
% tight_subplot([0 0 0 0], [.02 .02]);
% tightfig;
% for i = 1:M
%     temp = [];
%     for j = 1:P
%         temp = [temp ax{i}{j}];
%     end
% %     linkaxes(temp, 'xy');
%     axis(temp,[10e1 10e3 10e-6 10e-2])
% end

