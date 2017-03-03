%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script computes the SF matrix
% The input is the collection of baseline graphs with per-node
% statistics.
% The output is the F by F matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ SF SFK ] = SF_cal( BFK )

K = size(BFK,2);
F = size(BFK{1},2);

SFK = zeros(F, F, K);

for i = 1:1:K

    curBF = BFK{i};
    curSF = zeros(F,F);  

    v = 1:1:F;    
    C = nchoosek(v,2);    
    [C_n, C_m] = size(C);    
    
    for k = 1:C_n
        x = C(k,1);        
        y = C(k,2);        
    %         curSF(x, y) = sim_BH(curNF(:,x), curNF(:,y));        
        curSF(x, y) = 1/( 1+dtw(curBF{x},curBF{y}) );
        curSF(y, x) = curSF(x, y);
    end
    
    curSF(logical(eye(size(curSF)))) = 1;
    SFK(:,:,i) = curSF;
    
end

SF = SF_compress(SFK);    
SFK;

end







