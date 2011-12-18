function out = oct_define_geometry_run(job)
% This is a module to simply define parameters that will be used in
% reconstruction

rev = '$Rev$'; %#ok

% Reference from previous computation.
OCTmat=job.OCTmat;

% Loop over acquisitions
for acquisition=1:size(OCTmat,1)
    load(OCTmat{acquisition});
    if( ~isfield(OCT.jobsdone,'define_geometry') || job.redo )
        try
            % At this point we only have acqui_info in this matrix, here we define
            % the reconstruction information 
           
            acqui_info=OCT.acqui_info;
            
            %Mask, move to later in post-processing
            recons_info.mask_prop.surface=job.mask_params.surface;
            recons_info.mask_prop.enable=job.mask_params.enable;
            recons_info.mask_prop.noise_lower_fraction=job.mask_params.noise_lower;
            recons_info.mask_prop.threshold_db=job.mask_params.threshold_db;
            recons_info.mask_prop.blur_window=ones(job.mask_params.blur_window);
            
            % Default is no dispersion compensation
            recons_info.dispersion_enable = 0;
            
            % Define reconstruction geometry
            type_of_acquisition=acqui_info.ramp_type;
            recons_info.A_line_position=single(zeros(acqui_info.resolution,acqui_info.nframes*acqui_info.nfiles,2));
            
            switch type_of_acquisition
                case 1 %In case of a 2Dt acquisition
                    if acqui_info.ecg==1 %If the ecg signal is valid and we want to reconstruct using it.
                        recons_info.number_of_time_gates=job.n_gates;
                        [gate_position,recons_info.dt_us]=...
                            segment_2Dtime(acqui_info,recons_info.number_of_time_gates);
                        
                        recons_info.A_line_position(:,:,2)=...
                            gate_position(1:acqui_info.resolution,...
                            1:acqui_info.nframes*acqui_info.nfiles);
                        
                    else % If there is no ECG signal then the frame is reconstructed as it was acquired.
                        % If there is multiple files they will be added to one another.
                        for i=1:acqui_info.nfiles
                            recons_info.A_line_position(:,...
                                (i-1)*acqui_info.nframes+(1:acqui_info.nframes),2)=...
                                ones(acqui_info.resolution,1)*(1:acqui_info.nframes);
                        end
                    end
                    
                    for i=1:acqui_info.resolution
                        recons_info.A_line_position(i,:,1)=i*ones(acqui_info.nframes*acqui_info.nfiles,1);
                    end
                    
                case 4 %In case of a 3D acquisition
                    if isfield(acqui_info,'line_shift')
                        line_shift=acqui_info.line_shift;
                    else
                        line_shift=0;
                    end
                    %keyboard
                    position_dim_1(:,:,1)=(line_shift+(1:acqui_info.resolution))'*ones(1,acqui_info.nframes);
                    overlapped=find((line_shift+(1:acqui_info.resolution))>acqui_info.ramp_length);
                    position_dim_1(overlapped,:,1)=position_dim_1(overlapped,:,1)-acqui_info.ramp_length;
                    
                    position_dim_1(:,:,2)=((acqui_info.resolution:-1:1)-line_shift)'*ones(1,acqui_info.nframes);
                    underlapped=find(((acqui_info.resolution:-1:1)-line_shift)<0);
                    position_dim_1(underlapped,:,2)=position_dim_1(underlapped,:,2)+acqui_info.ramp_length;
                    
                    position_dim_3(:,:,1)=ones(1,acqui_info.resolution)'*(1:acqui_info.nframes);
                    position_dim_3(:,:,2)=ones(1,acqui_info.resolution)'*(acqui_info.nframes:-1:1);
                    
                    for file=1:acqui_info.nfiles
                        current_frames=(file-1)*acqui_info.nframes+(1:acqui_info.nframes);
                        if acqui_info.rev_fast_axis;oddoreven=2-rem(file,2);else;oddoreven=1;end
                        recons_info.A_line_position(:,current_frames,1)=position_dim_1(:,:,oddoreven);
                        recons_info.A_line_position(:,current_frames,2)=position_dim_3(:,:,oddoreven);
                    end
                case 6 %In case of a 3D HD acquisition
                    ramp=linspace(1,acqui_info.x_FOV_um,...
                        (acqui_info.HD_info.framesperslice-1)*acqui_info.resolution);
                    position_X=[(reshape(ramp,acqui_info.resolution,(acqui_info.HD_info.framesperslice-1))) -1*ones(acqui_info.resolution,1)];
                    for slice=1:acqui_info.HD_info.slicesperfile*acqui_info.nfiles;
                        current_frames=(slice-1)*acqui_info.HD_info.framesperslice+(1:acqui_info.HD_info.framesperslice);
                        recons_info.A_line_position(:,current_frames,1)=position_X;
                        recons_info.A_line_position(:,current_frames,2)=slice;
                    end
            end
            
            dimensions=define_dimensions(acqui_info,recons_info);
            
            % This will define all the dimensions of the result matrix
            recons_info.size=[dimensions{1}.size dimensions{2}.size dimensions{3}.size];
            recons_info.step=[dimensions{1}.FOV/dimensions{1}.size...
                dimensions{2}.FOV/dimensions{2}.size...
                dimensions{3}.FOV/dimensions{3}.size];
            
            recons_info.type={dimensions{1}.type dimensions{2}.type dimensions{3}.type};
            recons_info.units={dimensions{1}.units dimensions{2}.units dimensions{3}.units};
            
            OCT.recons_info = recons_info;
            OCT.jobsdone.define_geometry=1;
            save(fullfile(OCT.output_dir, 'OCT.mat'),'OCT');
        catch exception
            disp(exception.identifier)
            disp(exception.stack(1))
            out.OCTmat{acquisition} = job.OCTmat{acquisition};
        end
    end
end

out.OCTmat = OCTmat;
end


