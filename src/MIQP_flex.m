%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes the optimum of the MIQP. Specifically
% it applies the cutting plane method.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xLinInt fval exitFlagInt] = MIQP_flex (SF, h, lambda1, lambda2, lambda3)

F = size(SF,1);
r = lambda3 .* h;
Q = lambda1 .* SF + lambda2 .* eye(F);

N = length(r);

xvars = 1:N;
zvar = N+1;
lb = zeros(N+1,1);
ub = ones(N+1,1);
ub(zvar) = Inf;

M = F;
m = 0;
A = zeros(1,N+1); % Allocate A matrix
A(xvars) = 1; % A*x represents the sum of the v(i)
A = [A;-A];
b = zeros(2,1); % Allocate b vector
b(1) = M;
b(2) = -m;

% fmin = 0.001;
% fmax = 0.05;

% Atemp = eye(N);
% Amax = horzcat(Atemp,-Atemp*fmax,zeros(N,1));
% A = [A;Amax];
% b = [b;zeros(N,1)];
% Amin = horzcat(-Atemp,Atemp*fmin,zeros(N,1));
% A = [A;Amin];
% b = [b;zeros(N,1)];

Aeq = zeros(1,N+1); % Allocate Aeq matrix
Aeq(xvars) = 0;% <<<---
beq = 0;% <<<---

% lambda = 100;

f = [r; 1];

options = optimoptions(@intlinprog,'Display','off'); % Suppress iterative display
[xLinInt,fval,exitFlagInt,output] = intlinprog(f,xvars,A,b,Aeq,beq,lb,ub,options);

thediff = 1e-6;
iter = 1; % iteration counter
assets = xLinInt(xvars); % the x variables
truequadratic = assets'*Q*assets;
zslack = xLinInt(zvar); % slack variable value

history = [truequadratic,zslack];
temp = [];
while abs((zslack - truequadratic)/max(1, truequadratic)) > thediff % relative error
    newArow = horzcat(2*assets'*Q,-1); % Linearized constraint
    A = [A;newArow];
    b = [b;truequadratic];
    
%     step = step * decay;
    
    % Solve the problem with the new constraints
    [xLinInt,fval,exitFlagInt,output] = intlinprog(f,xvars,A,b,Aeq,beq,lb,ub,options);
    assets = (assets+xLinInt(xvars))/(2); % Midway from the previous to the current
%     assets = xLinInt(xvars); % Use the previous line or this one
    truequadratic = assets'*Q*assets;
    zslack = xLinInt(zvar);
    history = [history;truequadratic,zslack];
    iter = iter + 1
%     truequadratic;
    if mod(iter, 150) == 1
        display(iter)
        break;
    end
    temp(:,end+1)=xLinInt;
end

% 
% % result_idx = find(temp(:,end) > 0.99);
% % addup = sum(temp, 2);
% % [B I] = sort(addup(result_idx), 'descend');
% % 
% % xLinInt(find(xLinInt > 0.99)) = I;

% figure('units','normalized','position',[.5 .5 .4 .5]); % 0.5, 0.4
% plot(1:size(history, 1), history(:,1), 'b-', 'linewidth', 2)
% hold on;
% grid;
% plot(1:size(history, 1), history(:,2), 'r-.', 'linewidth', 2)
% legend('Quadratic term','Slack term z')
% ylabel('Value')
% xlabel('Iteration number')
% xlim([0 150])
% set(gca,'fontsize',20)
end

