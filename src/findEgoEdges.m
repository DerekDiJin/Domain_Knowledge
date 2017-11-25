function [ edges_index_size ] = findEgoEdges( egoNodes, src, dst )
%FINDLOCAL Summary of this function goes here
%   Detailed explanation goes here

    src_in = ismember(src, egoNodes);            
    dst_in = ismember(dst, egoNodes);  
    edges_index_size = length(find(src_in + dst_in == 2));
    

end

