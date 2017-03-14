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

extra = 0;
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


grids = {'000' '001' '002' '003' '004' '005' '006' '007' '008' '009' '010' '011' '012' '013' '014' '015' '016' '017' '018' '019'... 
    '020' '021' '022' '023' '024' '025' '026' '027' '028' '029' '030' '031' '032' '033' '034' '035' '036' '037' '038' '039'...
	'040' '041' '042' '043' '044' '045' '046' '047' '048' '049' '050' '051' '052' '053' '054' '055' '056' '057' '058' '059'...
	'060' '061' '062' '063' '064' '065' '066' '067' '068' '069' '070' '071' '072' '073' '074' '075' '076' '077' '078' '079'...
	'080' '081' '082' '083' '084' '085' '086' '087' '088' '089' '090' '091' '092' '093' '094' '095' '096' '097' '098' '099'...
	'100' '101' '102' '103' '104' '105' '106' '107' '108' '109' '110' '111' '112' '113' '114' '115' '116' '117' '118' '119'...
	'120' '121' '122' '123' '124' '125' '126' '127' '128' '129' '130' '131' '132' '133' '134' '135' '136' '137' '138' '139'...
	'140' '141' '142' '143' '144' '145' '146' '147'};


for i = 1:1:length(grids)
    
    data_path = strcat('../DATA/real_train/neural_', grids(i), '_w.mat');
    temp = load( data_path{1} );
    temp_full = full(temp.H);
    [m n] = size(temp_full);
    maxSize = max(m, n);
    curFeatures = G_b{i};
    lastFeature = sum(temp_full, 2);
    lastFeature(end+1:maxSize,:) = 0;
    curFeatures(:,end+1) = lastFeature;
    G_b{i} = curFeatures;
end



Patients = {'000' '001' '002' '003' '004' '005' '006' '007' '008' '009' '010' '011' '012' '015' '016'... 
    '021' '022' '025' '028' '029' '032' '034' '037' '039'...
	'040' '041' '042' '044' '046' '047' '049' '059'...
	'060' '064' '071' '072' '073' '075' '077' '078' '079'...
	'080' '081' '082' '084' '085' '088' '089' '092' '094' '096' '097' '098' '099'...
	'100' '101' '103' '105' '106' '108' '109' '110' '112' '117' ...
	'122' '126' '132' '133' '137' ...
	'142' '143' '145' };



G_t_Patient = {};
G_b_Control = {};

for i = 1:1:length(grids)
    
    if ismember(grids{i}, Patients)      
        G_t_Patient{end+1} = G_b{i};
    else
        G_b_Control{end+1} = G_b{i};
    end
    
end

result = [];
for i=1:1:length(G_t_Patient)
    
    G_t = {};
    G_t{1} = G_t_Patient{i};
    G_t_BF = h_cal_prep(BFK, G_t, '', 0, 'scott', 0, 0);
    [h hK] = h_cal(G_t_BF, BFK, 'dis');
    [xLinInt fval iter] = MIQP_flex (SF, h, lambda1, lambda2, lambda3);
    result(end+1,:) = xLinInt;
end





