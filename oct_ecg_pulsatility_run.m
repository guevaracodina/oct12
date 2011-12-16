function out = oct_ecg_pulsatility_run(job)
% At this point, the folder contains a list of dat and mat files
% respectively containing acquisition information and data. This module
% will concatenate the acquisition info.

rev = '$Rev$'; %#ok

% Reference from previous computation.
OCTmat=job.OCTmat;

% Loop over acquisitions

fid = fopen('F:\OCT\Aging\vessel.txt', 'w');
fprintf(fid,'Name, Mean, Median, Std, Max, Min\n');

for acquisition=1:size(OCTmat,1)
    try
    load(OCTmat{acquisition});
    % This reconstruction only works if the ECG data is recorded and we
    % have a 2D ramp type
    if( OCT.acqui_info.ramp_type == 1)
        
        % Reconstruction paramters to save in recons_info structure.
        acqui_info=OCT.acqui_info;
        recons_info = OCT.recons_info;
        
        %% Initialize 3D volume and average grid, it is a handle class to be able to pass across functions
        vol=C_OCTVolume(recons_info.size);
        cd(OCT.input_dir)
        a=dir('*.dopl3Dt');
        vol.openint16(a.name);
        %vol.openint16(recons_info.ecg_recons.filename);
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
        figure(100);plot(vessel_time_course);
        recons_info.ecg_recons.vessel.time_course=vessel_time_course;
        fprintf(fid, '%s , %6.4f , %6.4f , %6.4f , %6.4f , %6.4f\n', OCT.acqui_info.base_filename, mean(vessel_time_course),...
        median(vessel_time_course),std(vessel_time_course),max(vessel_time_course),min(vessel_time_course));
        OCT.acqui_info=acqui_info;
        OCT.recons_info=recons_info;
        save([OCT.input_dir, filesep, 'OCT.mat'],'OCT');
    end
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.OCTmat{acquisition} = job.OCTmat{acquisition};
    end
end
fclose(fid);
out.OCTmat = OCTmat;
end


