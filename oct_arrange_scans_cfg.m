function arrange1 = oct_arrange_scans_cfg
% Graphical interface configuration function for oct_arrange_scans_run.
% This code is part of a batch job configuration system for MATLAB. See help
% matlabbatch for a general overview.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Edgar Guevara
% $Id$

rev = '$Rev$'; %#ok

%% Data Folder
dataFolder              = cfg_files; 
dataFolder.name         = 'Data folder'; 
dataFolder.tag          = 'rawdata_dir';       %directory names
dataFolder.filter       = 'dir';   
dataFolder.ufilter      = '.*';    
dataFolder.num          = [1 Inf];     % Number of inputs required 
dataFolder.help         = {'Select top raw data folder that contains the subjects folders.'}; % help text displayed

%% Choose individual subjects folders
chooseSubjectDir        = cfg_menu;
chooseSubjectDir.name   = 'Choose subject folders';
chooseSubjectDir.tag    = 'chooseSubjectDir';
chooseSubjectDir.labels = {'Yes' 'No'};
chooseSubjectDir.values = {true false};
chooseSubjectDir.val    = {false};
chooseSubjectDir.help   = {'Choose individual subject folders to be processed. By default, all folders inside data folder are processed.'};

%% Executable Branch
arrange1                = cfg_exbranch;       % This is the branch that has information about how to run this module
arrange1.name           = 'Arrange scans in separate folders';             % The display name
arrange1.tag            = 'oct_arrange_scans_cfg'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
arrange1.val            = {dataFolder chooseSubjectDir};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
arrange1.prog           = @oct_arrange_scans_run;  % A function handle that will be called with the harvested job to run the computation
arrange1.vout           = @oct_arrange_scans_vout; % A function handle that will be called with the harvested job to determine virtual outputs
arrange1.help           = {'Arranges scans (.bin files) in sub-folders within each scan(FOV) folder; each scan is stored in directories called X, Y and 3D, depending on the type of scan:' 
                '\dataFolder'
                ' \--> subjectFolder'
                '    \--> scanFolder'
                '        \--> 3D'
                '        \--> X'
                '        \--> Y'};

%% Local Functions
% For output dependency
function vout           = oct_arrange_scans_vout(job)
% Determine what outputs will be present if this job is run. In this case,
% the structure of the inputs is fixed, and the output is always a single
% number. Note that input items may not be numbers, they can also be
% dependencies.
vout                    = cfg_dep;                        % The dependency object
vout.sname              = 'OCT.mat';            % Displayed dependency name
vout.src_output         = substruct('.','OCTmat'); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
