%% Machine Learning -- Prj-------------------------------------------------
%  Class: wavProcess
%  Describe: Processing the sound
%--------------------------------------------------------------------------
%  Author: Lyu Yaopengfei
%  Date: 04/08/2016
%--------------------------------------------------------------------------

classdef wavProcess < handle
    properties(SetAccess = 'private')
        sigsnum;
        time;
        labels;
        origsig;
        desnsig;
        fftsig;
        WavSigSet;
    end
    
%     methods(Access = 'private')
    methods
        function readsig(wp, ws)
            wsNum = length(ws);
            wp.sigsnum = 0;
            for i=1:wsNum
                wp.sigsnum = ws(i).Count+wp.sigsnum;
            end

            wp.labels = zeros(wp.sigsnum,1);
            wp.time = zeros(wp.sigsnum,1);
            
%           sig{1}=time, sig{2}=sig, sig{3}=sampling rate
            wp.origsig = cell(wp.sigsnum,3);
            cnt = 0;
            for i=1:wsNum
                for j=1:ws(i).Count
                    [wp.origsig{cnt+j,2},wp.origsig{cnt+j,3}] = audioread(ws(i).WavLocation{j});
                    wp.origsig{cnt+j,2} = wp.origsig{cnt+j,2}';
                    
                    NS = length(wp.origsig{cnt+j,2});
                    SR = wp.origsig{cnt+j,3}; 
                    wp.time(cnt+j) = NS/SR;
                    wp.origsig{cnt+j,1} = linspace(0, wp.time(cnt+j), NS);
                    wp.labels(cnt+j) = i;
                    
                end
                cnt = ws(i).Count+cnt;
            end
        end
        
%       deSampling and deNoise        
        function desn(wp,drate)
%           sig{1}=time, sig{2}=dessig, sig{3}=densig, sig{4}=sampling rate
            wp.desnsig = cell(wp.sigsnum,4);
            for i=1:wp.sigsnum
                wp.desnsig{i,4} = round(wp.origsig{i,3}/drate);
                wp.desnsig{i,2} = decimate(wp.origsig{i,2},drate);
                NS = length(wp.desnsig{i,2});
                wp.desnsig{i,1} = linspace(0, wp.time(i), NS);
            end
            
            level = 5;
            for i=1:wp.sigsnum
                w = wp.desnsig{i,2};
                DNS1 = wden(w, 'minimaxi', 's', 'mln', level, 'db10');
                thr = thselect(w,'minimaxi');
                thrSettings =  [...
                    thr ; ...
                    thr ; ...
                    0 ; ...
                    0 ; ...
                    0 ; ...
                    ];
                DNS2 = cmddenoise(DNS1, 'db10', level, 's', NaN,thrSettings);
                DNS2 = (DNS2-min(DNS2))/(max(DNS2)-min(DNS2));
                DNS2 = DNS2 - mean(DNS2);
                wp.desnsig{i,3} = DNS2;
            end
        end

        function ft(wp)
            wp.fftsig = cell(wp.sigsnum,3);
            for i=1:wp.sigsnum
%               desampling signal
                dsstemp = wp.desnsig{i,2};
%               sampling rate
                sRtemp = wp.desnsig{i,4};
                K = length(dsstemp);
                wp.fftsig{i,1} = linspace(0,sRtemp/2,ceil(K/2)+1);
                Fftsig = abs(fftshift(fft(dsstemp,K)));
                wp.fftsig{i,2} = Fftsig(fix(K/2):end);
                wp.fftsig{i,2} = wp.fftsig{i,2}/K;
                
%               denoise signal
                dnstemp = wp.desnsig{i,3};
                Fftsig = abs(fftshift(fft(dnstemp,K)));
                wp.fftsig{i,3} = Fftsig(fix(K/2):end);
                wp.fftsig{i,3} = wp.fftsig{i,3}/K;
            end
        end
        
        function tidysig(wp)
            wp.WavSigSet = cell(wp.sigsnum+1,10);
            wp.WavSigSet{1,1} = 'label';
            wp.WavSigSet{1,2} = 'time';
            wp.WavSigSet{1,3} = 'origSig';
            wp.WavSigSet{1,4} = 'origSR';
            wp.WavSigSet{1,5} = 'desSig';
            wp.WavSigSet{1,6} = 'denSig';
            wp.WavSigSet{1,7} = 'desSR';
            wp.WavSigSet{1,8} = 'fftSig';
            wp.WavSigSet{1,9} = 'fftSig_dn';
            wp.WavSigSet{1,10} = 'Frequency';
            wp.WavSigSet(2:end,1) = num2cell(wp.labels);
            wp.WavSigSet(2:end,2) = num2cell(wp.time);
            wp.WavSigSet(2:end,3) = wp.origsig(:,2);
            wp.WavSigSet(2:end,4) = wp.origsig(:,3);
            wp.WavSigSet(2:end,5) = wp.desnsig(:,2);
            wp.WavSigSet(2:end,6) = wp.desnsig(:,3);
            wp.WavSigSet(2:end,7) = wp.desnsig(:,4);
            wp.WavSigSet(2:end,8) = wp.fftsig(:,2);
            wp.WavSigSet(2:end,9) = wp.fftsig(:,3);
            wp.WavSigSet(2:end,10) = wp.fftsig(:,1);
        end
        
    end
    
    methods
        function wp = wavProcess(ws)
            wp.readsig(ws);
            wp.desn(40);
            wp.ft();
            wp.tidysig();
        end
    end
    
end