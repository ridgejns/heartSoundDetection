%% Machine Learning -- Prj-------------------------------------------------
%  Class: wavSet
%  Describe: Get the sound set
%--------------------------------------------------------------------------
%  Author: Lyu Yaopengfei
%  Date: 03/12/2016
%--------------------------------------------------------------------------

classdef wavSet < handle
    properties(SetAccess = 'private')
        Description
        WavLocation
        Count
    end
    
    methods
        function wavset = wavSet(wavfolderpath, varargin)
            if nargin==0||nargin>2
                error('Invalid parameter.')
            end
            % path is must a folder, not file
            if(~isdir(wavfolderpath))
                error('Invalid file folder.')
            end

            if nargin==1
                wavpath = fullfile(wavfolderpath,'*.wav');
                [~,wavset.Description,~] = fileparts(wavfolderpath);
                d = dir(wavpath);
                wavset.Count = length(d);
                wavset.WavLocation = cell(1,wavset.Count);
                for i = 1:wavset.Count
                    wavset.WavLocation{i} = fullfile(wavfolderpath,d(i).name);
                end

            elseif nargin==2
                if strcmpi(varargin{1},'recursive')
                    wavdircnt = 0;
                    paths = genpath(wavfolderpath);
                    paths = regexp(paths, ':', 'split');
                    pathsNum = length(paths)-1;
                    for i=1:pathsNum
                        ws = wavSet(paths{i});
                        if(ws.Count > 0)
                            wavdircnt = wavdircnt+1;
                            wavset(wavdircnt) = ws;
                        end
                    end
                else
                    error('Invalid parameter.')
                end
            else
                error('Invalid parameter.')
            end
        end
    end
end