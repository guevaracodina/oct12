function basalCBF = oct_basal_CBF_cfg
% Graphical interface configuration function for oct_basal_CBF_run.
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

% Recompute
redo                    = cfg_menu; % This is the generic data entry item
redo.name               = 'Force Redo?'; % The displayed name
redo.tag                = 'redo';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
redo.labels             = {'No', 'Yes'};     % Number of inputs required (2D-array with exactly one row and two column)
redo.values             = {false, true};
redo.val                = {false};
redo.help               = {'This option will force recomputation.'}; % help text displayed

% Select directory to save global results
save_data_dir           = cfg_files;
save_data_dir.tag       = 'save_data_dir';
save_data_dir.name      = 'Directory to save group data';
save_data_dir.filter    = 'dir'; 
save_data_dir.num       = [1 1];
save_data_dir.help      = {'Select the directory where consolidated basal flow data will be saved'}';

% Save figures
save_figures            = cfg_menu; % This is the generic data entry item
save_figures.name       = 'Save pulsatility figures?'; % The displayed name
save_figures.tag        = 'save_figures';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
save_figures.labels     = {'No', 'Yes'};     % Number of inputs required (2D-array with exactly one row and two column)
save_figures.values     = {false, true};
save_figures.val        = {false};
save_figures.help       = {'This option will save basal CBF figures.'}; % help text displayed

% ------------------------------------------------------------------------------
% ID groups
% ------------------------------------------------------------------------------
% String identifying Control (NaCl) group [NC]
controlString               = cfg_entry;
controlString.name          = 'Control group ID';
controlString.tag           = 'controlString';       
controlString.strtype       = 's';
controlString.val           = {'NC'}; 
controlString.num           = [2 2];     
controlString.help          = {'String to identify Control Group.'}'; 

% String identifying treatment (CaCl2) group [CC]
treatmentString             = cfg_entry;
treatmentString.name        = 'Treatment group ID';
treatmentString.tag         = 'treatmentString';       
treatmentString.strtype     = 's';
treatmentString.val         = {'CC'}; 
treatmentString.num         = [2 2];     
treatmentString.help        = {'String to identify Treatment Group.'}'; 

% ID options
ID                          = cfg_branch;
ID.tag                      = 'ID';
ID.name                     = 'Groups ID';
ID.val                      = {controlString treatmentString};
ID.help                     = {'Strings to identify groups. If in doubt, simply keep the default values.'}';
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Print figure Options
% ------------------------------------------------------------------------------
% Figure size
figSize                 = cfg_entry;
figSize.tag             = 'figSize';
figSize.name            = 'Figure size';
figSize.strtype         = 'r';
figSize.num             = [1 2];
figSize.val{1}          = [2 2];
figSize.help            = {'Enter figure size in inches [Width Height].'};

% Figure resolution
figRes                  = cfg_entry;
figRes.tag              = 'figRes';
figRes.name             = 'Figure resolution';
figRes.strtype          = 'r';
figRes.num              = [1 1];
figRes.val{1}           = 300;
figRes.help             = {'Enter figure resolution in dpi. Suggested [150-1200]'};

% ------------------------------------------------------------------------------
% Axes & Title Font Sizes
% ------------------------------------------------------------------------------
% X-axis font size
xLabelFontSize          = cfg_entry;
xLabelFontSize.tag      = 'xLabelFontSize';
xLabelFontSize.name     = 'X-tick label font size';
xLabelFontSize.strtype  = 'r';
xLabelFontSize.num      = [1 1];
xLabelFontSize.val      = {12};
xLabelFontSize.help     = {'Enter X-tick label font size'};

% Y-axis font size
yLabelFontSize          = cfg_entry;
yLabelFontSize.tag      = 'yLabelFontSize';
yLabelFontSize.name     = 'Y axis label font size';
yLabelFontSize.strtype  = 'r';
yLabelFontSize.num      = [1 1];
yLabelFontSize.val      = {12};
yLabelFontSize.help     = {'Enter Y axis label font size'};

