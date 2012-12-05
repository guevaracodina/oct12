function reconstruct1 = oct_reconstruct_struct_cfg
% Example script that creates an cfg_exbranch to sum two numbers. The
% inputs are entered as two single numbers, the output is just a single
% number.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id$

rev = '$Rev$'; %#ok

%% Input Items
OCTmat         = cfg_files; %Select NIRS.mat for this subject 
OCTmat.name    = 'OCT.mat'; % The displayed name
OCTmat.tag     = 'OCTmat';       %file names
OCTmat.filter  = 'mat';
OCTmat.ufilter = '^OCT.mat$';    
OCTmat.num     = [1 Inf];     % Number of inputs required 
OCTmat.help    = {'Select OCT.mat for the scan.'}; % help text displayed

redo1         = cfg_menu; % This is the generic data entry item
redo1.name    = 'Force Redo?'; % The displayed name
redo1.tag     = 'redo';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
redo1.labels  = {'No', 'Yes'};     % Number of inputs required (2D-array with exactly one row and two column)
redo1.values  = {0,1};
redo1.val     = {0};
redo1.help    = {'This option will force recomputation.'}; % help text displayed

gate1         = cfg_menu; % This is the generic data entry item
gate1.name    = 'ECG gate?'; % The displayed name
gate1.tag     = 'gate';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
gate1.labels  = {'No', 'Yes'};     % Number of inputs required (2D-array with exactly one row and two column)
gate1.values  = {0,1};
gate1.val     = {0};
gate1.help    = {'This option will either average the structural over ECG gates or reconstruct the base structure.'}; % help text displayed

ref1         = cfg_menu; % This is the generic data entry item
ref1.name    = 'Which signal to use as reference?'; % The displayed name
ref1.tag     = 'self_ref';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
ref1.labels  = {'Measured Reference', 'Reference from mean frame'};     % Number of inputs required (2D-array with exactly one row and two column)
ref1.values  = {0,1};
ref1.val     = {0};
ref1.help    = {'This option will set which reference is used (measured or mean of each frame).'}; % help text displayed


%% Executable Branch
reconstruct1      = cfg_exbranch;                               % This is the branch that has information about how to run this module
reconstruct1.name = 'Reconstruct structural';             % The display name
reconstruct1.tag  = 'oct_reconstruct_struct_cfg'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
reconstruct1.val  = {OCTmat redo1 gate1 ref1};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
reconstruct1.prog = @oct_reconstruct_struct_run;  % A function handle that will be called with the harvested job to run the computation
reconstruct1.vout = @oct_reconstruct_struct_vout; % A function handle that will be called with the harvested job to determine virtual outputs
reconstruct1.help = {'Start from preprocessed data and reconstructs structural acquisition.'};

%% Local Functions
% For output dependency
function vout = oct_reconstruct_struct_vout(job)
% Determine what outputs will be present if this job is run. In this case,
% the structure of the inputs is fixed, and the output is always a single
% number. Note that input items may not be numbers, they can also be
% dependencies.

vout = cfg_dep;                        % The dependency object
vout.sname      = 'OCT.mat';            % Displayed dependency name
vout.src_output = substruct('.','OCTmat'); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
