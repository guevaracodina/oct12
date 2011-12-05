function reconstruct1 = oct_doppler_cfg
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


%% Executable Branch
reconstruct1      = cfg_exbranch;                               % This is the branch that has information about how to run this module
reconstruct1.name = 'Filter reconstructed volume';  % The display name
reconstruct1.tag  = 'oct_filtervolume_cfg'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
reconstruct1.val  = {OCTmat};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
reconstruct1.prog = @oct_filtervolume_run;  % A function handle that will be called with the harvested job to run the computation
reconstruct1.vout = @oct_filtervolume_vout; % A function handle that will be called with the harvested job to determine virtual outputs
reconstruct1.help = {'Start from reconstructed data and generate new volume.'};

%% Local Functions
% For output dependency
function vout = oct_filtervolume_vout(job)
% Determine what outputs will be present if this job is run. In this case,
% the structure of the inputs is fixed, and the output is always a single
% number. Note that input items may not be numbers, they can also be
% dependencies.

vout = cfg_dep;                        % The dependency object
vout.sname      = 'OCT.mat';            % Displayed dependency name
vout.src_output = substruct('.','OCTmat'); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
