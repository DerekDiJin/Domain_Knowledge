%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script computes the SF matrix
% The input is the collection of baseline graphs with per-node
% statistics.
% The output is the F by F matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ SF SFK BFK_p F_p ] = SF_cal_Approx( BFK )

K = size(BFK,2);
F = size(BFK{1},2);

SFK = zeros(F, F, K);
F_p = [];

for i = 1:1:K

    curSF = zeros(F,F);
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
        curSF(x, y) = Y(end);
        curSF(y, x) = curSF(x, y);
        
    end
    curSF(logical(eye(size(curSF)))) = 1;
    SFK(:,:,i) = curSF;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Shrink the size of feature space
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    Z = linkage(Y,'average');
%     I = inconsistent(Z);
    T = cluster(Z,'maxclust',F*0.6);
%     T = cluster(Z,'cutoff',0.8);    %<<<----
    [C ic ia] = unique(T);
    
    F_p(end+1:end+length(ic), 1) = ic;
    

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% From SFK tensor (F by F by K) to SF_p (F_p by F_p by K)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[count value] = hist(F_p, unique(F_p));
idx = find(count == K);
F_p = value(idx)';

SFK = SFK(idx, idx, :);

BFK_p = {};
for i = 1:1:size(BFK,2)
    
    curBF = BFK{i}
    newBF = {};
    for j = 1:1:length(F_p)
        newBF{j} = curBF{F_p(j)}
    end
    BFK_p{i} = newBF;
    
end

SF = SF_compress(SFK);    
SFK;

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




