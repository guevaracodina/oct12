function out = oct_doppler_run(job)
% Computes the Doppler image of any scan and keeps geometry as is (i.e.
% need to verify for repetitive scans but will keep last position only)

rev = '$Rev$'; %#ok

% Reference from previous computation.
OCTmat=job.OCTmat;
wb=waitbar(0,'');
% Loop over acquisitions
for acquisition=1:size(OCTmat,1)
    
    load(OCTmat{acquisition});
    
    % Reconstruction paramters to save in recons_info structure.
    acqui_info=OCT.acqui_info;
    recons_info = OCT.recons_info;
    recons_info.dop_recons.kernel_sigma=job.doppler_params.kernel_sigma;
    recons_info.dop_recons.self_ref=job.doppler_params.self_ref;
    recons_info.dop_recons.bulk_phase_correction = job.doppler_params.bulk_phase_correction;
    recons_info.dop_recons.zwindow = job.doppler_params.z_window;
    recons_info.dop_recons.rwindow = job.doppler_params.r_window;
    window=ones(recons_info.dop_recons.zwindow,recons_info.dop_recons.rwindow);
    window=window/(sum(window(:)));
    
    load doppler_color_map.mat;
    
    %FrameData is a cell with dimensions of number of files in the acquisition
    [FrameData]=map_dat_file(acqui_info);
    total_frames=acqui_info.nframes*acqui_info.nfiles;
    
    % Kernel for high pass filtering of doppler data
    filter_kernel=design_filter_kernel(recons_info.dop_recons.kernel_sigma,acqui_info.line_period_us*1e-6);
    
    % Interpolation wavenumbers
    wavenumbers=wavelengths2wavenumbers(acqui_info.wavelengths);
    
    %% Initialize 3D volumes, it is a handle class to be able to pass across functions
    vol=C_OCTVolume(recons_info.size);
    ave_grid = zeros(size(vol.data,1),size(vol.data,3));        
    
    %% This is the timer used for the waitbar time remaining estimation
    ETA_text='Starting reconstruction';
    
    for i_frame=1:acqui_info.nframes;
        if i_frame>size(recons_info.A_line_position,2)
            warning('Requested frame number exceeds number of frames, please verify')
            keyboard
        end
        if i_frame==2
            tic
        end
        
        current_file=ceil(i_frame/acqui_info.nframes);
        local_frame_number=i_frame-(current_file-1)*acqui_info.nframes;
        
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
        
       
        frame=squeeze(FrameData{current_file}.Data.frames(:,:,local_frame_number));
        [m,n,o]=size(frame);
        frame=reshape(frame,m,n*o);
        
        % Frame to gamma fait la FFT
        [gamma_abs,gamma_angle]=...
            frame2gamma(frame,acqui_info.reference,wavenumbers,recons_info, recons_info.dop_recons.self_ref);
        current_frame = gamma_abs.*exp(1i*gamma_angle);
        
        % Bulk phase correction for whole slice
        if( recons_info.dop_recons.bulk_phase_correction )
            a=current_frame(:,1:end-1).*conj(current_frame(:,2:end));
            % Look for acceleration of this
            phi=angle(sum(a,1));
            for i=1:length(phi)
                current_frame(:,i+1)=current_frame(:,i+1)*exp(1i*phi(i));
            end
        end
        
        use_fft = 0;
        if use_fft
            OPTIONS.GPU = 0;
            OPTIONS.Power2Flag = 0;
            current_frame_hpf = convnfft(current_frame, repmat(filter_kernel,size(current_frame,1),1), 'same', 2,OPTIONS);
        else
            current_frame_hpf = conv2(current_frame,filter_kernel,'same');
        end
        
        %%%
        A=current_frame_hpf(:,1:end-1).*conj(current_frame_hpf(:,2:end));
        
        % This is to reduce noise (H. Ren 2006), a implementer, code vivek
        window=double(window);
        if use_fft
            OPTIONS.Brep = 0;
            A_conv = convnfft(A,window,'same',1:2,OPTIONS);
        else
            A_conv=convn(A,window,'same');
        end
        
        % Unwrapping of data (not stable in noisy regions)
        doppler_angle=angle(A_conv);
        doppler_angle_unwrapped=unwrap(doppler_angle);
        difference=sum(doppler_angle_unwrapped~=doppler_angle);
        positions_to_unwrap=find(difference~=0);
        
        %This is a more careful way of unwrapping that makes sure the operation
        %is done in both directions
        for i=positions_to_unwrap
            doppler_angle(:,i)=unwrap_single_line(doppler_angle(:,i));
        end
        
        %This will give the result file the same dimension as the input file
        doppler_angle=[doppler_angle(:,1) doppler_angle/2]...
            +[doppler_angle/2 doppler_angle(:,end)];
        
        %This function will place the frames inside the Structure and
        %Doppler global variables based on their position declared in
        %the A_line_position variable
        current_position=squeeze(recons_info.A_line_position(:,i_frame,:));
        
        
        % Do operations in linear space for speed.
        ii=repmat(current_position(:,1),[1 size(vol.data,2)])';
        ii=ii(:);
        jj=repmat([1:size(vol.data,2)]',[size(doppler_angle,2) 1]);
        kk=repmat(current_position(:,2),[1 size(vol.data,2)])';
        kk=kk(:);
        ind1=double(sub2ind(size(vol.data),double(ii),double(jj),double(kk)));
        ind2=double(sub2ind(size(ave_grid),current_position(:,1),current_position(:,2)));
        vol.data(ind1) = vol.data(ind1)+doppler_angle(:);
        ave_grid(ind2) = ave_grid(ind2)+1;
        
        
        if i_frame==1
            % The first frame takes longer to execute, therefore the
            % time it takes to complete is not used to estimate the
            % remaining time
            tic
        else
            time=toc;
            ETA_text=get_ETA_text(time,i_frame-1,total_frames-1);
        end
        
    end
    % Images now reconstructed, renorm volume since we averaged over scans
    ave_grid = reshape(ave_grid,[size(ave_grid,1) 1 size(ave_grid,2)]);
    vol.data = vol.data ./ repmat(ave_grid,[1 size(vol.data,2)]);
    wavelength=870e-6; %Wavelength in mm
    vol.data=vol.data*wavelength/(4*pi)/acqui_info.line_period_us/1e-6;
    vol.data=vol.data/2; %This is the correction factor determined by the test on the fantom
    
    [tmp_dir, tmp_fnm]=fileparts(acqui_info.filename);
    vol.set_maxmin(max(vol.data(:)),min(vol.data(:)));
    vol.data=(vol.data)/(max(vol.data(:))-min(vol.data(:)))*double(intmax('int16'));
    vol.saveint16(fullfile(OCT.output_dir,[tmp_fnm,'.dopl3D']));
    
    recons_info.date=date;
    recons_info.dop_recons.filename=fullfile(OCT.output_dir,[tmp_fnm,'.dopl3D']);
    OCT.acqui_info=acqui_info;
    OCT.recons_info=recons_info;
    save(fullfile(OCT.output_dir, 'OCT.mat'),'OCT');
end
if ishandle(wb);close(wb);drawnow;end
out.OCTmat = OCTmat;
end


