%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script computes the SF matrix
% The input is the collection of baseline graphs with per-node
% statistics.
% The output is the F by F matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ F_p_set BF_pK_set ] = SF_cal_Approx_prep( BFK_set )

CAN = size(BFK_set,2);
K = size(BFK_set{1},2);

BF_pK_set = {};
F_p_set = {};

for j = 1:1:CAN
    F = size(BFK_set{j}{1},2);
    BFK = BFK_set{j};
    
    F_p = [];
    for i = 1:1:K

        curBF = BFK{i};

        Y = [];

        v = 1:1:F;    
        C = nchoosek(v,2);    
        [C_n, C_m] = size(C);    

        for k = 1:C_n
            x = C(k,1);        
            y = C(k,2);        
        %         curSF(x, y) = sim_BH(curNF(:,x), curNF(:,y));
            Y(end+1) = 1/( 1+dtw(curBF{x},curBF{y}) );


        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Shrink the size of feature space
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
        Z = linkage(Y,'average');
    %     I = inconsistent(Z);
        T = cluster(Z,'maxclust',F*0.4);
    %     T = cluster(Z,'cutoff',0.8);    %<<<----
        [C ic ia] = unique(T);

        F_p(end+1:end+length(ic), 1) = ic;

    end
    
    [count value] = hist(F_p, unique(F_p));
    idx = find(count == K);
    F_p = value(idx)';
    
    BF_pK = {};
    for i = 1:1:K
        curBF_p = {};
        curBF = BFK{i};
        for k = 1:1:length(F_p)
            curBF_p{k} = curBF{F_p(k)};
        end
        BF_pK{i} = curBF_p;
    end
    
    BF_pK_set{j} = BF_pK;
    F_p_set{j} = F_p;

    
end






end







% v = 1:1:F_p;    
%     C = nchoosek(v,2);    
%     [C_n, C_m] = size(C);    
%     
%     for k = 1:C_n
%         x = C(k,1);        
%         y = C(k,2);        
%     %         curSF(x, y) = sim_BH(curNF(:,x), curNF(:,y));
%         curSF(x, y) = 1/( 1+dtw(newBF{x},newBF{y}) );
%         curSF(y, x) = curSF(x, y);
%     end




