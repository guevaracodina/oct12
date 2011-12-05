function convert1 = oct_convert_bin2mat_cfg
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
input1         = cfg_files; 
input1.name    = 'Select directories containing bin files to process'; 
input1.tag     = 'rawdata_dir';       %directory names
input1.filter = 'dir';   
input1.ufilter = '.*';    
input1.num     = [1 Inf];     % Number of inputs required 
input1.help    = {'Select directories containing raw bin data files to be converted for this experiment.'}; % help text displayed



%% Executable Branch
convert1      = cfg_exbranch;       % This is the branch that has information about how to run this module
convert1.name = 'Convert Binary files';             % The display name
convert1.tag  = 'oct_convert_bin2mat_cfg'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
convert1.val  = {input1};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
convert1.prog = @oct_convert_bin2mat_run;  % A function handle that will be called with the harvested job to run the computation
convert1.vout = @oct_convert_bin2mat_vout; % A function handle that will be called with the harvested job to determine virtual outputs
convert1.help = {'Takes binary files saved by the OCT system in LabView and converts them to a format readable by matlab.'};

%% Local Functions
% For output dependency
function vout = oct_convert_bin2mat_vout(job)
% Determine what outputs will be present if this job is run. In this case,
% the structure of the inputs is fixed, and the output is always a single
% number. Note that input items may not be numbers, they can also be
% dependencies.
vout = cfg_dep;                        % The dependency object
vout.sname      = 'OCT.mat';            % Displayed dependency name
vout.src_output = substruct('.','OCTmat'); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
