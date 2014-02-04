function bpm_avg = oct_get_avg_bpm_per_subject(varargin)
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% only want 1 optional input at most
numvarargs = length(varargin);
if numvarargs > 1
    error('oct_get_avg_bpm_per_subject:TooManyInputs', ...
        'Requires at most 1 optional input');
end

% set defaults for optional inputs
optargs = {[]};

% now put these defaults into the optargs cell array, and overwrite the ones
% specified in varargin.
optargs(1:numvarargs) = varargin;

% Place optional args in memorable variable names
subjectFolder = optargs{:};

% Top folder containing all subjects data (change as needed)
dataFolder = 'F:\Edgar\Data\OCT_Results\';

if ~exist(dataFolder,'dir')
    dataFolder = matlabroot;
end
if isempty(subjectFolder) || ~exist('subjectFolder','var')
    subjectFolder = uigetdir(dataFolder, 'Pick a subject directory');
    if subjectFolder == 0
        % User cancelled input
        disp('User cancelled input')
        return
    end
end

tic
fprintf('Retrieving ECG information...\n')

% Separate subdirectories and files:
d = dir(subjectFolder);
isub = [d(:).isdir];            % Returns logical vector
FOVlist = {d(isub).name}';
% Remove . and ..
FOVlist(ismember(FOVlist,{'.','..'})) = [];

% Initialize counter
iScans = 1;

for iFOV = 1:numel(FOVlist)
    currentFOV = fullfile(subjectFolder, FOVlist{iFOV});
    % Get individual scans folders
    d = dir(currentFOV);
    isub = [d(:).isdir];            % Returns logical vector
    folderList = {d(isub).name}';
    % Remove . and ..
    folderList(ismember(folderList, {'.','..'})) = [];
    for iFolders = 1:numel(folderList)
        scanList{iScans, 1} = fullfile(currentFOV, folderList{iFolders});
        iScans = iScans + 1;
    end
end

% Preallocate data
bpm = zeros(size(scanList));
% Retrieve OCT.mat
for iScans = 1:numel(scanList),
    load(fullfile(scanList{iScans}, 'OCT.mat'))
    bpm(iScans) = OCT.acqui_info.bpm;
end

% Mean bpm of subject
bpm_avg = nanmean(bpm);
fprintf('Average bpm = %0.2f for %s\n',bpm_avg,subjectFolder)

% EOF
