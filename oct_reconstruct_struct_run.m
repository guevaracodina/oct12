function out = oct_reconstruct_struct_run(job)
% At this point, the folder contains a list of dat and mat files
% respectively containing acquisition information and data. This module
% will concatenate the acquisition info.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

rev = '$Rev$'; %#ok

% Reference from previous computation.
OCTmat=job.OCTmat;
wb=waitbar(0,'');
% Loop over acquisitions
for acquisition=1:size(OCTmat,1)
    try %//EGC
        load(OCTmat{acquisition});
        if ~isfield(OCT.jobsdone,'structural') || job.redo
            acqui_info=OCT.acqui_info;
            recons_info = OCT.recons_info;
            % Parameters for structural reconstructions
            recons_info.struct_recons.self_ref = job.self_ref;
            
            
            %FrameData is a cell with dimensions of number of files in the acquisition
            [FrameData]=map_dat_file(acqui_info);
            total_frames=acqui_info.nframes*acqui_info.nfiles;
            
            % In this case we reconstruct every frame
            if (job.gate==0)
                recons_info.size(3)=total_frames;
            end
            
            wavenumbers=wavelengths2wavenumbers(acqui_info.wavelengths);
            
            %% Initialize 3D volumes, it is a handle class to be able to pass across functions
            vol=C_OCTVolume(recons_info.size);
            ave_grid = zeros(size(vol.data,1),size(vol.data,3));
            % Pour decompte des cycles cardiaques, pas vraiment pour la recons
            %No_of_A_lines=zeros(recons_info.size(1),recons_info.size(3));
            
            %% This is the timer used for the waitbar time remaining estimation
            ETA_text='Starting reconstruction';
            
            for i_frame=1:total_frames;
                
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
                    if i_frame==1
                        % Display message only the first frame //EGC
                        fprintf([waitbarmessage{1} '\n']);
                    end
                else
                    if i_frame==1
                        % Display message only the first frame //EGC
                        disp(waitbarmessage);
                    end
                end
                % END GUI PART
                
                frame=squeeze(FrameData{current_file}.Data.frames(:,:,local_frame_number));
                [m,n,o]=size(frame);
                frame=reshape(frame,m,n*o);
                
                % Frame to gamma fait la FFT
                [gamma_abs,gamma_angle]=frame2gamma(frame,acqui_info.reference,wavenumbers,recons_info, recons_info.struct_recons.self_ref);
                frame_struct=10*log(gamma_abs);
                
                current_position=squeeze(recons_info.A_line_position(:,i_frame,:));
                
                % ECG gating reconstruction code
                if(job.gate == 1)
                    % Sometimes current A-line position is greater than N ECG gates
                    % //EGC
                    if any( current_position(:,2) > OCT.recons_info.number_of_time_gates)
                        fprintf('Error in frame %d, %s\nA-line position greater than %d\n',...
                            i_frame, acqui_info.base_filename, OCT.recons_info.number_of_time_gates)
                        % Take former position
                        current_position(:,2) = squeeze(recons_info.A_line_position(:,i_frame-1,2));
                    end
                    
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
                else
                    % Normal reconstruction code
                    vol.data(:,:,i_frame) = frame_struct';
                end
                
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
            
            % renormalize for images that are gated
            if( job.gate == 1)
                % Renorm by number of average, apply filter to avoid zeros
                ave_grid = reshape(ave_grid,[size(ave_grid,1) 1 size(ave_grid,2)]);
                ave_filter=ones(3,3,3)/9;
                vol.data = imfilter(vol.data,ave_filter,'circular','same') ./ ...
                imfilter(repmat(ave_grid,[1 size(vol.data,2)]),ave_filter,'circular','same');
            end

            %Saving to disk
            [tmp_dir, tmp_fnm]=fileparts(acqui_info.filename);
            vol.set_maxmin(max(vol.data(:)),min(vol.data(:)));
            vol.data=(vol.data-min(vol.data(:)))/(max(vol.data(:))-min(vol.data(:)))*double(intmax('int16'));
            vol.saveint16(fullfile(OCT.output_dir,[tmp_fnm,'.struct3D']));
            
            recons_info.date=date;
            recons_info.struct_recons.filename=fullfile(OCT.output_dir,[tmp_fnm,'.struct3D']);
            OCT.acqui_info=acqui_info;
            OCT.recons_info=recons_info;
            OCT.jobsdone.structural = 1;
            save(fullfile(OCT.output_dir, 'OCT.mat'),'OCT');
        end
    catch exception % //EGC
        disp(exception.identifier)
        disp(exception.stack(1))
        out.OCTmat{acquisition} = job.OCTmat{acquisition};
    end
end % Acquisitions loop
if ishandle(wb);close(wb);drawnow;end
out.OCTmat = OCTmat;
end

% EOF
