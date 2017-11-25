%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes the L2, or Euclidean distance between
% two vectors. vec1 and vec2 are N by 1 vectors.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function s = sim_L2(vec1, vec2)

v_d = vec1 - vec2;
d = sqrt(v_d' * v_d);
s = 1/(1+d);

end