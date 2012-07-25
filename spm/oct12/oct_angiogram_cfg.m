function reconstruct1 = oct_angiogram_cfg
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

%% Input Items for doppler
sigma2         = cfg_entry; % This is the generic data entry item
sigma2.name    = 'Kernel sigma'; % The displayed name
sigma2.tag     = 'kernel_sigma';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
sigma2.strtype = 'r';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
sigma2.num     = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
sigma2.val     = {1e-3};
sigma2.help    = {'Kernel std deviation in s.'}; % help text displayed

zwin2         = cfg_entry; % This is the generic data entry item
zwin2.name    = 'Z window size'; % The displayed name
zwin2.tag     = 'zwindow';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
zwin2.strtype = 'r';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
zwin2.num     = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
zwin2.val    = {15};
zwin2.help    = {'Z window extent for Doppler.'}; % help text displayed

rwin2         = cfg_entry; % This is the generic data entry item
rwin2.name    = 'R window size'; % The displayed name
rwin2.tag     = 'rwindow';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
rwin2.strtype = 'r';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
rwin2.num     = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
rwin2.val     = {15};
rwin2.help    = {'R window extent for doppler.'}; % help text displayed

dop1         = cfg_branch;
dop1.tag     = 'dop_params';
dop1.name    = 'Doppler Processing Parameters';
dop1.val     = {sigma2 zwin2 rwin2};
dop1.help    = {'Parameters for Doppler processing, '
    'pools all values necessary for further processing. '}';

%% Processing type

ref1         = cfg_menu; % This is the generic data entry item
ref1.name    = 'Which signal to use as reference?'; % The displayed name
ref1.tag     = 'self_ref';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
ref1.labels  = {'Measured Reference', 'Reference from mean frame'};     % Number of inputs required (2D-array with exactly one row and two column)
ref1.values  = {0,1};
ref1.val     = {0};
ref1.help    = {'This option will set which reference is used (measured or mean of each frame).'}; % help text displayed

%% Executable Branch
reconstruct1      = cfg_exbranch;                 % This is the branch that has information about how to run this module
reconstruct1.name = 'Reconstruct angiogram';     % The display name
reconstruct1.tag  = 'oct_angiogram_cfg'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
reconstruct1.val  = {OCTmat dop1 ref1};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
reconstruct1.prog = @oct_angiogram_run;  % A function handle that will be called with the harvested job to run the computation
reconstruct1.vout = @oct_angiogram_vout; % A function handle that will be called with the harvested job to determine virtual outputs
reconstruct1.help = {'Start from preprocessed data and reconstructs structural acquisition.'};

%% Local Functions
% For output dependency
function vout = oct_angiogram_vout(job)
% Determine what outputs will be present if this job is run. In this case,
% the structure of the inputs is fixed, and the output is always a single
% number. Note that input items may not be numbers, they can also be
% dependencies.

vout = cfg_dep;                        % The dependency object
vout.sname      = 'OCT.mat';            % Displayed dependency name
vout.src_output = substruct('.','OCTmat'); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
