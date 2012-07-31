function out = oct_reconstruct_struct_run(job)
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
    acqui_info=OCT.acqui_info;
    recons_info = OCT.recons_info;
    % Parameters for structural reconstructions
    recons_info.struct_recons.self_ref = job.self_ref;
    
    %FrameData is a cell with dimensions of number of files in the acquisition
    [FrameData]=map_dat_file(acqui_info);
    total_frames=acqui_info.nframes*acqui_info.nfiles;
    
    wavenumbers=wavelengths2wavenumbers(acqui_info.wavelengths);
    
    %% Initialize 3D volumes, it is a handle class to be able to pass across functions
    vol=C_OCTVolume(recons_info.size);
    ave_grid = zeros(size(vol.data,1),size(vol.data,3));
    % Pour decompte des cycles cardiaques, pas vraiment pour la recons
    %No_of_A_lines=zeros(recons_info.size(1),recons_info.size(3));
    
    %% This is the timer used for the waitbar time remaining estimation
    ETA_text='Starting reconstruction';
    
    for i_frame=1:400 %total_frames;
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
            fprintf([waitbarmessage{1} '\n']);
        else disp(waitbarmessage);end
        % END GUI PART
        
        frame=squeeze(FrameData{current_file}.Data.frames(:,:,local_frame_number));
        [m,n,o]=size(frame);
        frame=reshape(frame,m,n*o);
        
        % Frame to gamma fait la FFT
        [gamma_abs,gamma_angle]=frame2gamma(frame,acqui_info.reference,wavenumbers,recons_info, recons_info.struct_recons.self_ref);
        frame_struct=10*log(gamma_abs);
        
        current_position=squeeze(recons_info.A_line_position(:,i_frame,:));
        
        % Do operations in linear space for speed.
        ii=repmat(current_position(:,1),[1 size(vol.data,2)])';
        ii=ii(:);
        jj=repmat([1:size(vol.data,2)]',[size(frame_struct,2) 1]);
        kk=repmat(current_position(:,2),[1 size(vol.data,2)])';
        kk=round(kk(:));
        ind1=double(sub2ind(size(vol.data),double(ii),double(jj),double(kk)));
        ind2=double(sub2ind(size(ave_grid),round(current_position(:,1)),round(current_position(:,2))));
        vol.data(ind1) = frame_struct;
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
    % Images now reconstructed
    
    %Saving to disk
    [tmp_dir, tmp_fnm]=fileparts(acqui_info.filename);
    vol.set_maxmin(max(vol.data(:)),min(vol.data(:)));
    vol.data=(vol.data-min(vol.data(:)))/(max(vol.data(:))-min(vol.data(:)))*double(intmax('int16'));
    vol.saveint16(fullfile(OCT.output_dir,[tmp_fnm,'.struct3D']));
    
    recons_info.date=date;
    recons_info.struct_recons.filename=fullfile(OCT.output_dir,[tmp_fnm,'.struct3D']);
    OCT.acqui_info=acqui_info;
    OCT.recons_info=recons_info;
    save(fullfile(OCT.output_dir, 'OCT.mat'),'OCT');
end
if ishandle(wb);close(wb);drawnow;end
out.OCTmat = OCTmat;
end


