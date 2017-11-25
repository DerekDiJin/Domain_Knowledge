%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis of the sensitivity, create experiment plot 3
% usage: 
% 1) load the processed data files before running this script;
% 2) hardcode the trainfile, testfile name 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc;
rng(17);
theFiles_train_names_str = {'cit-HepTh.mat', 'soc-Slashdot0811.mat', 'brain.mat'};
theFile_test_name_str = 'cit-HepPh.mat';%'soc-Slashdot0902.mat';%%

temp1 = load('G_b_cit-HepTh.mat');
temp2 = load('G_b_soc-Slashdot0811.mat');
temp3 = load('G_b_brain.mat');
G_b = temp3.G_b;
G_b{2} = temp1.G_b{1};
G_b{3} = temp2.G_b{1};

load('G_t_cit-HepPh.mat');


% theFiles_train_names_str = 'soc-Slashdot0811.mat';
% theFile_test_name_str = 'soc-Slashdot0902.mat';


% obtain all features for SF and h 
BFK = SF_cal_prep(G_b, theFiles_train_names_str, 0, 'scott', 0, 0);
G_t_BF = h_cal_prep(BFK, G_t, theFile_test_name_str, 0, 'scott', 0, 0);

 
% calculate SF and h
[SF SFK] = SF_cal(BFK, 'DTW'); %<<<---    
display('SF done')

[h hK] = h_cal(G_t_BF, BFK, 'DTW', 'dis');%   <<<---             
display('h done')

F = size(SF, 1);

lambda1 = 1/F; % F*F 
lambda2 = 1; %   
lambda3 = -ceil((lambda1+lambda2)/max(h))-1;%2; % F      
     
% lambdas = [1/(1024*F), 1/(512*F), 1/(256*F), 1/(128*F), 1/(64*F), 1/(32*F), 1/(16*F), 1/(8*F), 1/(4*F), 1/(2*F), 1/F, 2/F, 4/F, 8/F, 16/F, 32/F, 64/F, 128/F, 256/F, 512/F, 1024/F];
lambdas1 = [1/(32*F), 1/(16*F), 1/(8*F), 1/(4*F), 1/(2*F), 1/F, 2/F, 4/F, 8/F, 16/F, 32/F];    % lambda 1
lambdas2 = [1/(32), 1/(16), 1/(8), 1/(4), 1/(2), 1, 2, 4, 8, 16, 32];    % lambda2
lambdas3 = [1/(16), 1/(8), 1/(4), 1/(2), 1, 2, 4, 8, 16, 32, 64];    %  lambda3

% lambdas = [0.2/F, 0.3/F, 0.4/F, 0.5/F, 0.6/F, 0.7/F, 0.8/F, 0.9/F, 1/F, 1.1/F, 1.2/F, 1.3/F, 1.4/F, 1.5/F, 1.6/F, 1.7/F, 1.8/F];


selection_count = [];
selection = [];


for i =1:1:length(lambdas1)      
    display(strcat('lambda: ', num2str(i)));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    % Run MIQP_flex        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    display('In MIQP_flex'); 
    
    [xLinInt fval iter] = MIQP_flex (SF, h, lambdas1(i), lambdas2(i), -lambdas3(i));         
%     [xLinInt fval iter] = MIQP_fixed(SF, h, lambdas(i), lambda2, lambda3, 10);     

    display('------');
    selection(end+1,:) = xLinInt(1:F);
    selection_count(end+1) = length(find(xLinInt == 1));
    

    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The above analysis is time-consuming: below plots the recorded results
% Run the below code to get the result in the paper.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lambdas_test = -[1/(16), 1/(8), 1/(4), 1/(2), 1, 4, 8, 16, 32, 64];    %  lambda3
lambdas = -[1/(16), 1/(8), 1/(4), 1/(2), 1, 2, 4, 8, 16, 32, 64];    %  lambda3


temp = load('../records/sens_lambda3_log.mat');    %<<<---
selection = temp.selection;
test = selection([1:5 7:end],:)


figure('units','normalized','position',[.5 .5 .5 .4]);

D_ham = pdist2(test, selection((1+end)/2, :), 'hamming');
acc = 1 - D_ham';
yyaxis left
plot(log2(lambdas_test(1:end)), acc(1:end), 'd-', 'linewidth', 4);
ylabel('Percentage')
ylim([0 1])

