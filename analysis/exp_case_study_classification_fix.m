%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis of the scalability, create experiment plot 2
% usage: 
% 1) load the processed data files before running this script;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng(17); clear; clc;
% theFiles_train_names_str = {'cit-HepTh.mat', 'soc-Slashdot0811.mat'};
% theFile_test_name_str = 'soc-Slashdot0902.mat';%'cit-HepPh.mat';%
k_baseline = 36;
k_input = 40;
S = 6;
CV_K = 10;
binary = 0;
% type = 'ordinary';
type = 'surprising';

if strcmp(type, 'ordinary') == 1
    mod = 'dis';
else
    mod = 'sim';
end


temp = load('G_b_Neural_Control_pearson0.85.mat');
G_b_Control = temp.G_b_Control;

indices_reorder = datasample(1:length(G_b_Control), length(G_b_Control), 'Replace',false);
indices_baseline = indices_reorder(1:k_baseline);
indices_input_c = indices_reorder(k_baseline+1:end);

G_b = reconstrcutG(G_b_Control, num2cell(indices_baseline));
G_t_Control = reconstrcutG(G_b_Control, num2cell(indices_input_c));

temp = load('G_t_Neural_Patient_pearson0.85.mat'); %<<<---
G_t_Patient = temp.G_t_Patient;

indices_input_p = datasample(1:length(G_t_Patient), k_input, 'Replace',false);
G_t_Patient = reconstrcutG(G_t_Patient, num2cell(indices_input_p));


% obtain all features for SF and h     
BFK = SF_cal_prep(G_b, '', 0, 'scott', 0, 0);    
[SF SFK] = SF_cal(BFK, 'DTW');     
F = size(SF, 1);

result = [];
hs = [];

for i = 1:1:length(G_t_Patient)
    G_t = reconstrcutG(G_t_Patient, {i});
    
    G_t_BF = h_cal_prep(BFK, G_t, '', 0, 'scott', 0, 0);
    
    [h hK] = h_cal(G_t_BF, BFK, 'DTW', mod);
    
    lambda1 = 1 * 1/F; % F*F        
    lambda2 = 0; %          
    lambda3 = 1;
    
    [xLinInt fval iter] = MIQP_fixed (SF, h, lambda1, lambda2, lambda3, S);
    
    [B, I] = sort(h);
    tempp = [I (1:1:length(I))'];
    tempp = sortrows(tempp,1);
    xLinInt_order = tempp(:,2) .* xLinInt(1:F);
    
    result(end+1, :) = xLinInt;
    hs(end+1,:) = h';
%     

end

for i = 1:1:length(G_t_Control)
    G_t = reconstrcutG(G_t_Control, {i});
    
    G_t_BF = h_cal_prep(BFK, G_t, '', 0, 'scott', 0, 0);
    
    [h hK] = h_cal(G_t_BF, BFK, 'DTW', mod);
    
    lambda1 = 1 * 1/F; % F*F        
    lambda2 = 0; %          
    lambda3 = 1;
    
    [xLinInt fval iter] = MIQP_fixed (SF, h, lambda1, lambda2, lambda3, S);
    
    [B, I] = sort(h);
    tempp = [I (1:1:length(I))'];
    tempp = sortrows(tempp,1);
    xLinInt_order = tempp(:,2) .* xLinInt(1:F);
    
    result(end+1, :) = xLinInt;
    hs(end+1,:) = h';
    
end

result = result(:,1:F);
result( find(result < 0.01) ) = 0;
% result( find(result == 0) ) = 11;

labels_p = zeros(length(G_t_Patient), 1);
labels_c = ones(length(G_t_Patient), 1);
labels = [labels_p; labels_c];

if binary == 0
    result = hs .* result;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Baseline 1: average of F properties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
baseline1_Xs = zeros(length(G_t_Patient) + length(G_t_Control), F);
baseline1_Ys = zeros(length(G_t_Patient) + length(G_t_Control), 1);
for i = 1:1:length(G_t_Patient)
    G_t = reconstrcutG(G_t_Patient, {i});
    features = G_t{1};
    averageF = mean(features, 1);
    baseline1_Xs(i, :) = averageF;
end
for i = 1:1:length(G_t_Control)
    G_t = reconstrcutG(G_t_Control, {i});
    features = G_t{1};
    averageF = mean(features, 1);
    baseline1_Xs(i+length(G_t_Patient), :) = averageF;
    baseline1_Ys(i+length(G_t_Patient), 1) = 1;
end
baseline1_Ys = baseline1_Ys;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CV starts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N=30;
CV_EAGLE_sum = 0;
SVMModel = fitcsvm(result,labels, 'Standardize',true,'KernelFunction','RBF');

for i = 1:1:N
    CVSVMModel = crossval(SVMModel,'Holdout',0.1);
    CV_EAGLE_sum = CV_EAGLE_sum + kfoldLoss(CVSVMModel);
end
1-CV_EAGLE_sum / N

% CV_EAGLE_analysis = crossValidation_LOG(result, labels, CV_K)

CV_Baseline1_sum = 0;
SVMModel = fitcsvm(baseline1_Xs ,baseline1_Ys, 'Standardize',true,'KernelFunction','RBF');

analysis_matrix = zeros(N, 5); % 6 metrics are used.

for i = 1:1:N
    CVSVMModel = crossval(SVMModel,'Holdout',0.1);
    CV_Baseline1_sum = CV_Baseline1_sum + kfoldLoss(CVSVMModel);
end
1-CV_Baseline1_sum / N

% CV_EAGLE = crossValidation_LOG(result, labels, CV_K)

for i = 1:1:N
    i
    [ final_accuracy, final_precision, final_recall, final_f1Scores, final_AUC ] = crossValidation_Scores(result, labels, CV_K);
    analysis_matrix(i,:) =  [ final_accuracy, final_precision, final_recall, final_f1Scores, final_AUC ];

end
features_str = sprintf('accuracy\tprecision\trecall\tf1scores\tAUC');
display(features_str);
mean(analysis_matrix, 1)


% result(:, end+1) = labels;

% fid = fopen('result.csv', 'w');
% fprintf(fid, 'degree,pr,closeness,eigenvector,cc,betweennes,egoNeighEdge,egoNeighNode,egoEdge,egoNode,degree_w,label\n');
% fclose(fid);
% dlmwrite('result.csv', result, '-append', 'delimiter', ',');
% 
% result_indices = [indices_input_c'; indices_input_p'];

% figure('units','normalized','position',[.5 .5 .5 .5]);
% handle = tight_subplot(1, size(result, 2), [0.045 .04], [0.05 0.05], [0.05 0.05]);
% for i = 1:1:size(result, 2)
%     axes(handle(i));
%     hist(result(:,i));
%     xlim([0 S]);
% end
% figure;
% temp = load('times_cit.mat');
% times = temp.times;
% loglog(candidates, mean(times), '*-');
% hold on;
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