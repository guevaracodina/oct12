function diameter1 = oct_diameter_vessel_cfg
% Graphical interface configuration function for oct_diameter_vessel_run.
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

% Select directory to save global results
save_data_dir           = cfg_files;
save_data_dir.tag       = 'save_data_dir';
save_data_dir.name      = 'Directory to save group data';
save_data_dir.filter    = 'dir'; 
save_data_dir.num       = [1 1];
save_data_dir.help      = {'Select the directory where consolidated vessel diameters data will be saved'}';

%% Executable Branch
diameter1               = cfg_exbranch;       % This is the branch that has information about how to run this module
diameter1.name          = 'Vessel diameter';             % The display name
diameter1.tag           = 'oct_diameter_vessel_cfg'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
diameter1.val           = {OCTmat save_data_dir};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
diameter1.prog          = @oct_diameter_vessel_run;  % A function handle that will be called with the harvested job to run the computation
diameter1.vout          = @oct_diameter_vessel_vout; % A function handle that will be called with the harvested job to determine virtual outputs
diameter1.help          = {'Computes vessel diameter manually.'};

%% Local Functions
% For output dependency
function vout           = oct_diameter_vessel_vout(job)
% Determine what outputs will be present if this job is run. In this case,
% the structure of the inputs is fixed, and the output is always a single
% number. Note that input items may not be numbers, they can also be
% dependencies.
vout                    = cfg_dep;                        % The dependency object
vout.sname              = 'OCT.mat';            % Displayed dependency name
vout.src_output         = substruct('.','OCTmat'); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
