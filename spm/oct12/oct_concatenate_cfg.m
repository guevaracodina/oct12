function concatenate1 = oct_concatenate_cfg
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

%Select top directory of data
top_data_dir         = cfg_files;
top_data_dir.tag     = 'input_data_topdir';
top_data_dir.name    = 'Top directory of raw data';
top_data_dir.filter = 'dir'; 
top_data_dir.num     = [1 1];
top_data_dir.help    = {'Select the directory at the top of the tree of the raw data.'}';

%Select directory to save global results
output_data_dir         = cfg_files;
output_data_dir.tag     = 'output_data_dir';
output_data_dir.name    = 'Top directory to save group data';
output_data_dir.filter = 'dir'; 
output_data_dir.num     = [1 1];
output_data_dir.help    = {'Select the directory where consolidated results will be saved using the same directory tree as the raw data.'}';

%% Executable Branch
concatenate1      = cfg_exbranch;                               % This is the branch that has information about how to run this module
concatenate1.name = 'Concatenate acqui info files';             % The display name
concatenate1.tag  = 'oct_concatenate_cfg'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
concatenate1.val  = {OCTmat redo1 top_data_dir output_data_dir};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
concatenate1.prog = @oct_concatenate_run;  % A function handle that will be called with the harvested job to run the computation
concatenate1.vout = @oct_concatenate_vout; % A function handle that will be called with the harvested job to determine virtual outputs
concatenate1.help = {'Takes acquisition info saved by the OCT system and converts them to a single file.'};

%% Local Functions
% For output dependency
function vout = oct_concatenate_vout(job)
% Determine what outputs will be present if this job is run. In this case,
% the structure of the inputs is fixed, and the output is always a single
% number. Note that input items may not be numbers, they can also be
% dependencies.

vout = cfg_dep;                        % The dependency object
vout.sname      = 'OCT.mat';            % Displayed dependency name
vout.src_output = substruct('.','OCTmat'); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
