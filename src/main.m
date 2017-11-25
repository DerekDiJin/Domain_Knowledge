clear; clc;

addpath(genpath('../lib'));
addpath(genpath('../processed'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% Set processed to 0 to run the whole preprocess procedure.
% Warning: could be slow due to some structure-specific distributions, e.g., egonet size, egonet neighbors, etc.
% We stored some processed results under the "/processed/" directory.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
processed = 1;

if processed == 0
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Graph type: directed weighted, small
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % tic
    % display('In prepareSmall()');
    % [G_b G_t] = prepareSmall();
    % toc
    % display('------');

    extra = 1;
    % theFiles_train_names_str = {'brain2.mat'};
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

else
    temp = load('G_b_Cit.mat');
    G_b = temp.G_b_Cit;
    temp = load('G_t_cit-HepPh.mat');
    G_t = temp.G_t;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calaulate the SF and SFK matrix
% 'theFiles_train_names_str': cit-HepPh.mat, cit-HepTh.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
display('In SF_cal()');
BFK = SF_cal_prep(G_b, '', 0, 'scott', 0, 0);

[SF SFK] = SF_cal(BFK, 'DTW'); 
toc
display('------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% G_t, the new input graph is denoted as an n by F matrix. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
tic
display('In h_cal()');
G_t_BF = h_cal_prep(BFK, G_t, '', 0, 'scott', 0, 0);

[h hK] = h_cal(G_t_BF, BFK, 'DTW', 'dis');
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

tic
display('In MIQP_fixed');
[xLinInt fval iter] = MIQP_fixed (SF, h, lambda1, lambda2, lambda3, 3)
toc
display('------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Group experiments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% result_fixed = [];
% result_fixed = [result_fixed; xLinInt'];
% [xLinInt fval iter] = MIQP_fixed (SF, h, lambda1, lambda2, lambda3, 2);
% result_fixed = [result_fixed; xLinInt'];
% [xLinInt fval iter] = MIQP_fixed (SF, h, lambda1, lambda2, lambda3, 3);
% result_fixed = [result_fixed; xLinInt'];
% [xLinInt fval iter] = MIQP_fixed (SF, h, lambda1, lambda2, lambda3, 4);
% result_fixed = [result_fixed; xLinInt'];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MIQP flex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lambda1 = 1 * 1/(F); % F*F
lambda2 = 1; % F
lambda3 = -2; % -2*F

tic
display('In MIQP_flex');
    [xLinInt fval iter] = MIQP_flex (SF, h, lambda1, lambda2, lambda3)
toc
display('------');


