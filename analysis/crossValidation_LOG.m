function [ accuracy ] = crossValidation( Xs, Ys, CV_K )
%CROSSVALIDATION Summary of this function goes here
%   Detailed explanation goes here

input_size = size(Xs, 1);

total = 0;
corrects = 0;

Indices = crossvalind('Kfold', input_size, CV_K);

for i = 1:1:CV_K
    not_idx = find(Indices == i);
    train_X_idx = setdiff(1:1:input_size, not_idx);
    train_X = Xs(train_X_idx, :);
    train_Y = Ys(train_X_idx,:);
    
    test_X = Xs(not_idx,:);
    test_Y = Ys(not_idx,:);

%     SVMModel = fitcsvm(train_X,train_Y, 'Standardize',true,'KernelFunction','RBF', 'KernelScale','auto');
%     [label, score] = predict(SVMModel, test_X);
% 
%     corrects = corrects + sum(label == test_Y);
%     total = total + length(not_idx);

%     [B,dev,stats] = mnrfit(train_X, train_Y);
%     pihat = mnrval(B, test_X, stats);
    [b,dev,stats] = glmfit(train_X, [ones(size(train_Y)) train_Y],'binomial', 'link', 'logit');
    yfit = glmval(b, test_X, 'logit');
    
    corrects = corrects + sum(abs(yfit - test_Y)<0.1);
    total = total + length(not_idx);
    
%     confusion_matrix = zeros(2,2);
%     confusion_matrix(1,1) = length(find(test_Y == 1 & prediction == 1));
%     confusion_matrix(1,2) = length(find(test_Y == 1 & prediction == 2));
%     confusion_matrix(2,1) = length(find(test_Y == 2 & prediction == 1));
%     confusion_matrix(2,2) = length(find(test_Y == 2 & prediction == 2));
%     
%     precision = @(confusion_matrix) diag(confusion_matrix)./sum(confusion_matrix,2);
%     precision(confusion_matrix)
%     
%     recall = @(confusion_matrix) diag(confusion_matrix)./sum(confusion_matrix,1)';
%     recall(confusion_matrix)
%     
%     f1Scores = @(confusion_matrix) 2*(precision(confusion_matrix).*recall(confusion_matrix))./(precision(confusion_matrix)+recall(confusion_matrix));
%     f1Scores(confusion_matrix)
%     
%     meanF1 = @(confusion_matrix) mean(f1Scores(confusion_matrix));
%     meanF1(confusion_matrix)
% 
%     
%     mdl = fitglm(train_X,train_Y-1,'Distribution','binomial','Link','logit');

end

accuracy = corrects/total;



end

