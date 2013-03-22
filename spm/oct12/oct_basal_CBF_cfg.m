function basalCBF = oct_basal_CBF_cfg
% Graphical interface configuration function for oct_basal_CBF_run.
% This code is part of a batch job configuration system for MATLAB. See help
% matlabbatch for a general overview.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Edgar Guevara
% $Id$

rev = '$Rev$'; %#ok

% OCT structure input
OCTmat                  = cfg_files;     % Select OCT.mat for this subject 
OCTmat.name             = 'OCT.mat';     % The displayed name
OCTmat.tag              = 'OCTmat';      % file names
OCTmat.filter           = 'mat';
OCTmat.ufilter          = '^OCT.mat$';    
OCTmat.num              = [1 Inf];       % Number of inputs required 
OCTmat.help             = {'Select OCT.mat for the scan.'}; % help text displayed

redo                    = cfg_menu; % This is the generic data entry item
redo.name               = 'Force Redo?'; % The displayed name
redo.tag                = 'redo';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
redo.labels             = {'No', 'Yes'};     % Number of inputs required (2D-array with exactly one row and two column)
redo.values             = {false, true};
redo.val                = {false};
redo.help               = {'This option will force recomputation.'}; % help text displayed

% Select directory to save global results
save_data_dir           = cfg_files;
save_data_dir.tag       = 'save_data_dir';
save_data_dir.name      = 'Directory to save group data';
save_data_dir.filter    = 'dir'; 
save_data_dir.num       = [1 1];
save_data_dir.help      = {'Select the directory where consolidated basal flow data will be saved'}';

% Save figures
save_figures            = cfg_menu; % This is the generic data entry item
save_figures.name       = 'Save pulsatility figures?'; % The displayed name
save_figures.tag        = 'save_figures';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
save_figures.labels     = {'No', 'Yes'};     % Number of inputs required (2D-array with exactly one row and two column)
save_figures.values     = {false, true};
save_figures.val        = {false};
save_figures.help       = {'This option will save basal CBF figures.'}; % help text displayed

%% Executable Branch
basalCBF                = cfg_exbranch;       % This is the branch that has information about how to run this module
basalCBF.name           = 'Basal CBF';             % The display name
basalCBF.tag            = 'oct_basal_CBF_cfg'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
basalCBF.val            = {OCTmat redo save_data_dir save_figures};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
basalCBF.prog           = @oct_basal_CBF_run;  % A function handle that will be called with the harvested job to run the computation
basalCBF.vout           = @oct_basal_CBF_vout; % A function handle that will be called with the harvested job to determine virtual outputs
basalCBF.help           = {'Computes basal (quantitative in nL/s) cerebral blood flow (CBF) manually.'};

%% Local Functions
% For output dependency
function vout           = oct_basal_CBF_vout(job)
% Determine what outputs will be present if this job is run. In this case,
% the structure of the inputs is fixed, and the output is always a single
% number. Note that input items may not be numbers, they can also be
% dependencies.
vout                    = cfg_dep;                        % The dependency object
vout.sname              = 'OCT.mat';            % Displayed dependency name
vout.src_output         = substruct('.','OCTmat'); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
