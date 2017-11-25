%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes the normalized pdf of input vector
% The input is the feature vector representing the value of 
% each node (N by 1), the output is the normalized (to [0,1]) 
% counts.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ counts ] = SF_normalize( curF, bin_strategy, B )

if strcmp(bin_strategy, 'fixed')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normalize with fixed number of bins
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    N = hist(curF,min(curF):(max(curF)-min(curF))/(B-1):max(curF));
    counts = N' ./ sum(N);

elseif strcmp(bin_strategy, 'fd')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normalize with unfixed number of bins: fd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [N edges bin] = histcounts(curF, 'BinMethod', 'fd');
    counts = N' ./ sum(N);
%     counts = log10((N'+1)./sum(N));

elseif strcmp(bin_strategy, 'auto')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normalize with unfixed number of bins: auto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [N edges bin] = histcounts(curF, 'BinMethod', 'auto');
    counts = N' ./ sum(N);
    
elseif strcmp(bin_strategy, 'scott')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normalize with unfixed number of bins: auto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [N edges bin] = histcounts(curF, 'BinMethod', 'scott');
    counts = N' ./ sum(N);
    
elseif strcmp(bin_strategy, 'sturges')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normalize with unfixed number of bins: auto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [N edges bin] = histcounts(curF, 'BinMethod', 'sturges');
    counts = N' ./ sum(N);
    
elseif strcmp(bin_strategy, 'sqrt')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normalize with unfixed number of bins: auto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [N edges bin] = histcounts(curF, 'BinMethod', 'sqrt');
    counts = N' ./ sum(N);

else
    return;
    
end 
 
end

