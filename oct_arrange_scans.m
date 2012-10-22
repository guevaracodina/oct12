function oct_arrange_scans(varargin)
% Function that arranges scans (.bin files) in sub-folders within each scan(FOV)
% folder; each scan is stored in directories called X, Y and 3D, depending on
% the type of scan
% SYNTAX
% oct_arrange_scans(subjectFolder)
% INPUT 
% subjectFolder     Parent folder containing the FOV folders. Prompts the user
%                   to pick a directory if empty.
% OUTPUT 
% None              .BIN files are organized as follows
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
dataFolder = 'E:\Edgar\Data\OCT_Data\';

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
fprintf('Arranging .BIN files in their corresponding folders...\n')

% Separate subdirectories and files:
d = dir(subjectFolder);
isub = [d(:).isdir];            % Returns logical vector
folderList = {d(isub).name}';
% Remove . and ..
folderList(ismember(folderList,{'.','..'})) = [];

% Scans (FOV) loop
for iScans = 1:length(folderList)
    currentFolder = fullfile(subjectFolder,folderList{iScans});
    % Find .BIN files
    d = dir(fullfile(currentFolder,'*.bin'));
    fileList = {d.name}';
    if isempty(fileList)
        fprintf('No .BIN files in folder %s\n',currentFolder)
    else
        % Loop through all .bin files
        for iFiles=1:length(fileList)
            currentFile = fullfile(currentFolder,fileList{iFiles});
            % Check the type of scan according to the filename
            fileType = oct_check_file_type(currentFile);
            newFolder = [currentFolder filesep fileType];
            if ~exist(newFolder,'dir')
                mkdir(currentFolder, fileType);
            end
            newFile = fullfile(newFolder, fileList{iFiles});
            try
                % Fast alternative (undocumented java feature)
                java.io.File(currentFile).renameTo(java.io.File(newFile));
            catch exception
                % Slow alternative...
                movefile(currentFile, newFile);
                disp(exception.identifier)
                disp(exception.stack(1))
            end
        end
    end
end
fprintf('Arranging .BIN files done!\n')
disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')]);

function fileType = oct_check_file_type(currentFile)
% Determines type of scan (X, Y, 3D) (ignores case)
startIndex = regexpi(currentFile, 'Coupe selon X', 'once');
if ~isempty(startIndex)
    fileType = 'X';
end
startIndex = regexpi(currentFile, 'Coupe selon Y', 'once');
if ~isempty(startIndex)
    fileType = 'Y';
end
startIndex = regexpi(currentFile, '3D rev fast axis', 'once');
if ~isempty(startIndex)
    fileType = '3D';
end

% EOF

