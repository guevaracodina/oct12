function cfg = cfg_oct_processing
% Master file that collects all OCT processing
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2011 Laboratoire d'Imagerie Optique et Moleculaire

% F Lesage
% $Id$

rev = '$Rev$'; %#ok

% Sets up the different modules, each module will have its own menu in the
% batch interface so that they will be organized logically

%% Modules to perform pre-processing of oct data
preproc        = cfg_repeat; % A repeat collects a variable number of items from its .values field in its .val field
preproc.name   = 'Preprocessing';
preproc.tag    = 'preproc';
preproc.values = {oct_convert_bin2mat_cfg oct_concatenate_cfg}; % Config files for all preprocessing modules
preproc.forcestruct = true; % There is a speciality in cfg_repeat harvest behaviour that makes a difference depending on the number of elements in values. forcestruct == true forces the repeat to behave as if there are more than one distinct values, even if there is only one.
preproc.help   = {'All functions used for data preprocessing are collected in this module'};

%% Modules to process the OCT per-se
proc        = cfg_repeat;
proc.name   = 'Image Processing';
proc.tag    = 'proc';
proc.values = {oct_define_geometry_cfg oct_dispersion_comp_cfg oct_reconstruct_struct_cfg oct_doppler_cfg oct_angiogram_cfg oct_ecg_doppler_cfg};
proc.forcestruct = true;
proc.help   = {'Processing of images.'};

%% Modules to export images
export        = cfg_repeat;
export.name   = 'Image Export';
export.tag    = 'export';
export.values = {oct_create_dicom_cfg};
export.forcestruct = true;
export.help   = {'Image export.'};


%% Collect above Collections
cfg        = cfg_repeat;
cfg.name   = 'OCT';
cfg.tag    = 'cfg_oct';
cfg.values = {preproc proc export}; % Values in a cfg_repeat can be any cfg_item objects
cfg.forcestruct = true;
cfg.help   = {'Full oct processing pipeline'};