D = pdist2(selection,zeros(1,21), 'squaredeuclidean');
yyaxis right
plot(log2(lambdas), D', 'd-.', 'linewidth', 4);
hold on;
plot(log2(-2), D((1+end)/2),'*', 'Color', 'b', 'MarkerSize',15);
txt = 'Default Value   ';
text(log2(-2),D((1+end)/2),txt, 'HorizontalAlignment','right', 'FontSize',20)
ylabel('# features selected')
grid;

xlabel('log_2\lambda_3');    %<<<---
% xticks([-10 -8 -6 -4 -2 0 2])
% xticklabels({'-10','-8','-6','-4','-2','0','2'})
% xlim([0 450])
% set(gca, 'XTick',[-12 -10 -8 -6 -4 -2 0 2 4 6])
set(gca,'fontsize',20)



lambdas_test = [1/(32*F), 1/(16*F), 1/(8*F), 1/(4*F), 1/(2*F), 2/F, 4/F, 8/F, 16/F, 32/F];
lambdas = [1/(32*F), 1/(16*F), 1/(8*F), 1/(4*F), 1/(2*F), 1/F, 2/F, 4/F, 8/F, 16/F, 32/F];

temp = load('../records/sens_lambda1_log.mat');    %<<<---
selection = temp.selection;
test = selection([1:5 7:end],:)


figure('units','normalized','position',[.5 .5 .5 .4]);

D_ham = pdist2(test, selection((1+end)/2, :), 'hamming');
acc = 1 - D_ham';
yyaxis left
plot(log2(lambdas_test(1:end)), acc(1:end), 'd-', 'linewidth', 4);
ylabel('Percentage')
ylim([0 1])

D = pdist2(selection,zeros(1,21), 'squaredeuclidean');
yyaxis right
plot(log2(lambdas), D', 'd-.', 'linewidth', 4);
hold on;
plot(log2(lambdas((1+end)/2)), D((1+end)/2),'*', 'Color', 'b','MarkerSize',15);
txt = '  Default Value   ';
text(log2(lambdas((1+end)/2)),D((1+end)/2),txt, 'HorizontalAlignment', 'left', 'FontSize',20)
ylabel('# features selected')
grid;

xlabel('log_2\lambda_1');    %<<<---
% xticks([-10 -8 -6 -4 -2 0 2])
% xticklabels({'-10','-8','-6','-4','-2','0','2'})
% xlim([0 450])
% set(gca, 'XTick',[-12 -10 -8 -6 -4 -2 0 2 4 6])
set(gca,'fontsize',20)









figure('units','normalized','position',[.5 .5 .5 .4]);

lambdas = [1/(32*F), 1/(16*F), 1/(8*F), 1/(4*F), 1/(2*F), 1/F, 2/F, 4/F, 8/F, 16/F, 32/F];
lambda_all = lambdas;
lambdas = [1/(32), 1/(16), 1/(8), 1/(4), 1/(2), 1, 2, 4, 8, 16, 32];    % lambda2
lambda_all(2,:)=lambdas;
lambdas = [1/(16), 1/(8), 1/(4), 1/(2), 1, 2, 4, 8, 16, 32, 64];    %  lambda3
lambda_all(3,:)=lambdas;

all_D = load('../records/all_D.mat');
test = selection_count; % from code defined in line 52.
xValues = [1/(32), 1/(16), 1/(8), 1/(4), 1/(2), 1, 2, 4, 8, 16, 32];

plot(log2(xValues), test, 'd-.', 'linewidth', 4);

ylabel('# features');
xlabel('log_2 times of default value');
% ylim([10, max(test)]);
grid
set(gca,'fontsize',20)
set(gca, 'XTick',log2(xValues))
 
 % temp = load('times_soc-Slashdot.mat');
% times = temp.times;
% loglog(candidates, mean(times), '*-');
% hold off;
% grid;
% legend('citation graphs', 'social graphs');
% xlabel('# features');
% ylabel('runtime (s)');

% figure('units','normalized','position',[.5 .5 .5 .4]);
% temp = load('times_cit.mat');
% times = temp.times;
% loglog(candidates, mean(times), 'b*-');
% hold on;
% temp = load('times1_cit.mat');
% times_1 = temp.times_1;
% temp = load('times2_cit.mat');
% times_2 = temp.times_2;
% loglog(candidates, mean(times-(times_1+times_2)), 'c*-');
% 
% temp = load('times_soc.mat');
% times = temp.times;
% loglog(candidates, mean(times), 'r*-');
% 
% temp = load('times1_soc.mat');
% times_1 = temp.times_1;
% temp = load('times2_soc.mat');
% times_2 = temp.times_2;
% loglog(candidates, mean(times-(times_1+times_2)), 'm*-');
% 
% grid;
% legend('citation graph: total', 'citation graph: MIQP', 'social graph: total', 'social graph: MIQP');
% 
% xlabel('# features');
% ylabel('runtime (s)');
% xlim([0 450])
% set(gca,'fontsize',16)