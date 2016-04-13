clear, clc
wavPATH = '/Users/lvypf/OneDrive/myprjs/MATLAB/sound/soundA';
wavset = wavSet(wavPATH,'recursive');
wp = wavProcess(wavset);

%%
segN = 200;
seg = zeros(segN+1,1);
feature = zeros(segN,wp.sigsnum);

for i=1:wp.sigsnum
    for j=1:segN
        seg(j+1)=fix(length(wp.WavSigSet{i+1,9})/segN*j);
        feature(j,i) = sum(wp.WavSigSet{i+1,9}(seg(j)+1:seg(j+1)));
    end
    feature(:,i) = (feature(:,i)-min(feature(:,i)))/(max(feature(:,i))-min(feature(:,i)));
end
%%
cr=0;
N=100;
for i = 1:N
cvp = cvpartition(wp.labels,'HoldOut',0.2);
trainingIdx = cvp.training;
testIdx = cvp.test;
testData = feature(:,testIdx);
testLabel = wp.labels(testIdx);
trainData = feature(:,trainingIdx);
trainLabel = wp.labels(trainingIdx);

model = fitcecoc(trainData',trainLabel','Coding','onevsone','Learners','svm');
nlabel = predict(model,testData');

tf = testLabel - nlabel;
correctRate = length(find(tf == 0))/size(nlabel,1);
display(['correctRate: ',num2str(correctRate)]);
cr = cr+correctRate;
end
display(['avgcorrectRate: ',num2str(cr/N)]);
%%
plot(testLabel,'r'); hold on
plot(nlabel,'b')
