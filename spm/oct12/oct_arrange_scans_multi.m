function oct_arrange_scans_multi(varargin)
% Function that arranges scans (.bin files) in sub-folders within each scan(FOV)
% folder; each scan is stored in directories called X, Y and 3D, depending on
% the type of scan
% SYNTAX
% oct_arrange_scans_multi(dataFolder)
% INPUT 
% dataFolder        Optional directory to start off in
% OUTPUT 
% None              .BIN files are organized as follows:
% 
% dataFolder
%     \--> subjectFolder
%         \--> scanFolder
%             \--> 3D
%             \--> X
%             \--> Y
% 
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% only want 1 optional input at most
numvarargs = length(varargin);
if numvarargs > 1
    error('oct_arrange_scans_multi:TooManyInputs', ...
        'Requires at most 1 optional input');
end

% set defaults for optional inputs
optargs = {'E:\Edgar\Data\OCT_Data\'};

% now put these defaults into the optargs cell array, and overwrite the ones
% specified in varargin.
optargs(1:numvarargs) = varargin;

% Place optional args in memorable variable names
dataFolder = optargs{:};

% Check if dataFolder is a valid directory, else get current working dir
if ~exist(dataFolder,'dir')
    dataFolder = pwd;
end

% Separate subdirectories and files:
d = dir(dataFolder);
isub = [d(:).isdir];            % Returns logical vector
folderList = {d(isub).name}';
% Remove . and ..
folderList(ismember(folderList,{'.','..'})) = [];

%% Choose the subjects folders
[subjectList, sts] = cfg_getfile(Inf,'dir','Select subject folders',folderList, dataFolder, '.*'); %dataFolder

%% Arrange scans for every subject folder
if sts
    for iFolders = 1:numel(subjectList)
        oct_arrange_scans(subjectList{iFolders})
    end
else
    disp('User cancelled input')
end
