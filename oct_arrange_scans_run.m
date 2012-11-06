function out = oct_arrange_scans_run(job)
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

tic
OCTmat={};
for iDirs = 1:size(job.rawdata_dir,1)
    try
        dataFolder = job.rawdata_dir{iDirs};
        chooseSubjectDir = job.chooseSubjectDir;
        oct_arrange_scans_multi(dataFolder, chooseSubjectDir);
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
    end
end
disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')]);
out.OCTmat = OCTmat';

% EOF
