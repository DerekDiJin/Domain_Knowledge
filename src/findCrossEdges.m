function [ crossEdges_index_size, crossEdges_outNode_size ] = findCrossEdges( egoNodes, outNodes, src, dst, mod )
%FINDLOCAL Summary of this function goes here
%   Detailed explanation goes here

if strcmp(mod, 'to') == 1
    src_in = ismember(src, egoNodes);            
    dst_out = ismember(dst, outNodes);  
    crossEdges_index_size = length(find(src_in + dst_out == 2));
    neighbors = dst_out .* dst;
    crossEdges_outNode_size = length(unique(neighbors(find(neighbors~=0))));
elseif strcmp(mod, 'from') == 1
    src_out = ismember(src, outNodes);
    dst_in = ismember(dst, egoNodes);
    crossEdges_index_size = length(find(src_out + dst_in == 2));
    neighbors = src_out .* src;
    crossEdges_outNode_size = length(unique(neighbors(find(neighbors~=0))));
else
    display('mod does not exist.');
    exit;
end

end

