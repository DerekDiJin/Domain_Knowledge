


function [ f ] = gradient_descent( SF, h, lambda1, lambda2, lambda3 )
%GRADIENT_DESCENT Summary of this function goes here
%   Detailed explanation goes here
epsilon = 10^(-6);
t = 1;
alpha = 0.99;
toContinue = 1;
F = size(SF, 1);
f_u = zeros(F, 1);  %new/updated value
f_l = ones(F, 1);   %last value

counter = 0;
while toContinue
    counter = counter + 1;
    der = lambda1 .* (SF + SF') * f_l + (2 * lambda2) .* f_l + lambda3 .* h;
    t = t * alpha;
    f_u = f_l - t * der;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Sanity check: for f values in F.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     f_u = gradient_descent_sanity(f_u);
    
    if (sqrt((f_u-f_l)' * (f_u-f_l)) < epsilon)
        toContinue = 0;
    end
    f_l = f_u;
    
end

display(counter);
f = f_u;
end

