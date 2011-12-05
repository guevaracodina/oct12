function param3dhd1 = oct_define_geometry_cfg
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


%% Input Items for display mask
surface1         = cfg_entry; % This is the generic data entry item
surface1.name    = 'Mask surface prop'; % The displayed name
surface1.tag     = 'surface';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
surface1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
surface1.num     = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
surface1.val     = {1};
surface1.help    = {'Mask parameter.'}; % help text displayed

enable1         = cfg_menu; % This is the generic data entry item
enable1.name    = 'Enable masking'; % The displayed name
enable1.tag     = 'enable';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
enable1.labels = {'True','False'};       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
enable1.values = {1,0};     % Number of inputs required (2D-array with exactly one row and two column)
enable1.val = {0};
enable1.help    = {'Mask parameters.'}; % help text displayed

noise_lower1         = cfg_entry; % This is the generic data entry item
noise_lower1.name    = 'Lower noise mask threshold'; % The displayed name
noise_lower1.tag     = 'noise_lower';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
noise_lower1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
noise_lower1.num     = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
noise_lower1.val     = {0.1};
noise_lower1.help    = {'Mask parameter.'}; % help text displayed

threshold_db1         = cfg_entry; % This is the generic data entry item
threshold_db1.name    = 'Threshold db'; % The displayed name
threshold_db1.tag     = 'threshold_db';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
threshold_db1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
threshold_db1.num     = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
threshold_db1.val     ={17};
threshold_db1.help    = {'Mask parameters.'}; % help text displayed

blur_window1         = cfg_entry; % This is the generic data entry item
blur_window1.name    = 'Blur window size (pixels)'; % The displayed name
blur_window1.tag     = 'blur_window';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
blur_window1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
blur_window1.num     = [1 2];  
blur_window1.val     = {[10 10]};% Number of inputs required (2D-array with exactly one row and two column)
blur_window1.help    = {'Mask parameters.'}; % help text displayed

mask1         = cfg_branch;
mask1.tag     = 'mask_params';
mask1.name    = 'Image Mask Parameters';
mask1.val     = {enable1 surface1 noise_lower1 threshold_db1 blur_window1};
mask1.help    = {'Parameters for image masking'}';


n_gates         = cfg_entry; % This is the generic data entry item
n_gates.name    = 'N Gates'; % The displayed name
n_gates.tag     = 'n_gates';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
n_gates.strtype = 'r';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
n_gates.num     = [1 1];   % Number of inputs required (3D-array with exactly one row and three column)
n_gates.val     = {100};
n_gates.help    = {'Number of gates over which the signal will be reconstructed if ECG gated acquisition.'}; % help text displayed

%% Executable Branch
param3dhd1      = cfg_exbranch;                               % This is the branch that has information about how to run this module
param3dhd1.name = 'Parameter definition for 3DHD reconstructions';             % The display name
param3dhd1.tag  = 'oct_define_3DHD_parameters_cfg'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
param3dhd1.val  = {OCTmat mask1 n_gates};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
param3dhd1.prog = @oct_define_geometry_run;  % A function handle that will be called with the harvested job to run the computation
param3dhd1.vout = @oct_define_geometry_vout; % A function handle that will be called with the harvested job to determine virtual outputs
param3dhd1.help = {'Define geometry parameters for reconstruction.'};

%% Local Functions
% For output dependency
function vout = oct_define_geometry_vout(job)
% Determine what outputs will be present if this job is run. In this case,
% the structure of the inputs is fixed, and the output is always a single
% number. Note that input items may not be numbers, they can also be
% dependencies.

vout = cfg_dep;                        % The dependency object
vout.sname      = 'OCT.mat';            % Displayed dependency name
vout.src_output = substruct('.','OCTmat'); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
