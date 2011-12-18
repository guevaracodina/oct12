function out = oct_angiogram_run(job)
% At this point, the folder contains a list of dat and mat files
% respectively containing acquisition information and data. This module
% will concatenate the acquisition info.

rev = '$Rev$'; %#ok

% Reference from previous computation.
OCTmat=job.OCTmat;

wb=waitbar(0,'');
% Loop over acquisitions of type HD only, this module will do nothing on
% the others
for acquisition=1:size(OCTmat,1)
    load(OCTmat{acquisition});
    acqui_info=OCT.acqui_info;
    if (acqui_info.ramp_type == 6)
        recons_info = OCT.recons_info;
        
        % Angio paramters
        recons_info.angio.kernel_sigma=job.dop_params.kernel_sigma;
        recons_info.angio.zwindow=job.dop_params.zwindow;
        recons_info.angio.rwindow=job.dop_params.rwindow;
        recons_info.angio.self_ref = job.self_ref;
        
        %FrameData is a cell with dimensions of number of files in the acquisition
        [FrameData]=map_dat_file(acqui_info);
        total_frames=acqui_info.nframes*acqui_info.nfiles;
        
        % Kernel for high pass filtering of doppler data
        filter_kernel=design_filter_kernel(recons_info.angio.kernel_sigma,...
            acqui_info.line_period_us*1e-6);
        wavenumbers=wavelengths2wavenumbers(acqui_info.wavelengths);
        
        %% Initialize 3D volumes, it is a handle class to be able to pass across functions
        vol=C_OCTVolume(recons_info.size);
        lp_vol=C_OCTVolume(recons_info.size);
        
        %% This is the timer used for the waitbar time remaining estimation
        ETA_text='Starting angiogram reconstruction';
        
        i_frame = 1;
        i_slice=1;
        current_frame=[];
        while (i_frame<=total_frames)
            if i_frame>size(recons_info.A_line_position,2)
                warning('Requested frame number exceeds number of frames, please verify')
                keyboard
            end
            if i_frame==2
                tic
            end
            % GUI PART
            waitbarmessage={['Acq. ' num2str(acquisition) ' of '...
                num2str(size(OCTmat,1)) ' : ' acqui_info.base_filename...
                ' with ' num2str(acqui_info.nfiles) ' files'];...
                [ETA_text  ', Frame ' num2str(i_frame) ' of '...
                num2str(total_frames) ', ' num2str(round(100*i_frame/total_frames))...
                '%']};
            if ishandle(wb);waitbar(i_frame/total_frames,wb,waitbarmessage);
            else;disp(waitbarmessage);end
            % END GUI PART
            
            % Read frames one by one, fft and concatenate in one slice
            current_file=ceil(i_frame/acqui_info.nframes);
            local_frame_number=i_frame-(current_file-1)*acqui_info.nframes;
            frame=squeeze(FrameData{current_file}.Data.frames(:,:,local_frame_number));
            [m,n,o]=size(frame);
            frame=reshape(frame,m,n*o);
            
            % Frame to gamma fait la FFT
            [gamma_abs,gamma_angle]=...
                frame2gamma(frame,acqui_info.reference,wavenumbers,recons_info, recons_info.angio.self_ref);
            subset = gamma_abs.*exp(1i*gamma_angle);
            current_frame=[current_frame, subset];
            
            % Only filter when we have concatenated all slices
            if(mod(i_frame,acqui_info.HD_info.framesperslice)==0)
                
                % Bulk phase correction for whole slice
                a=current_frame(:,1:end-1).*conj(current_frame(:,2:end));
                % Look for acceleration of this
                phi=angle(sum(a,1));
                for i=1:length(phi)
                    current_frame(:,i+1)=current_frame(:,i+1)*exp(1i*phi(i));
                end
                
                % Then do resampling
                
                % Filter and create hpf and lpf image
                use_fft = 0;
                if use_fft
                    OPTIONS.GPU = 0;
                    OPTIONS.Power2Flag = 0;
                    current_frame_hpf = abs(convnfft(current_frame, repmat(filter_kernel,size(current_frame,1),1), 'same', 2,OPTIONS));
                else
                    current_frame_hpf = abs(conv2(current_frame,filter_kernel,'same'));
                end
                if use_fft
                    OPTIONS.GPU = 0;
                    OPTIONS.Power2Flag = 0;
                    current_frame_lpf = abs(convnfft(current_frame, repmat(ones(size(filter_kernel)),[length(current_frame) 1]), 'same', 2,OPTIONS));
                else
                    current_frame_lpf=abs(conv2(current_frame,ones(size(filter_kernel)),'same'));
                end
                % Resample data so that it is of decent size, need to
                % correct for non-linear sampling later
                current_frame_hpf_t = convn(current_frame_hpf,ones(size(filter_kernel)),'same');
                dimx=size(current_frame_hpf_t(:,1:round(length(filter_kernel)/2):end),2);
                vol.data(1:dimx,:,i_slice) = current_frame_hpf_t(:,1:round(length(filter_kernel)/2):end)';
                current_frame_lpf_t = convn(current_frame_lpf,ones(size(filter_kernel)),'same');
                lp_vol.data(1:dimx,:,i_slice)=current_frame_lpf_t(:,1:round(length(filter_kernel)/2):end)';
                i_slice = i_slice+1
                current_frame=[];
            end
            
            if i_frame==1
                tic
            else
                time=toc;
                ETA_text=get_ETA_text(time,i_frame-1,total_frames-1);
            end
            i_frame = i_frame+1;
        end
        % Images now reconstructed
        [tmp_dir, tmp_fnm]=fileparts(acqui_info.filename);
        vol.set_maxmin(max(vol.data(:)),min(vol.data(:)));
        vol.data=(vol.data-min(vol.data(:)))/(max(vol.data(:))-min(vol.data(:)))*double(intmax('int16'));
        vol.saveint16(fullfile(OCT.output_dir,[tmp_fnm,'.dopl3D']));
        
        lp_vol.set_maxmin(max(lp_vol.data(:)),min(lp_vol.data(:)));
        lp_vol.data=(lp_vol.data-min(lp_vol.data(:)))/(max(lp_vol.data(:))-min(lp_vol.data(:)))*double(intmax('int16'));
        lp_vol.saveint16(fullfile(OCT.output_dir,[tmp_fnm,'.dopl3D_LP']));
        
        recons_info.angio_recons.filename=fullfile(OCT.output_dir,[tmp_fnm,'.dopl3D']);
        recons_info.angio_recons.filename_lp=fullfile(OCT.output_dir,[tmp_fnm,'.dopl3D_LP']);
        
        recons_info.date=date;
        OCT.acqui_info=acqui_info;
        OCT.recons_info=recons_info;
        save([OCT.input_dir, filesep, 'OCT.mat'],'OCT');
        if ishandle(wb);close(wb);drawnow;end
    else
        disp([OCTmat{acquisition}, ': Wrong acquisition type for angiograms, data ignored for this scan.'])
    end
end

out.OCTmat = OCTmat;
end


