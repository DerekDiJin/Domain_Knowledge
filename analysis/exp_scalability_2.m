%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis of the scalability, create experiment plot 1
% usage: 
% 1) load the processed data files before running this script;
% 2) hardcode the trainfile, testfile name 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng(17);

addpath(genpath('../lib'));
addpath(genpath('../src'));
addpath(genpath('../records'));

mod = 0;    % 1 for approx, 0 for normal

SynDataFolder = '../DATA/syn/';

G_b_files = {'G_b_10000.mat', 'G_b_20000.mat', 'G_b_40000.mat', 'G_b_80000.mat', 'G_b_160000.mat'};
G_t_files = {'G_t_10000.mat', 'G_t_20000.mat', 'G_t_40000.mat', 'G_t_80000.mat', 'G_t_160000.mat'};

candidates = [10000, 20000, 40000, 80000, 160000];
times = [];
T = 1%5;

result = [];
result_appro = {};
for i = 1:1:length(G_b_files)    
    
    fileStr_G_b = strcat(SynDataFolder, G_b_files(i));
    G_b = struct2cell(load(fileStr_G_b{1}));
    fileStr_G_t = strcat(SynDataFolder, G_t_files(i));
    G_t = struct2cell(load(fileStr_G_t{1}));
    
    BFK = SF_cal_prep(G_b{1}, '', 0, 'scott', 0, 14);
    G_t_BF = h_cal_prep(BFK, G_t, '', 0, 'scott', 0, 14);
                      
    newBFK = {};
    curF = 20;
    for j = 1:1:size(BFK,2)
            
        curBFK = BFK{j};            
        temp = {};
            
        for k = 1:1:curF
            temp{end+1} = curBFK{k};                        
        end        
        newBFK{end+1} = temp;        
    end
    
    BFK = newBFK;   
    
    time_T = [];
    for j = 1:1:T
        if mod == 0
            tic
            [SF SFK] = SF_cal(BFK, 'DTW');         
            display('SF done')

            [h hK] = h_cal(G_t_BF(1:curF), BFK, 'DTW', 'dis');       
            display('h done')

            lambda1 = 1 * 1/curF; % F*F 
            lambda2 = 1; %   
            lambda3 = -ceil((lambda1+lambda2)/max(h))-1;%2; % F

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
            % Run MIQP_flex        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

            display('In MIQP_flex');      
            [xLinInt fval iter] = MIQP_flex (SF(1:curF, 1:curF), h(1:curF), lambda1, lambda2, lambda3);      
            timer_end = toc     
            display('------');
            result(end+1,:) = xLinInt(1:end-1);
            
        elseif mod == 1
            tic
       
            [SF SFK BFK_p F_p] = SF_cal_Approx(BFK);         
            display('SF done')

            [h hK] = h_cal(G_t_BF(F_p), BFK_p, 'dis');       
            display('h done')


            lambda1 = 1 * 1/curF; % F*F 
            lambda2 = 1; %   
            lambda3 = -ceil((lambda1+lambda2)/max(h))-1;%2; % F

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
            % Run MIQP_flex        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

            display('In MIQP_flex');      
            [xLinInt fval iter] = MIQP_flex (SF, h, lambda1, lambda2, lambda3);      
            timer_end = toc     
            display('------');           
            result_appro{end+1} = xLinInt(1:end-1);
        end

        time_T(end+1) = timer_end;
    end
    times(end+1,:) = time_T;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The above analysis is time-consuming: below plots the recorded results
% Run the below code to get the result in the paper.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('units','normalized','position',[.5 .5 .4 .5]);
% temp = load('times_scalability2_approx.mat');
% times = temp.times;
% s = std(times);
% e_nor = errorbar(candidates, mean(times), s, 'linewidth', 4);
temp = load('../records/times_scalability2_normal.mat');
times = temp.times;
s = std(times);
e_app = errorbar(candidates, mean(times), s, 'linewidth', 4);
e_nor.LineStyle ='-.';
legend('EAGLE');
xlim([0, max(candidates)*1.1]);
ylim([0, 35]);
xlabel('# nodes');
ylabel('runtime (s)');
set(gca,'fontsize',20)
grid on;


