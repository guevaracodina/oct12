function ecg_recons1 = oct_ecg_doppler_cfg
%
% ECG-gated doppler reconstruction.
%_______________________________________________________________________


rev = '$Rev$'; 

%% Input Items
OCTmat         = cfg_files; %Select NIRS.mat for this subject 
OCTmat.name    = 'OCT.mat'; % The displayed name
OCTmat.tag     = 'OCTmat';       %file names
OCTmat.filter  = 'mat';
OCTmat.ufilter = '^OCT.mat$';    
OCTmat.num     = [1 Inf];     % Number of inputs required 
OCTmat.help    = {'Select OCT.mat for the scan.'}; % help text displayed

ref1         = cfg_menu; % This is the generic data entry item
ref1.name    = 'Which signal to use as reference?'; % The displayed name
ref1.tag     = 'self_ref';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
ref1.labels  = {'Measured Reference', 'Reference from mean frame'};     % Number of inputs required (2D-array with exactly one row and two column)
ref1.values  = {0,1};
ref1.val     = {0};
ref1.help    = {'This option will set which reference is used (measured or mean of each frame).'}; % help text displayed

bulk1         = cfg_menu; % This is the generic data entry item
bulk1.name    = 'Bulk phase correction?'; % The displayed name
bulk1.tag     = 'bulk_phase_correction';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
bulk1.labels  = {'Do not correct', 'Correct for bulk phase'};     % Number of inputs required (2D-array with exactly one row and two column)
bulk1.values  = {0,1};
bulk1.val     = {0};
bulk1.help    = {'This option will decide whether data is corrected for the bulk phase in each frame.'}; % help text displayed

sigma2         = cfg_entry; % This is the generic data entry item
sigma2.name    = 'Kernel sigma'; % The displayed name
sigma2.tag     = 'kernel_sigma';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
sigma2.strtype = 'r';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
sigma2.num     = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
sigma2.val     = {1e-3};
sigma2.help    = {'Kernel std deviation in s.'}; % help text displayed

zwin1         = cfg_entry; % This is the generic data entry item
zwin1.name    = 'Z window extent'; % The displayed name
zwin1.tag     = 'z_window';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
zwin1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
zwin1.num     = [1 1];   % Number of inputs required (3D-array with exactly one row and three column)
zwin1.val     = {10};
zwin1.help    = {'Extent of the window used in the z (depth) direction for doppler processing.'}; % help text displayed

rwin1         = cfg_entry; % This is the generic data entry item
rwin1.name    = 'R window extent'; % The displayed name
rwin1.tag     = 'r_window';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
rwin1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
rwin1.num     = [1 1];   % Number of inputs required (3D-array with exactly one row and three column)
rwin1.val     = {10};
rwin1.help    = {'This is the extent of the window in the scan (r) direction for doppler processing.'}; % help text displayed

dop1         = cfg_branch;
dop1.tag     = 'doppler_params';
dop1.name    = 'Doppler Processing Parameters';
dop1.val     = {sigma2 zwin1 rwin1 ref1 bulk1};
dop1.help    = {'Parameters for Doppler processing, '
    'pools all values necessary for processing. '}';

%% Executable Branch
ecg_recons1      = cfg_exbranch;                               % This is the branch that has information about how to run this module
ecg_recons1.name = 'Reconstruct ecg-gated doppler';             % The display name
ecg_recons1.tag  = 'oct_ecg_doppler_cfg'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
ecg_recons1.val  = {OCTmat dop1};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
ecg_recons1.prog = @oct_ecg_doppler_run;  % A function handle that will be called with the harvested job to run the computation
ecg_recons1.vout = @oct_ecg_doppler_vout; % A function handle that will be called with the harvested job to determine virtual outputs
ecg_recons1.help = {'Start from preprocessed data and reconstructs Doppler images gated by ECG.'};

%% Local Functions
% For output dependency
function vout = oct_ecg_doppler_vout(job)
% Determine what outputs will be present if this job is run. In this case,
% the structure of the inputs is fixed, and the output is always a single
% number. Note that input items may not be numbers, they can also be
% dependencies.

vout = cfg_dep;                        % The dependency object
vout.sname      = 'OCT.mat';            % Displayed dependency name
vout.src_output = substruct('.','OCTmat'); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
