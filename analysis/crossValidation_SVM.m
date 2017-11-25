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
    
    SVMModel = fitcsvm(train_X,train_Y, 'Standardize',true,'KernelFunction','RBF');
    ScoreSVMModel = fitSVMPosterior(SVMModel);
    [label, score] = predict(ScoreSVMModel, test_X);
    
    cutoff = sum(train_Y==0)/length(train_Y);
    label = score(:,1) < cutoff;
%     SVMModel = fitcsvm(train_X,train_Y, 'Standardize',true,'KernelFunction','RBF', 'KernelScale', 'auto');
%     [label, score] = predict(SVMModel, test_X);

    corrects = corrects + sum(label == test_Y);
    total = total + length(not_idx);

%     [B,dev,stats] = mnrfit(train_X, train_Y);
%     pihat = mnrval(B, test_X, stats);
%     
%     prediction = (pihat(:,1) < pihat(:,2)) + 1;
%     corrects = corrects + sum(prediction == test_Y);
%     total = total + length(not_idx);

end

accuracy = corrects/total;



end

