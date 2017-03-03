clear; clc;

addpath(genpath('../lib'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graph type: directed weighted, small
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tic
% display('In prepareSmall()');
% [G_b G_t] = prepareSmall();
% toc
% display('------');

extra = 1;
theFiles_train_names_str = {'soc-Epinions1.mat'};
% theFile_test_name_str = 'cit-HepPh.mat';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graph type: directed unweighted, big
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic    % <<<---
display('In prepareBig()');    % <<<---
[G_b theFiles_train_names_str G_t theFile_test_name_str] = prepareBig(extra);    % <<<---
% save('G_b_syn_2.mat', 'G_b');
% save('G_t_syn_2.mat', 'G_t');
toc
display('------');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synthetic dataset porto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% N_train = 10;
% G_b = extractSyntheticFiles(N_train);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis of the similarity between different SFs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% B_all = {19, 49, 99, 149, 'fd', 'auto', 'scott', 'sturges', 'sqrt'};
% SF_analysis = [];
% 
% for i = 1:length(B_all)
%     B = B_all{i};
%     if isnumeric(B)
%         [ SF SFK BFK] = SF_cal(G_b, 'fixed', B);
%     else
%         [ SF SFK BFK] = SF_cal(G_b, B, 0);
%     end
%     SF_analysis(:,:,i) = SF;
%     
% end
% 
% 
% d_all = zeros(1, size(SF_analysis, 3));
% for i = 1:size(SF_analysis, 3)
%     d_all(i) = norm( (SF_analysis(:,:,1)-SF_analysis(:,:,i)), 'fro' );
% end
% d_all
% 
% figure
% labels = {'19', '49', '99', '149', 'fd', 'auto', 'scott', 'sturges', 'sqrt'}
% plot(1:length(d_all), d_all, '*-');
% text(1:length(d_all),(d_all*0.95),labels);

% save('SFK_4.mat', 'SFK');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calaulate the SF and SFK matrix
% 'theFiles_train_names_str': cit-HepPh.mat, cit-HepTh.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
display('In SF_cal()');
BFK = SF_cal_prep(G_b, theFiles_train_names_str, 1, 'scott', 0, 0);

[SF SFK] = SF_cal(BFK); 
toc
display('------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% G_t, the new input graph is denoted as an n by F matrix. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
tic
display('In h_cal()');
G_t_BF = h_cal_prep(BFK, G_t, theFile_test_name_str, 1, 'scott', 0, 0);

[h hK] = h_cal(G_t_BF, BFK, 'dis');
toc
display('------');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Objective function setup 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
F = size(SF, 1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MIQP fixed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
lambda1 = 1 * 1/F; % F*F
lambda2 = 1; % F
lambda3 = 1;%2; % F
% [h hK] = h_cal(BFK, G_t, 'fd', 0, 'sim');

tic
display('In MIQP_fixed');
[xLinInt fval iter] = MIQP_fixed (SF, h, lambda1, lambda2, lambda3, 5)
toc
display('------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Group experiments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
result_fixed = [];
result_fixed = [result_fixed; xLinInt'];
[xLinInt fval iter] = MIQP_fixed (SF, h, lambda1, lambda2, lambda3, 2);
result_fixed = [result_fixed; xLinInt'];
[xLinInt fval iter] = MIQP_fixed (SF, h, lambda1, lambda2, lambda3, 3);
result_fixed = [result_fixed; xLinInt'];
[xLinInt fval iter] = MIQP_fixed (SF, h, lambda1, lambda2, lambda3, 4);
result_fixed = [result_fixed; xLinInt'];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MIQP flex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lambda1 = 1 * 1/(F); % F*F
lambda2 = 1; % F
lambda3 = -1; % -2*F

tic
display('In MIQP_flex');
    [xLinInt fval iter] = MIQP_flex (SF, h, lambda1, lambda2, lambda3)
toc
display('------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MIQP flex lower and upper bounds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
combos_all = {};

for i = 1:1:F
    v = 1:1:F;
    C = nchoosek(v,i);
    combos_all{i} = C;
end

terms_1 = [];
terms_2 = [];
terms_3 = [];
% terms_4 = [];
for i = 1:1:F
    combos_cur = combos_all{1,i};
    [m n] = size(combos_cur);
    for j = 1:1:m
        combo_cur = combos_cur(j,:);
        cur = zeros(1,F);
        cur(combo_cur) = 1;
        term1 = (1/F) * cur * SF * cur';
        term2 = cur * cur';
        term3 = cur * h;
%         cur_h = h(find(cur==1));
        terms_1(end+1) = term1;
        terms_2(end+1) = term2;
        terms_3(end+1) = term3;
%         terms_4(end+1) = sum(cur_h);
    end
    
end
display( strcat('Suggested Lambda3 Lower bound: ', num2str((lambda1+lambda2)/max(h))) );
display( strcat('Suggested Lambda3 Upper bound: ', num2str(max(max(terms_1./terms_3), max(terms_2./terms_3)))) );
% plot(1:1:length(terms_1), (terms_1+terms_2)./terms_3, '*-');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Group experiments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% result_flex = [];
% curResult = [];
% 
% for lambda3 = -3:-0.5:-10.5 % 0:0.1:10
%     display(lambda3)
%     [xLinInt fval iter] = MIQP_flex (SF, h, lambda1, lambda2, lambda3);
%     curResult(1) = lambda3;
%     curResult(2:F+1) = xLinInt(1:F)';
%     curResult(F+2) = fval;
%     result_flex = [result_flex; curResult];
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GD to LP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% tic
% display('In gradient_descent()');
% f1 = gradient_descent(SF, h, lambda1, lambda2, lambda3)
% toc
% display('------');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Closed form solution to LP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% tic
% display('In closed form solution');
% F = size(SF, 1);
% f2 = inv(lambda1.*(SF + SF') + (2 * lambda2) .* eye(F))*(-lambda3 .* h)
% toc
% display('------');

