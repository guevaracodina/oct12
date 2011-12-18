function out = oct_filtervolume_run(job)
% At this point, the folder contains a list of dat and mat files
% respectively containing acquisition information and data. This module
% will concatenate the acquisition info.

rev = '$Rev$'; %#ok

% Reference from previous computation.
OCTmat=job.OCTmat;
wb=waitbar(0,'');
% Loop over acquisitions
for acquisition=1:size(OCTmat,1)
    
    load(OCTmat{acquisition});
    recons_info = OCT.recons_info;

    Hstruct3D=fopen(filename,'r');
    vol=fread(Hstruct3D, inf,'int16');
    fclose(Hstruct3D);

    sizex=length(vol)/(512*400);
    vol=reshape(vol,[sizex 512 400]);

    OCT.recons_info=recons_info;
    save(fullfile(OCT.output_dir, 'OCT.mat'),'OCT');
end

out.OCTmat = OCTmat;
end


