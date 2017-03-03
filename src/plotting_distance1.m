clear;clc;
xmin  = 1;
alpha = 1.5;
n1 = 100100;
B = 1000;
frac = 1;

curF = floor((xmin-0.5)*(1-rand(n1, 1)).^(-1/(alpha-1)) + 0.5);
curF = sort(curF);
curF = curF(1:end-100);

[N value1] = hist(curF,min(curF):(max(curF)-min(curF))/(B-1):max(curF));
counts1 = N' ./ sum(N);
figure;
loglog(value1, counts1, 'o');

n2 = 10100;
curF = floor((xmin-0.5)*(1-rand(n2, 1)).^(-1/(alpha-1)) + 0.5);
curF = sort(curF);
curF = curF(1:end-100);

[N value2] = hist(curF,min(curF):(max(curF)-min(curF))/(B-1):max(curF));
counts2 = N' ./ sum(N);
figure;
loglog(value2, counts2, 'o');

sim_L2(counts1, counts2)
1/(1+dtw(counts1, counts2))
% [counts,value]=hist(curF,unique(curF));
% loglog(value, counts, 'o');




% G_o = G_b;
% G_o{size(G_b,2)+1} = G_t{1};
% G = G_o{3};
% 
% F = [];
% F(:,1) = G(:,2);
% F(:,2) = G(:,3);
% 
% M = 2;
% P = 5;
% 
% handle = figure('units','normalized','position',[.5 .5 .7 .7])
% % features = {'indegree', 'outdegree', 'pr', 'incloseness', 'outcloseness', 'hubs', 'authorities', 'cc'};
% granularity = {'10^{-1} Range', '10^{-2} Range', '10^{-4} Range', 'unique', 'FD'};
% labels = {'Out-degree', 'Pagerank'};
% 
% deg = F(:,1);
% [count value] = hist(deg, min(deg):(max(deg)-min(deg))/(9999):max(deg));            
% loglog(value, count/sum(count), 'o')
% 
% [count value] = hist(deg, unique(deg));          
% loglog(value, count/sum(count), 'o')

