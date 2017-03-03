%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes the similarity vector between the 
% input vector and the marginal diestributions in the baseline
% graphs. SFK is the S by F by K tensor. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ h hK ] = h_cal(G_t_BF, BFK, mod)

K = size(BFK,2);
F = size(G_t_BF,2);
hK = zeros(F, 1, K);
h = zeros(F,1);

for i=1:K
    
    curG = BFK{i};
    curh = zeros(F, 1);
    for j = 1:F
        if strcmp(mod, 'sim')
            curh(j, 1) = 1/( 1+dtw(G_t_BF{j},curG{j}) );  % <<<--- 1/( 1+dtw(G_t_BF{j},curG{j}) )
        elseif strcmp(mod, 'dis')
            curh(j, 1) = dtw(G_t_BF{j},curG{j});
        end
        %sim_BH(G_t_SF(:,j), curG(:,j));
    end
    hK(:,:,i) = curh;
    
end

h = h_compress(hK);




end



