%% Machine Learning -- Prj-------------------------------------------------
%  Class: wavProcess
%  Describe: Processing the sound
%--------------------------------------------------------------------------
%  Author: Lyu Yaopengfei
%  Date: 04/08/2016
%--------------------------------------------------------------------------

classdef wavProcess < handle
%     properties(SetAccess = 'private', GetAccess = 'private')
    properties(SetAccess = 'private')
        label;
        time;
        origSig;
        origSR;
        desSig;
        denSig;
        deSR;
        ds_fft;
        ds_fft_env;
        dn_fft;
        dn_fft_env;
        maxFreq;
    end
    
    properties(SetAccess = 'private')
        sigsNum;
        WavSigSet;
    end
    
%     methods(Access = 'private')
    methods
        function readsig(wp, ws)
            wsNum = length(ws);
            wp.sigsNum = 0;
            for i=1:wsNum
                wp.sigsNum = ws(i).Count+wp.sigsNum;
            end
            wp.label = cell(wp.sigsNum,2);
            wp.time = zeros(wp.sigsNum,1);
            wp.origSig = cell(wp.sigsNum,1);
            wp.origSR = zeros(wp.sigsNum,1);
            cnt = 0;
            for i=1:wsNum
                for j=1:ws(i).Count
                    [wp.origSig{cnt+j},wp.origSR(cnt+j)] = audioread(ws(i).WavLocation{j});
                    wp.origSig{cnt+j} = wp.origSig{cnt+j}';
                    
                    NS = length(wp.origSig{cnt+j});
                    SR = wp.origSR(cnt+j); 
                    wp.time(cnt+j) = NS/SR;
                    wp.label{cnt+j,1} = i;
                    wp.label{cnt+j,2} = ws(i).Description;
                end
                cnt = ws(i).Count+cnt;
            end
%             wp.origSig = wp.origSig';
        end
        
%       deSampling and deNoise        
        function desnsig(wp,drate)
            wp.desSig = cell(wp.sigsNum,1);
            wp.deSR = zeros(wp.sigsNum,1);
            for i=1:wp.sigsNum
                wp.deSR(i) = round(wp.origSR(i)/drate);
                wp.desSig{i} = decimate(wp.origSig{i},drate);
            end
            
            level = 5;
            wp.denSig = cell(wp.sigsNum,1);
            for i=1:wp.sigsNum
                w = wp.desSig{i};
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
                wp.denSig{i} = DNS2;
            end
        end

        function ftsig(wp)
            wp.ds_fft = cell(wp.sigsNum,1);
            wp.ds_fft_env = cell(wp.sigsNum,1);
            wp.dn_fft = cell(wp.sigsNum,1);
            wp.ds_fft_env = cell(wp.sigsNum,1);
            wp.dn_fft_env = cell(wp.sigsNum,1);
            wp.maxFreq = zeros(wp.sigsNum,1);
            for i=1:wp.sigsNum
%               desampling signal
                dsstemp = wp.desSig{i};
%               new sampling rate
                sRtemp = wp.deSR(i);
                K = length(dsstemp);
                wp.maxFreq(i) = sRtemp/2;
                Fftsig = abs(fftshift(fft(dsstemp,K)));
                wp.ds_fft{i} = Fftsig(fix(K/2):end);
                wp.ds_fft{i} = wp.ds_fft{i}/K;
                wp.ds_fft_env{i} = envelope(wp.ds_fft{i},80,'peak');
                
%               denoise signal
                dnstemp = wp.denSig{i};
                Fftsig = abs(fftshift(fft(dnstemp,K)));
                wp.dn_fft{i} = Fftsig(fix(K/2):end);
                wp.dn_fft{i} = wp.dn_fft{i}/K;
                wp.dn_fft_env{i} = envelope(wp.dn_fft{i},80,'peak');
            end
        end
        
        function tidysig(wp)
            wp.WavSigSet = cell(wp.sigsNum+1,12);
            wp.WavSigSet{1,1} = 'label';
            wp.WavSigSet{1,2} = 'time';
            wp.WavSigSet{1,3} = 'origSig';
            wp.WavSigSet{1,4} = 'origSR';
            wp.WavSigSet{1,5} = 'desSig';
            wp.WavSigSet{1,6} = 'denSig';
            wp.WavSigSet{1,7} = 'deSR';
            wp.WavSigSet{1,8} = 'ds_fft';
            wp.WavSigSet{1,9} = 'ds_fft_env';
            wp.WavSigSet{1,10} = 'dn_fft';
            wp.WavSigSet{1,11} = 'dn_fft_env';
            wp.WavSigSet{1,12} = 'maxFreq';
            wp.WavSigSet(2:end,1) = wp.label(:,1);
            wp.WavSigSet(2:end,2) = num2cell(wp.time);
            wp.WavSigSet(2:end,3) = wp.origSig;
            wp.WavSigSet(2:end,4) = num2cell(wp.origSR);
            wp.WavSigSet(2:end,5) = wp.desSig;
            wp.WavSigSet(2:end,6) = wp.denSig;
            wp.WavSigSet(2:end,7) = num2cell(wp.deSR);
            wp.WavSigSet(2:end,8) = wp.ds_fft;
            wp.WavSigSet(2:end,9) = wp.ds_fft_env;
            wp.WavSigSet(2:end,10) = wp.dn_fft;
            wp.WavSigSet(2:end,11) = wp.dn_fft_env;
            wp.WavSigSet(2:end,12) = num2cell(wp.maxFreq);
        end
        
        function [feature] = freqfeature(wp, segN)
            seg = zeros(segN+1,1);
            feature = zeros(segN,wp.sigsNum);
            for i=1:wp.sigsNum
                sig = wp.dn_fft{i};
                for j=1:segN
                    len = length(sig);
                    seg(j+1) = fix(len/segN*j);
                    feature(j,i) = sum(sig(seg(j)+1:seg(j+1)));
                end
                feature(:,i) = (feature(:,i)-min(feature(:,i)))/(max(feature(:,i))-min(feature(:,i)));
            end
        end
    end
    
    methods
        function wp = wavProcess(varargin)
            if nargin==0
                print('return a empty object');
                return
            elseif nargin==1
                ret = isa(varargin{1},'wavSet');
                if ret
                   wp.readsig(varargin{1});
                else
                    error('invalid input');
                end
                drate = 1;
            elseif nargin==2
                ret = isa(varargin{1},'wavSet');
                if ret
                   wp.readsig(varargin{1});
                else
                    error('invalid input');
                end
                drate = varargin{2};
            else
                error('too many inputs')
            end
            wp.desnsig(drate);
            wp.ftsig();
            wp.tidysig();
        end
        
        function [label, feature] = extractfeature(wp,varargin)
            disp(nargin)
            if nargin==1
                feature = wp.freqfeature(100);
                label = cell2mat(wp.label(:,1));
                return
            elseif nargin==3
                for i=1:nargin-1
                    ret1 = strncmpi(varargin{i},'frequency',4);
                    ret2 = strcmpi(varargin{i},'time');
                    if ret1
                        feature = wp.freqfeature(varargin{i+1});
                        label = cell2mat(wp.label(:,1));
                        return
                    elseif ret2
                        error('time domain feature is developing')
                    else
                        error('invalid input')
                    end
                end
            else
                error('invalid input')
            end
        end
    end
    
end