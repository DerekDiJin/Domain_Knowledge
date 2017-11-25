function [ G_o ] = reconstrcutG( G_b, K )
% recounstructG: this function is used to reconstruct the graph base. G_o
% is the base we want to select graphs from; K is the cell structure
% consisting indices.

G_o = {};

for i=1:1:length(K)
    G_o{i} = G_b{K{i}};
    
end



end

