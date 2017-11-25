%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis of the sensitivity, create experiment plot 3
% usage: 
% 1) load the processed data files before running this script;
% 2) hardcode the trainfile, testfile name 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc;
rng(17);

addpath(genpath('../lib'));
addpath(genpath('../src'));
addpath(genpath('../processed'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% scagnostics: obtained from Internet
% source: https://research.tableau.com/sites/default/files/Wilkinson_Infovis-05.pdf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

G_b_set = {};
G_t_set = {'G_t_cit-HepPh.mat', 'G_t_soc-Slashdot0902.mat'};

theFiles_train_names_str = {'cit-HepTh.mat'};
theFile_test_name_str = '';

temp1 = load('G_b_cit-HepTh.mat');
G_b = temp1.G_b;

G_b_set{1} = G_b;


theFiles_train_names_str = {'soc-Slashdot0811.mat', 'soc-Epinions.mat'};

temp1 = load('G_b_soc-Slashdot0811.mat');
G_b_temp1 = temp1.G_b;
temp2 = load('G_b_soc-Epinions.mat');
G_b = temp2.G_b;
G_b{2} = G_b_temp1{1};

G_b_set{2} = G_b;

theFiles_train_names_str = {'brain.mat', 'brain2.mat'};

temp1 = load('G_b_brain.mat');
G_b_temp1 = temp1.G_b;
temp2 = load('G_b_brain2.mat');
G_b = temp2.G_b;
G_b{2} = G_b_temp1{1};

G_b_set{3} = G_b;

F = 15;
Random_F1 = datasample(1:F, 5, 'Replace', false);
Random_F2 = datasample(1:F, 5, 'Replace', false);

s_set = [];
h_set = [];

for i = 1:1:3
    G_b = G_b_set{i};
    s_set_t = [];
    h_set_t = [];
    
    record = [];
    for j = 1:1:2
        load(G_t_set{j});

        % temp2 = load('G_b_soc-Slashdot0811.mat');
        % temp3 = load('G_b_brain.mat');
        % 
        % G_b{2} = temp1.G_b{1};
        % G_b{3} = temp2.G_b{1};

        % theFiles_train_names_str = 'soc-Slashdot0811.mat';
        % theFile_test_name_str = 'soc-Slashdot0902.mat';

        % obtain all features for SF and h 
        BFK = SF_cal_prep(G_b, theFiles_train_names_str, 0, 'scott', 0, 0);
        G_t_BF = h_cal_prep(BFK, G_t, theFile_test_name_str, 0, 'scott', 0, 0);

        % calculate SF and h
        [SF SFK] = SF_cal(BFK, 'temp'); %<<<---    
        display('SF done')

        [h hK] = h_cal(G_t_BF, BFK, 'DTW', 'sim');%   <<<---             
        display('h done')

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        BFK_COR = SF_cal_prep(G_b, theFiles_train_names_str, 0, 'fixed', 1000, 0);
        G_t_BF_COR = h_cal_prep(BFK_COR, G_t, theFile_test_name_str, 0, 'fixed', 1000, 0);
        
        % calculate SF and h
        [SF_COR SFK_COR] = SF_cal(BFK_COR, 'Spearman'); %<<<---    
        display('SF_MI done')

        [h_COR hK_COR] = h_cal(G_t_BF_COR, BFK_COR, 'Spearman', 'sim');%   <<<---             
        display('h_MI done')
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 6 scores start
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        F = size(SF, 1);

        score_SF = ones(F, F) - SF;

        % score 3
        if j == 1
            scagnostics = [20  3  4 21 20 21 20 18 18];         
        elseif j == 2
            scagnostics = [19  2  5 21 18 21 19 18 18];
        end
            
        scagnostics_F = unique(scagnostics);
        s_3 = (sum(sum(SF(scagnostics_F, scagnostics_F))) - length(scagnostics_F))/2;      
        h_3 = sum(h(scagnostics_F));

        % score 1
        lambda1 = 1/F; % F*F 
        lambda2 = 0.01; %   
        lambda3 = 1;

        [xLinInt fval iter] = MIQP_fixed (SF, h, lambda1, lambda2, lambda3, length(scagnostics_F))
        EAGLE_F = find(xLinInt==1)';
        s_1 = (sum(sum(SF(EAGLE_F, EAGLE_F))) - length(scagnostics_F))/2;
        h_1 = sum(h(EAGLE_F));
        
        s_5 = (sum(sum(SF_COR(EAGLE_F, EAGLE_F))) - length(scagnostics_F))/2;
        h_5 = sum(h_COR(EAGLE_F));

        % score 2
        if j == 1
            Random_F = Random_F1;
        elseif j == 2
            Random_F = Random_F2;
        end
                
        s_2 = (sum(sum(SF_COR(Random_F, Random_F))) - length(scagnostics_F))/2;
        h_2 = sum(h_COR(Random_F));

        % score 4
        [xLinInt fval iter] = MIQP_fixed (SF, h, 0, 0, lambda3, length(scagnostics_F))
        Surprising_F = find(xLinInt==1)';
        s_4 = (sum(sum(SF_COR(Surprising_F, Surprising_F))) - length(scagnostics_F))/2;
        h_4 = sum(h_COR(Surprising_F));
        
        record(:,end+1) = xLinInt;
        s_set_t(end+1, :) = [s_5 s_2 s_3 s_4];
        h_set_t(end+1, :) = [h_5 h_2 h_3 h_4];
    end
    s_set(end+1:end+2,:) = s_set_t;
    h_set(end+1:end+2,:) = h_set_t;
end

% figure('units','normalized','position',[.5 .5 .5 .4]);
% bar(s_set);
% labels = {'a', 'b', 'c', 'd'};
% set(gca, 'XTick', 1:4, 'XTickLabel', labels);
% grid;
% legend('EAGLE', 'Random', 'Scagnostics', 'Surprising');
% 
% 
% figure('units','normalized','position',[.5 .5 .5 .4]);
% bar(h_set);
% labels = {'a', 'b', 'c', 'd'};
% set(gca, 'XTick', 1:4, 'XTickLabel', labels);
% grid;
% legend('EAGLE', 'Random', 'Scagnostics', 'Surprising');

% s_set = 1/F .* s_set;
% s_set = F .* s_set;

% figure('units','normalized','position',[.5 .5 .5 .4]);

Y = [];
Y(:,:,1) = s_set;
Y(:,:,2) = h_set;
groupLabels = {'citation', 'social', 'citation', 'social', 'citation', 'social'};
b = plotBarStackGroups(Y, groupLabels);
b(1,1).FaceColor = '0.8431    0.0980    0.1098';
b(2,1).FaceColor = '0.9922    0.6824    0.3804';
b(3,1).FaceColor = '0.6706    0.8510    0.9137';
b(4,1).FaceColor = '0.1725    0.4824    0.7137';

b(1,2).FaceColor = '0.8431    0.0980    0.1098';
b(1,2).FaceAlpha = 0.5;
b(2,2).FaceColor = '0.9922    0.6824    0.3804';
b(2,2).FaceAlpha = 0.5;
b(3,2).FaceColor = '0.6706    0.8510    0.9137';
b(3,2).FaceAlpha = 0.5;
b(4,2).FaceColor = '0.1725    0.4824    0.7137';
b(4,2).FaceAlpha = 0.5;

set(gca, 'XTick', 1:6, 'XTickLabel', groupLabels);

xlabel('Input graph');

legend_str = {'EAGLE:PC', 'EAGLE:h', 'Random:PC', 'Random:h', 'Scagnostics:PC', 'Scagnostics:h', 'Surprising:PC', 'Surprising:h'};
legend_h = legend(legend_str, 'Orientation', 'horizontal');
PatchInLegend = findobj(legend_h, 'type', 'patch');
set(PatchInLegend, 'facea', 0.5)

ylim([0 16])
set(gca,'fontsize',25)
grid
% grid;
% 
% xlabel('# features');
% ylabel('runtime (s)');
% xlim([0 450])
% set(gca,'fontsize',16)