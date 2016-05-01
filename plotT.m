tic
hold on
i=1;
x = wp.maxFreq(i);
[pks,locs] = findpeaks(sig2,linspace(1,x,length(sig2)),'SortStr','descend');
findpeaks(sig2,linspace(0,x,length(sig2)));
text(locs+.02,pks,num2str((1:numel(pks))'))
toc
% figure()
% i = 220;
% % sig = wp.origSig{i};
% % sr = wp.origSR(i);
% sig = wp.denSig{i};
% sr = wp.deSR(i);
% x = linspace(0,wp.time(i),length(sig));
% % sig2 = wp.ds_fft_env{i};
% plot(x,sig)
% % plot(linspace(0,x,length(sig2)),sig2,'LineWidth',2)
% xlabel('Frequency','FontSize',12)
% ylabel('Intensity','FontSize',12)
% title(wp.label{i,2},'FontSize',16)
% snd = audioplayer(sig,sr);
% play(snd)
%%
% s1mask = find(x>0.05 & x<0.2);
% s1 = sig(s1mask);
% K = length(s1);
% ffts1 = abs(fftshift(fft(s1,K)));
% ffts1 = ffts1(fix(K/2):end);
% figure()
% plot(linspace(0,wp.maxFreq(i),length(ffts1)),ffts1)
% 
% s2mask = find(x>0.3 & x<0.45);
% s2 = sig(s2mask);
% K = length(s2);
% ffts1 = abs(fftshift(fft(s2,K)));
% ffts1 = ffts1(fix(K/2):end);
% figure()
% plot(linspace(0,wp.maxFreq(i),length(ffts1)),ffts1)

% s3mask = find(x>0.2 & x<0.7);
% s3 = sig(s3mask);
% K = length(s3);
% ffts1 = abs(fftshift(fft(s3,K)));
% ffts1 = ffts1(fix(K/2):end);
% ffts1 = ffts1(0:length(ffts1)/4);
% figure()
% plot(linspace(0,wp.maxFreq(i)/4,length(ffts1)),ffts1)
%%
figure(), hold on
i=46;
x = wp.maxFreq(i);
sig = wp.dn_fft{i};
sig = sig(1:length(sig));
sig2 = wp.dn_fft_env{i};
sig2 = sig2(1:length(sig2));
plot(linspace(0,x,length(sig)),sig)
plot(linspace(0,x,length(sig2)),sig2,'LineWidth',2)
yy = ones(1,20)*0.02;
stem(linspace(0,x,20),yy,'LineWidth',2)
for i=1:19
    str = sprintf('N%d',i);
    text(1+x/19*(i-1),0.018,str,'FontSize',11);
end
% [pks,locs] = findpeaks(sig2,linspace(1,x,length(sig2)),'SortStr','descend');
% findpeaks(sig2,linspace(0,x,length(sig2)));
% text(locs+.02,pks,num2str((1:numel(pks))'))
xlabel('Frequency','FontSize',12)
ylabel('Intensity','FontSize',12)
title('murmur','FontSize',16)

%%
figure()
subplot(3,1,1), hold on
i = 12;
x = wp.maxFreq(i);
sig = wp.dn_fft{i};
sig = sig(1:length(sig));
sig2 = wp.dn_fft_env{i};
sig2 = sig2(1:length(sig2));
plot(linspace(0,x,length(sig)),sig)
% plot(linspace(0,x,length(sig2)),sig2,'LineWidth',2)
[pks,locs] = findpeaks(sig2,linspace(1,x,length(sig2)),'SortStr','descend');
findpeaks(sig2,linspace(0,x,length(sig2)));
text(locs+.02,pks,num2str((1:numel(pks))'))
xlabel('Frequency','FontSize',12)
ylabel('Intensity','FontSize',12)
title(wp.label{i,2},'FontSize',16)

subplot(3,1,2), hold on
i = 46;
x = wp.maxFreq(i);
sig = wp.ds_fft{i};
sig2 = wp.ds_fft_env{i};
plot(linspace(0,x,length(sig)),sig)
% plot(linspace(0,x,length(sig2)),sig2,'LineWidth',2)
[pks,locs] = findpeaks(sig2,linspace(1,x,length(sig2)),'SortStr','descend');
findpeaks(sig2,linspace(0,x,length(sig2)));
text(locs+.02,pks,num2str((1:numel(pks))'))
xlabel('Frequency','FontSize',12)
ylabel('Intensity','FontSize',12)
title(wp.label{i,2},'FontSize',16)

subplot(3,1,3), hold on
i = 79;
x = wp.maxFreq(i);
sig = wp.ds_fft{i};
sig2 = wp.ds_fft_env{i};
plot(linspace(0,x,length(sig)),sig)
% plot(linspace(0,x,length(sig2)),sig2,'LineWidth',2)
[pks,locs] = findpeaks(sig2,linspace(1,x,length(sig2)),'SortStr','descend');
findpeaks(sig2,linspace(0,x,length(sig2)));
text(locs+.02,pks,num2str((1:numel(pks))'))
xlabel('Frequency','FontSize',12)
ylabel('Intensity','FontSize',12)
title(wp.label{i,2},'FontSize',16)
%%
for i = 1:1:wp.sigsNum
    figure(1),clf, hold on
    x = wp.maxFreq(i);
    sig = wp.dn_fft{i};
    sig = sig(1:length(sig));
    sig2 = wp.dn_fft_env{i};
    sig2 = sig2(1:length(sig2));
    plot(linspace(0,x,length(sig)),sig)
    % plot(linspace(0,x,length(sig2)),sig2,'LineWidth',2)
    [pks,locs] = findpeaks(sig2,linspace(1,x,length(sig2)),'SortStr','descend');
    findpeaks(sig2,linspace(0,x,length(sig2)));
    text(locs+.02,pks,num2str((1:numel(pks))'))
    xlabel('Frequency','FontSize',12)
    ylabel('Intensity','FontSize',12)
    title(wp.label{i,2},'FontSize',16)
    pause()
end