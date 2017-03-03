%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis of the scalability, create experiment plot 2
% usage: 
% 1) load the processed data files before running this script;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng(17); clear; clc;
% theFiles_train_names_str = {'cit-HepTh.mat', 'soc-Slashdot0811.mat'};
% theFile_test_name_str = 'soc-Slashdot0902.mat';%'cit-HepPh.mat';%

temp = load('G_b_brain_control_w.mat');
G_b_temp = temp.G_b;
G_b = {};
for i=1:1:5
    G_b{i} = G_b_temp{i};
end
G_t = {};

temp = load('G_b_brain_patient_w.mat'); %<<<---
G_b_temp = temp.G_b;


% obtain all features for SF and h 
BFK = SF_cal_prep(G_b, '', 0, 'scott', 0, 0);
[SF SFK] = SF_cal(BFK); 
F = size(SF, 1);

candidates = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]; 
% candidates = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15];    %<<<---

result = [];

for i = 1:1:length(candidates)
    G_t{1} = G_b_temp{candidates(i)};
    display(strcat('Number of iteration: ', num2str(i)));
    
    G_t_BF = h_cal_prep(BFK, G_t, '', 0, 'scott', 0, 0);
%     [h hK] = h_cal(G_t_BF, BFK, 'dis');%   <<<--- 
    [h hK] = h_cal(G_t_BF, BFK, 'sim');
       
    lambda1 = 1 * 1/F; % F*F      
    lambda2 = 1; %          
%     lambda3 = -ceil((lambda1+lambda2)/max(h))-1;%2; % F
    lambda3 = 1;
     
%     [xLinInt fval iter] = MIQP_flex (SF, h, lambda1, lambda2, lambda3); 
%     lambda3 = 1;   
    [xLinInt fval iter] = MIQP_fixed (SF, h, lambda1, lambda2, lambda3, 3); 
    
    result(end+1, :) = xLinInt;
    
end




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