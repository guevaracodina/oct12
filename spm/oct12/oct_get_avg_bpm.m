function [avg_bpm bpm] = oct_get_avg_bpm(varargin)
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% only want 1 optional input at most
numvarargs = length(varargin);
if numvarargs > 1
    error('oct_get_avg_bpm:TooManyInputs', ...
        'Requires at most 1 optional input');
end

% set defaults for optional inputs
optargs = {[]};

% now put these defaults into the optargs cell array, and overwrite the ones
% specified in varargin.
optargs(1:numvarargs) = varargin;

% Place optional args in memorable variable names
subjectFolder = optargs{:};

% Top folder containing all subjects results (change as needed)
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
fprintf('Computing average cardiac bpm...\n')

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
% 2D scans index
scanIdx = true(size(scanList));
% Retrieve OCT.mat
for iScans = 1:numel(scanList),
    load(fullfile(scanList{iScans}, 'OCT.mat'))
    if isfield(OCT, 'acqui_info')
        bpm(iScans) = OCT.acqui_info.bpm;
    else
        bpm(iScans) = NaN;
    end
    if ~isempty(regexp(scanList{iScans},'3D','match', 'once'))
        scanIdx(iScans) = false;
    end
end

% Mean bpm of subject
avg_bpm = nanmean(bpm);

% Keep only 2D scans for pulsatility
bpm = bpm(scanIdx);

[~, iD, ~] = fileparts(subjectFolder);
fprintf('%.2f bpm for %s\n', avg_bpm, iD)
disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')]);

% EOF
