%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script computes the SF matrix
% The input is the collection of baseline graphs with per-node
% statistics.
% The output is the F by F matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ BFK ] = SF_cal_prep( G_b, theFiles_train_names_str, extra, bin_strategy, B, noise )

% scale value
E = 0;
if extra == 1
    E = 7;
end
K = size(G_b, 2);
[N F] = size(G_b{1});

BFK = {};
for i = 1:K
    curBF = {};
    
    curG = G_b{i};
    for j = 1:F
        curF = curG(:,j);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Normalized to x -> 1:1000; y -> 0:1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        countsF = SF_normalize(curF, bin_strategy, B);
        curBF{j} = countsF;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % extra features
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if extra == 1
        extraFeature_dir = '../extra_Features/';
        % CODA_in
        coda_in = dlmread(strcat(extraFeature_dir, strrep(theFiles_train_names_str{i}, '.mat', ''), '/cmtyvv.in.out'));
        % CODA_out
        coda_out = dlmread(strcat(extraFeature_dir, strrep(theFiles_train_names_str{i}, '.mat', ''), '/cmtyvv.out.out'));
        % motifs
        motifs = dlmread(strcat(extraFeature_dir, strrep(theFiles_train_names_str{i}, '.mat', ''), '/motifs.out'));
        % ncp plot
        ncp = dlmread(strcat(extraFeature_dir, strrep(theFiles_train_names_str{i}, '.mat', ''), '/ncp.out'));
        % singular value
        sngVal = dlmread(strcat(extraFeature_dir, strrep(theFiles_train_names_str{i}, '.mat', ''), '/sngVal.out'));
        % left singular value
        sngVecL = dlmread(strcat(extraFeature_dir, strrep(theFiles_train_names_str{i}, '.mat', ''), '/sngVecL.out'));
        % hop plot
        hop_t = dlmread(strcat(extraFeature_dir, strrep(theFiles_train_names_str{i}, '.mat', ''), '/hop.out'));
        hop = hop_t(2:end);

        curBF{end+1} = coda_in;
        curBF{end+1} = coda_out;
        curBF{end+1} = motifs;
        curBF{end+1} = ncp;
        curBF{end+1} = sngVal;
        curBF{end+1} = sngVecL;
        curBF{end+1} = hop;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % add noise to extend the feature space, if necessary
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if noise ~= 0
        curBF = scalability_1_addNoise(curBF, noise); 
        
    end
    
    BFK{i} = curBF;
    
end
    
    BFK;

end







