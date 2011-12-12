function out = oct_ecg_pulsatility_run(job)
% At this point, the folder contains a list of dat and mat files
% respectively containing acquisition information and data. This module
% will concatenate the acquisition info.

rev = '$Rev$'; %#ok

% Reference from previous computation.
OCTmat=job.OCTmat;

% Loop over acquisitions
for acquisition=1:size(OCTmat,2)
    
    load(OCTmat{acquisition});
    % This reconstruction only works if the ECG data is recorded and we
    % have a 2D ramp type
    if( OCT.acqui_info.ramp_type == 1)
        
        % Reconstruction paramters to save in recons_info structure.
        acqui_info=OCT.acqui_info;
        recons_info = OCT.recons_info;
        
        %% Initialize 3D volume and average grid, it is a handle class to be able to pass across functions
        vol=C_OCTVolume(recons_info.size);
        vol.openint16(recons_info.ecg_recons.filename);
        % put image of first frame
        figure(99);
        load doppler_color_map.mat
        colormap(doppler_color_map);
        e=imagesc(squeeze(vol.data(:,:,1)));
        mask = roipoly;
       
        vessel_time_course=zeros(1,size(vol.data,3));
        for i=1:size(vol.data,3)
            tmp=squeeze(vol.data(:,:,i));
            vessel_time_course(i) = mean(tmp(mask));
        end
        recons_info.ecg_recons.vessel.time_course=vessel_time_course;
        
        OCT.acqui_info=acqui_info;
        OCT.recons_info=recons_info;
        save([OCT.input_dir, filesep, 'OCT.mat'],'OCT');
    end
end
if ishandle(wb);close(wb);drawnow;end
out.OCTmat = OCTmat;
end


