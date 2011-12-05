function reconstruct1 = oct_create_dicom_cfg
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

ref1         = cfg_menu; % This is the generic data entry item
ref1.name    = 'Convert structural scan?'; % The displayed name
ref1.tag     = 'do_struct';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
ref1.labels  = {'No', 'Yes'};     % Number of inputs required (2D-array with exactly one row and two column)
ref1.values  = {0,1};
ref1.val     = {0};
ref1.help    = {'This option will either convert the volume or do nothing.'}; % help text displayed

ref2         = cfg_menu; % This is the generic data entry item
ref2.name    = 'Convert Doppler scan?'; % The displayed name
ref2.tag     = 'do_doppler';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
ref2.labels  = {'No', 'Yes'};     % Number of inputs required (2D-array with exactly one row and two column)
ref2.values  = {0,1};
ref2.val     = {0};
ref2.help    = {'This option will either convert the volume or do nothing.'}; % help text displayed

ref3         = cfg_menu; % This is the generic data entry item
ref3.name    = 'Convert ECG Gated scan?'; % The displayed name
ref3.tag     = 'do_ecg';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
ref3.labels  = {'No', 'Yes'};     % Number of inputs required (2D-array with exactly one row and two column)
ref3.values  = {0,1};
ref3.val     = {0};
ref3.help    = {'This option will either convert the volume or do nothing.'}; % help text displayed

%% Executable Branch
reconstruct1      = cfg_exbranch;                               % This is the branch that has information about how to run this module
reconstruct1.name = 'Create DICOM volume from reconstructions';  % The display name
reconstruct1.tag  = 'oct_create_dicom_cfg'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
reconstruct1.val  = {OCTmat ref1 ref2 ref3};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
reconstruct1.prog = @oct_create_dicom_run;  % A function handle that will be called with the harvested job to run the computation
reconstruct1.vout = @oct_create_dicom_vout; % A function handle that will be called with the harvested job to determine virtual outputs
reconstruct1.help = {'Start from reconstructed data and generate new DICOM volume. The new volume will be saved in a subfolder dicom/'};

%% Local Functions
% For output dependency
function vout = oct_create_dicom_vout(job)
% Determine what outputs will be present if this job is run. In this case,
% the structure of the inputs is fixed, and the output is always a single
% number. Note that input items may not be numbers, they can also be
% dependencies.

vout = cfg_dep;                        % The dependency object
vout.sname      = 'OCT.mat';            % Displayed dependency name
vout.src_output = substruct('.','OCTmat'); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
