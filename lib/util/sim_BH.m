%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes the KL distance between
% two vectors. vec1 and vec2 are N by 1 vectors.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function s = sim_BH(vec1, vec2)

d_temp = sqrt(vec1 .* vec2);

d = log(sum(d_temp, 1)) * (-1);

s = 1/(1+d);

end