% Title font size
axisFontSize           = cfg_entry;
axisFontSize.tag       = 'axisFontSize';
axisFontSize.name      = 'Axis font size';
axisFontSize.strtype   = 'r';
axisFontSize.num       = [1 1];
axisFontSize.val       = {10};
axisFontSize.help      = {'Enter axes font size'};

% Title font size
titleFontSize           = cfg_entry;
titleFontSize.tag       = 'titleFontSize';
titleFontSize.name      = 'Title font size';
titleFontSize.strtype   = 'r';
titleFontSize.num       = [1 1];
titleFontSize.val       = {10};
titleFontSize.help      = {'Enter title font size'};

% ------------------------------------------------------------------------------
% Legends options
% ------------------------------------------------------------------------------
legendStr               = cfg_entry;
legendStr.tag           = 'legendStr';
legendStr.name          = 'Legend string';
legendStr.strtype       = 'e';
legendStr.num           = [1 2];
legendStr.val           = {{'NaCl' 'CaCl_2'}};
legendStr.help          = {'Enter legends. Default: {''NaCl'' ''CaCl_2''}'};

legendLocation          = cfg_entry;
legendLocation.tag      = 'legendLocation';
legendLocation.name     = 'Legend location';
legendLocation.strtype  = 's';
legendLocation.num      = [1 Inf];
legendLocation.val      = {'NorthWest'};
legendLocation.help     = {'Enter legend location'};

legendFontSize          = cfg_entry;
legendFontSize.tag      = 'legendFontSize';
legendFontSize.name     = 'Legend Font Size';
legendFontSize.strtype  = 'r';
legendFontSize.num      = [1 1];
legendFontSize.val      = {12};
legendFontSize.help     = {'Enter legend font size'};

legendShow              = cfg_branch;
legendShow.tag          = 'legendShow';
legendShow.name         = 'Show legend';
legendShow.val          = {legendStr legendLocation legendFontSize};
legendShow.help         = {'Show legends.'};

legendHide              = cfg_branch;
legendHide.tag          = 'legendHide';
legendHide.name         = 'Hide legend';
legendHide.val          = {};
legendHide.help         = {'Hide legends.'};

legends                 = cfg_choice;
legends.tag             = 'legends';
legends.name            = 'Legends options';
legends.values          = {legendShow legendHide};
legends.val             = {legendHide};
legends.help            = {'Choose whether to show legends or not'};
% ------------------------------------------------------------------------------

optFig                  = cfg_branch;
optFig.tag              = 'optFig';
optFig.name             = 'Print figure options';
optFig.val              = {figSize figRes xLabelFontSize yLabelFontSize axisFontSize titleFontSize legends};
optFig.help             = {'Print figure options. If in doubt, simply keep the default values.'}';
% ------------------------------------------------------------------------------

%% Executable Branch
basalCBF                = cfg_exbranch;         % This is the branch that has information about how to run this module
basalCBF.name           = 'Basal CBF';          % The display name
basalCBF.tag            = 'oct_basal_CBF_cfg';  % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
basalCBF.val            = {OCTmat redo save_data_dir ID save_figures optFig};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
basalCBF.prog           = @oct_basal_CBF_run;   % A function handle that will be called with the harvested job to run the computation
basalCBF.vout           = @oct_basal_CBF_vout;  % A function handle that will be called with the harvested job to determine virtual outputs
basalCBF.help           = {'Computes basal (quantitative in nL/s) cerebral blood flow (CBF) manually.'};

% For output dependency
function vout           = oct_basal_CBF_vout(job)
% Determine what outputs will be present if this job is run. In this case,
% the structure of the inputs is fixed, and the output is always a single
% number. Note that input items may not be numbers, they can also be
% dependencies.
vout                    = cfg_dep;                  % The dependency object
vout.sname              = 'OCT.mat';                % Displayed dependency name
vout.src_output         = substruct('.','OCTmat');  % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
