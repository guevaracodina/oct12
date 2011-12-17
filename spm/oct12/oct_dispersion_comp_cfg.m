function dispersion1 = oct_dispersion_comp_cfg
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

%%

enable2         = cfg_menu; % This is the generic data entry item
enable2.name    = 'Enable compensation'; % The displayed name
enable2.tag     = 'enable';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
enable2.labels = {'True','False'};       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
enable2.values = {1,0};     % Number of inputs required (2D-array with exactly one row and two column)
enable2.val = {1};
enable2.help    = {'Perform dispersion compensation.'}; % help text displayed

init_params1         = cfg_entry; % This is the generic data entry item
init_params1.name    = 'Initial parameters'; % The displayed name
init_params1.tag     = 'a';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
init_params1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
init_params1.num     = [1 2];     % Number of inputs required (2D-array with exactly one row and two column)
init_params1.val     = {[0 0]};
init_params1.help    = {'Dispersion polynomial initial parameters.'}; % help text displayed

    
%% Input Item
framenumbers1         = cfg_entry; % This is the generic data entry item
framenumbers1.name    = 'Frame numbers'; % The displayed name
framenumbers1.tag     = 'frames';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
framenumbers1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
framenumbers1.num     = [1 Inf];   % Number of inputs required (2D-array with exactly one row and two column)
framenumbers1.val     = {[1]};
framenumbers1.help    = {'Input vector containing frame numbers to use for compensation.','An average of compensation parameters will be performed.'}; % help text displayed

%% Executable Branch
dispersion1      = cfg_exbranch;                               % This is the branch that has information about how to run this module
dispersion1.name = 'Optimizes dispersion compensation';             % The display name
dispersion1.tag  = 'oct_dispersion_comp_cfg'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
dispersion1.val  = {OCTmat redo1 enable2 init_params1 framenumbers1};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
dispersion1.prog = @oct_dispersion_comp_run;  % A function handle that will be called with the harvested job to run the computation
dispersion1.vout = @oct_dispersion_comp_vout; % A function handle that will be called with the harvested job to determine virtual outputs
dispersion1.help = {'Choses a frame and optimizes dispersion compensation.'};

%% Local Functions
% For output dependency
function vout = oct_dispersion_comp_vout(job)
% Determine what outputs will be present if this job is run. In this case,
% the structure of the inputs is fixed, and the output is always a single
% number. Note that input items may not be numbers, they can also be
% dependencies.

vout = cfg_dep;                        % The dependency object
vout.sname      = 'OCT.mat';            % Displayed dependency name
vout.src_output = substruct('.','OCTmat'); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
