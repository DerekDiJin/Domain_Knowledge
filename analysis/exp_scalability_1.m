%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis of the scalability, create experiment plot 2
% usage: 
% 1) load the processed data files before running this script;
% 2) hardcode the trainfile, testfile name 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng(17);
theFiles_train_names_str = {'cit-HepTh.mat', 'soc-Slashdot0811.mat'};
theFile_test_name_str = 'soc-Slashdot0922.mat';%'cit-HepPh.mat';%
mod = 0; % mod == 0: normal; mod == 1: approx

temp = load('G_b_cit-HepTh.mat');
G_b_temp = temp.G_b;
temp = load('G_b_soc-Slashdot0811.mat');
G_b = temp.G_b;
G_b{2} = G_b_temp{1};
temp = load('G_t_soc-Slashdot0922.mat');
G_t = temp.G_t;
% theFiles_train_names_str = 'soc-Slashdot0811.mat';
% theFile_test_name_str = 'soc-Slashdot0902.mat';


% obtain all features for SF and h 
BFK = SF_cal_prep(G_b, theFiles_train_names_str, 1, 'scott', 0, 14);
G_t_BF = h_cal_prep(BFK, G_t, theFile_test_name_str, 1, 'scott', 0, 14);

candidates = [50, 100, 150, 200, 250, 300, 350, 400];
% candidates = [250];
times = [];
times_1 = [];
times_2 = [];

BFK_set = {};
for i = 1:1:length(candidates)
    newBFK = {};
    for j = 1:1:size(BFK,2)
        
        curBFK = BFK{j};
        temp = {};
        for k = 1:1:candidates(i)
            
            temp{end+1} = curBFK{k};            
        end
        
        newBFK{end+1} = temp;        
    end
    BFK_set{end+1} = newBFK;
end

if mod == 1
    [F_p_set BF_pK_set] = SF_cal_Approx_prep(BFK_set);
end

T = 1;
for j = 1:1:T
    time_T = [];
    time_T1 = [];
    time_T2 = [];
    display(strcat('Number of iteration: ', num2str(j)));
    for i =1:1:length(candidates)
        display(strcat('Candidate: ', num2str(i)));
        % calculate SF and h
        
        if mod == 0 % normal
            BFK = BFK_set{i};
            
            tic
            [SF SFK] = SF_cal(BFK, 'DTW'); %<<<---
            display('SF done')
            timer_1 = toc

            [h hK] = h_cal(G_t_BF(1:candidates(i)), BFK, 'DTW', 'dis');%   <<<---      
            display('h done')
            timer_2 = toc
        
        elseif mod == 1 % approx
            BFK = BF_pK_set{i};
            F_p = F_p_set{i};
            
            tic
            [SF SFK] = SF_cal(BFK, 'DTW');
            display('SF done')
            timer_1 = toc
            
            [h hK] = h_cal(G_t_BF(F_p), BFK, 'DTW', 'dis');
            display('h done')
            timer_2 = toc
            
        end
        
        F = size(SF, 1);

        lambda1 = 1 * 1/F; % F*F 
        lambda2 = 1; %   
        lambda3 = -ceil((lambda1+lambda2)/max(h))-1;%2; % F      

%         curF = candidates(i);        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        % Run MIQP_flex        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        display('In MIQP_flex');        
        [xLinInt fval iter] = MIQP_flex (SF, h, lambda1, lambda2, lambda3);    
        timer_end = toc    
        display('------');
        
        time_T1(end+1) = timer_1;
        time_T2(end+1) = timer_2 - timer_1;
        time_T(end+1) = timer_end;

    end
    times_1(end+1,:) = time_T1;
    times_2(end+1,:) = time_T2;
    times(end+1,:) = time_T;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The above analysis is time-consuming: below plots the recorded results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
temp = load('../src/processed/times_cit.mat');
times = temp.times;
loglog(candidates, mean(times), '*-', 'linewidth', 4);
hold on;
temp = load('../src/processed/times_soc-Slashdot.mat');
times = temp.times;
loglog(candidates, mean(times), '*-', 'linewidth', 4);
hold off;
grid;
legend('citation graphs', 'social graphs');
xlabel('# features');
ylabel('runtime (s)');

figure('units','normalized','position',[.5 .5 .4 .5]);
temp = load('times_cit.mat');
times = temp.times;
loglog(candidates, mean(times), 'b*-', 'linewidth', 4);
hold on;
temp = load('../src/processed/times1_cit.mat');
times_1 = temp.times_1;
temp = load('../src/processed/times2_cit.mat');
times_2 = temp.times_2;
loglog(candidates, mean(times-(times_1+times_2)), 'c*-', 'linewidth', 4);

temp = load('../src/processed/times_soc.mat');
times = temp.times;
loglog(candidates, mean(times), 'r*-.', 'linewidth', 4);

temp = load('../src/processed/times1_soc.mat');
times_1 = temp.times_1;
temp = load('../src/processed/times2_soc.mat');
times_2 = temp.times_2;
loglog(candidates, mean(times-(times_1+times_2)), 'm*-.', 'linewidth', 4);

grid;
legend('citation: total', 'citation: MIQP', 'social: total', 'social: MIQP');

xlabel('# features');
ylabel('runtime (s)');
xlim([0 450])
set(gca,'fontsize',20)