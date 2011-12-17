function ecg_pulse1 = oct_ecg_pulsatility_cfg
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
ref1.name    = 'Save pulsatility figures?'; % The displayed name
ref1.tag     = 'save_figures';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
ref1.labels  = {'No', 'Yes'};     % Number of inputs required (2D-array with exactly one row and two column)
ref1.values  = {0,1};
ref1.val     = {0};
ref1.help    = {'This option will save ROI pulse figures.'}; % help text displayed

%Select directory to save global results
save_data_dir         = cfg_files;
save_data_dir.tag     = 'pulse_data_dir';
save_data_dir.name    = 'Directory to save group data';
save_data_dir.filter = 'dir'; 
save_data_dir.num     = [1];
save_data_dir.help    = {'Select the directory where consolidated pulsatility data will be saved'}';

%% Executable Branch
ecg_pulse1      = cfg_exbranch;                               % This is the branch that has information about how to run this module
ecg_pulse1.name = 'ROI ECG pulsatility';             % The display name
ecg_pulse1.tag  = 'oct_ecg_doppler_cfg'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
ecg_pulse1.val  = {OCTmat ref1 save_data_dir};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
ecg_pulse1.prog = @oct_ecg_pulsatility_run;  % A function handle that will be called with the harvested job to run the computation
ecg_pulse1.vout = @oct_ecg_pulsatility_vout; % A function handle that will be called with the harvested job to determine virtual outputs
ecg_pulse1.help = {'User selects ROIs and this function computes pulsatility.'};

%% Local Functions
% For output dependency
function vout = oct_ecg_pulsatility_vout(job)
% Determine what outputs will be present if this job is run. In this case,
% the structure of the inputs is fixed, and the output is always a single
% number. Note that input items may not be numbers, they can also be
% dependencies.

vout = cfg_dep;                        % The dependency object
vout.sname      = 'OCT.mat';            % Displayed dependency name
vout.src_output = substruct('.','OCTmat'); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
