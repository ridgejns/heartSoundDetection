clear, clc
wavPATH = '/Users/lvypf/OneDrive/myprjs/MATLAB/sound/soundA';
wavset = wavSet(wavPATH,'recursive');
wp = wavProcess(wavset,40);
[label,feature]=wp.extractfeature('freq',100);
%%
mywavset = wavSet('/Users/lvypf/OneDrive/myprjs/MATLAB/sound/myNorm','recursive');
mywp = wavProcess(mywavset,40);
[~,myfeature]=mywp.extractfeature('freq',100);
%%
cr = 0;
N = 20;
for i = 1:N
    cvp = cvpartition(label,'HoldOut',0.1);
    trainingIdx = cvp.training;
    testIdx = cvp.test;
    testFeature = feature(:,testIdx);
    testLabel = label(testIdx);
    trainFeature = feature(:,trainingIdx);
    trainLabel = label(trainingIdx);

    model = fitcecoc(trainFeature',trainLabel','Coding','onevsone','Learners','svm');
    predectedTestLabel = predict(model,testFeature');

    tf = testLabel - predectedTestLabel;
    correctRate = length(find(tf == 0))/size(predectedTestLabel,1);
    display(['correctRate: ',num2str(correctRate)]);
    cr = cr+correctRate;
end
display(['avgcorrectRate: ',num2str(cr/N)]);
%%
plot(testLabel,'r'); hold on
plot(predectedTestLabel,'b')
