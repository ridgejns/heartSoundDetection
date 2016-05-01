clear, clc
wavPATH = '/Users/lvypf/OneDrive/myprjs/MATLAB/sound/soundA';
wavset = wavSet(wavPATH,'recursive');
wp = wavProcess(wavset,20,0.25);
%%
[label,feature] = wp.extractfeature('freq2',1);
% [label,feature]=wp.extractfeature('freq2',100);
% C = feature;
% cnt = 0;
% for i=1:length(wavset)
%     for j=1:wavset(i).Count
%         cnt = cnt+1;
%     end
% end


%%
mywavset = wavSet('/Users/lvypf/OneDrive/myprjs/MATLAB/sound/myNorm','recursive');
mywp = wavProcess(mywavset,20,0.25);
[~,myfeature]=mywp.extractfeature('freq2',1);
%%
cr = 0;
N = 20;
for i = 1:N
    cvp = cvpartition(label,'HoldOut',0.3);
    trainingIdx = cvp.training;
    testIdx = cvp.test;
    testFeature = feature(testIdx,:);
    testLabel = label(testIdx);
    trainFeature = feature(trainingIdx,:);
    trainLabel = label(trainingIdx);

%     model = fitcsvm(trainFeature,trainLabel, 'Standardize', true,'KernelFunction','polynomial');
%     model = fitcsvm(trainFeature,trainLabel, 'Standardize', true);
    model = fitcecoc(trainFeature,trainLabel,'Coding','onevsone','Learners','svm');
%     model = fitcknn(trainFeature,trainLabel);
%     model = fitcnb(trainFeature,trainLabel);
    predectedTestLabel = predict(model,testFeature);

    tf = testLabel - predectedTestLabel;
    correctRate = length(find(tf == 0))/size(predectedTestLabel,1);
    display(['correctRate: ',num2str(correctRate)]);
    cr = cr+correctRate;
end
display(['avgcorrectRate: ',num2str(cr/N)]);
%%
plot(testLabel,'r'); hold on
plot(predectedTestLabel,'b')
