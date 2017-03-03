function [ G_b G_t ] = prepareSmall()
% This function returns the small matrices to be used.


dataFolder_train = '../DATA/train/';
dataFolder_test = '../DATA/test/';

if ~isdir(dataFolder_train)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', dataFolder_train);
  uiwait(warndlg(errorMessage));
  return;
end

if ~isdir(dataFolder_test)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', dataFolder_test);
  uiwait(warndlg(errorMessage));
  return;
end

% Get a list of all files in the folder with the desired file name pattern.
filePattern_train = fullfile(dataFolder_train, '*.mat');
theFiles_train = dir(filePattern_train);
filePattern_test = fullfile(dataFolder_test, '*.mat');
theFiles_test = dir(filePattern_test);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Obtain a array of baseline graphs, denoted as an n by F by K tensor.
% Each graph in the array is a struct.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
G_b = prepareSmall_extractFiles(theFiles_train, dataFolder_train);
G_t = prepareSmall_extractFiles(theFiles_test, dataFolder_test);

end

