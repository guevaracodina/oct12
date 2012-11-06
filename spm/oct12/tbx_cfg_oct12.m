function oct12 = tbx_cfg_oct12
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

addpath(fileparts(which(mfilename)));

%-------------------------------------------------------------------------------
oct12        = cfg_choice;
oct12.name   = 'oct12';
oct12.tag    = 'oct12'; % Careful, this tag oct12 must be the same as the name of
                        % the toolbox and when called by spm_jobman in oct12.m
oct12.values = {cfg_oct_processing}; 

% EOF
