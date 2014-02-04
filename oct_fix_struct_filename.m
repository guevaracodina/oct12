function oct_fix_struct_filename(varargin)
% Function that fixes struct3d filenames in OCT structure (.bin files) 
% SYNTAX
% oct_fix_struct_filename(subjectFolder)
% INPUT 
% subjectFolder     Parent folder containing the FOV folders. Prompts the user
%                   to pick a directory if empty.
% OUTPUT 
% None              struct3d filenames fixed in
%                   OCT.recons_info.struct_recons.filename 
% 
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% only want 1 optional input at most
numvarargs = length(varargin);
if numvarargs > 1
    error('oct_arrange_scans:TooManyInputs', ...
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
dataFolder = 'F:\Edgar\Data\OCT_Data\';

if ~exist(dataFolder,'dir')
    dataFolder = matlabroot;
end
if isempty(subjectFolder) || ~exist(subjectFolder,'var')
    subjectFolder = uigetdir(dataFolder, 'Pick a subject directory');
    if subjectFolder == 0
        % User cancelled input
        disp('User cancelled input')
        return
    end
end

tic
fprintf('Fixing .struct3D filenames in their corresponding OCT.mat files...\n')

% Separate subdirectories and files:
d = dir(subjectFolder);
isub = [d(:).isdir];            % Returns logical vector
folderList = {d(isub).name}';
% Remove . and ..
folderList(ismember(folderList,{'.','..'})) = [];

% Scans (FOV) loop
for iScans = 1:length(folderList)
    currentFolder = fullfile(subjectFolder,folderList{iScans});
    % Find OCT.mat files
    d = dir(fullfile(currentFolder,'OCT.mat'));
    fileList = {d.name}';
    if isempty(fileList)
        fprintf('No OCT.mat files in folder %s\n',currentFolder)
    else
        % Loop through all OCT.mat files
        for iFiles=1:length(fileList)
            currentFile = fullfile(currentFolder,fileList{iFiles});
            load(currentFile);
            % Find .struct3D files
            d1 = dir(fullfile(currentFolder,'*.struct3d'));
            structFileList = {d1.name}';
             if isempty(fileList)
                fprintf('No .struct3d files in folder %s\n',currentFolder)
             else
                % Add filename in OCT.mat
                OCT.recons_info.struct_recons.filename = fullfile(currentFolder,structFileList{1});
                save(currentFile, 'OCT');
             end
        end
    end
end
fprintf('Fixing .struct3D filenames done!\n')
disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')]);

% EOF


