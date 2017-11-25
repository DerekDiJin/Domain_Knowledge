function [ final_accuracy, final_precision, final_recall, final_f1Scores, final_AUC ] = crossValidation( Xs, Ys, CV_K )
%CROSSVALIDATION Summary of this function goes here
%   Detailed explanation goes here

input_size = size(Xs, 1);

e = 10e-6;
final_accuracy = 0;
final_precision = 0;
final_recall = 0;
final_f1Scores = 0;
final_meanF1 = 0;
final_ACU = 0;

Indices = crossvalind('Kfold', input_size, CV_K);

for i = 1:1:CV_K
    not_idx = find(Indices == i);
    train_X_idx = setdiff(1:1:input_size, not_idx);
    train_X = Xs(train_X_idx, :);
    train_Y = Ys(train_X_idx,:);
    
    test_X = Xs(not_idx,:);
    test_Y = Ys(not_idx,:);

    SVMModel = fitcsvm(train_X,train_Y, 'Standardize',true,'KernelFunction','RBF');
    [prediction, scores] = predict(SVMModel, test_X);
    
    confusion_matrix = zeros(2,2);
    confusion_matrix(1,1) = length(find(test_Y == 0 & prediction == 0));
    confusion_matrix(1,2) = length(find(test_Y == 0 & prediction == 1));
    confusion_matrix(2,1) = length(find(test_Y == 1 & prediction == 0));
    confusion_matrix(2,2) = length(find(test_Y == 1 & prediction == 1));
    
    accuracy = @(confusion_matrix) (confusion_matrix(1,1)+confusion_matrix(2,2))/sum(sum(confusion_matrix,2)+e);
    final_accuracy = final_accuracy + accuracy(confusion_matrix);
    
%     precision = @(confusion_matrix) max( confusion_matrix(1,1)/(confusion_matrix(1,1)+confusion_matrix(2,1)+e), confusion_matrix(2,2)/(confusion_matrix(1,2)+confusion_matrix(2,2)+e) );
    precision = @(confusion_matrix) confusion_matrix(1,1)/(confusion_matrix(1,1)+confusion_matrix(2,1)+e) ;
    
    final_precision = final_precision + precision(confusion_matrix);
    
%     recall = @(confusion_matrix) max( confusion_matrix(1,1)/(confusion_matrix(1,1)+confusion_matrix(1,2)+e), confusion_matrix(2,2)/(confusion_matrix(2,2)+confusion_matrix(2,1)+e) );
    recall = @(confusion_matrix) confusion_matrix(1,1)/(confusion_matrix(1,1)+confusion_matrix(1,2)+e);

    final_recall = final_recall + recall(confusion_matrix);
    
    f1Scores = @(confusion_matrix) 2*(precision(confusion_matrix).*recall(confusion_matrix))./(precision(confusion_matrix)+recall(confusion_matrix)+e);
    final_f1Scores = final_f1Scores + f1Scores(confusion_matrix);
    
    meanF1 = @(confusion_matrix) mean(f1Scores(confusion_matrix));
    final_meanF1 = final_meanF1 + meanF1(confusion_matrix);
    
    mdlSVM = fitcsvm(train_X,train_Y,'Standardize',true);
    mdlSVM = fitPosterior(mdlSVM);
    [~,score_svm] = resubPredict(mdlSVM);
    [Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(train_Y==1,score_svm(:,2),'true');
    final_ACU = final_ACU + AUCsvm;
end

final_accuracy = final_accuracy / CV_K;
final_precision = final_precision / CV_K;
final_recall = final_recall / CV_K;
final_f1Scores = final_f1Scores / CV_K;
% final_meanF1 = final_meanF1 / CV_K;
final_AUC = final_ACU / CV_K;

end

