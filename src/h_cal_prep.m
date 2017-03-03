%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes the similarity vector between the 
% input vector and the marginal diestributions in the baseline
% graphs. SFK is the S by F by K tensor. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ G_t_BF ] = h_cal(BFK, G_t, theFile_test_name_str, extra, bin_strategy, B, noise)


K = size(BFK, 2);
F = size(BFK{1},2);
oriF = size(G_t{1},2);

hK = zeros(F, 1, K);


G = G_t{1};
G_t_BF = {};

for i = 1:oriF
%     i
    G_t_BF{i} = SF_normalize( G(:,i), bin_strategy, B);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% extra features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if extra == 1
    extraFeature_dir = '../extra_Features/';

    % CODA_in    
    coda_in = dlmread(strcat(extraFeature_dir, strrep(theFile_test_name_str(1,:), '.mat', ''), '/cmtyvv.in.out'));    
    % CODA_out    
    coda_out = dlmread(strcat(extraFeature_dir, strrep(theFile_test_name_str(1,:), '.mat', ''), '/cmtyvv.out.out'));    
    % motifs    
    motifs = dlmread(strcat(extraFeature_dir, strrep(theFile_test_name_str(1,:), '.mat', ''), '/motifs.out'));    
    % ncp plot    
    ncp = dlmread(strcat(extraFeature_dir, strrep(theFile_test_name_str(1,:), '.mat', ''), '/ncp.out'));   
    % singular value    
    sngVal = dlmread(strcat(extraFeature_dir, strrep(theFile_test_name_str(1,:), '.mat', ''), '/sngVal.out'));   
    % left singular value    
    sngVecL = dlmread(strcat(extraFeature_dir, strrep(theFile_test_name_str(1,:), '.mat', ''), '/sngVecL.out'));    
    % hop plot    
    hop_t = dlmread(strcat(extraFeature_dir, strrep(theFile_test_name_str(1,:), '.mat', ''), '/hop.out'));    
    hop = hop_t(2:end);

    G_t_BF{end+1} = coda_in;    
    G_t_BF{end+1} = coda_out;    
    G_t_BF{end+1} = motifs;    
    G_t_BF{end+1} = ncp;    
    G_t_BF{end+1} = sngVal;    
    G_t_BF{end+1} = sngVecL;    
    G_t_BF{end+1} = hop;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% add noise to extend the feature space, if necessary    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
if noise ~= 0     
    G_t_BF = scalability_1_addNoise(G_t_BF, noise);      
end

G_t_BF;


end



