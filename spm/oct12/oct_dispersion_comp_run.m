function out = oct_dispersion_comp_run(job)
% At this point, the folder contains a list of dat and mat files
% respectively containing acquisition information and data. This module
% will dispersion_comp the acquisition info.

rev = '$Rev$'; %#ok

% Reference from previous computation.
OCTmat=job.OCTmat;

% Loop over acquisitions
for acquisition=1:size(OCTmat,1)
    load(OCTmat{acquisition});
    
    if( ~isfield(OCT.jobsdone,'dispersion_comp') || redo )
        try
            % Dispersion compensation parameters
            recons_info.dispersion.a=job.a;
            recons_info.dispersion.compensate=job.enable;
            % Base info to access frames
            wavenumbers=wavelengths2wavenumbers(OCT.acqui_info.wavelengths);
            [FrameData]=map_dat_file(OCT.acqui_info);
            type_of_acquisition=OCT.acqui_info.ramp_type;
            total_frames=OCT.acqui_info.nframes*OCT.acqui_info.nfiles;
             
            % Loop over frames to compensate
            dispersion_vec = [];
            for i=1:length(job.frames)
                current_frame = job.frames(i);
                current_file=ceil(current_frame/OCT.acqui_info.nframes);
                local_frame_number=current_frame-(current_file-1)*OCT.acqui_info.nframes;
                switch OCT.acqui_info.ramp_type
                    case 6
                        slice_first_frame=1+OCT.acqui_info.HD_info.framesperslice*...
                            floor((local_frame_number-1)/OCT.acqui_info.HD_info.framesperslice);
                        slice_last_frame=slice_first_frame-1+...
                            OCT.acqui_info.HD_info.framesperslice;
                        frame_range=local_frame_number-kernel_frame_overlap:...
                            local_frame_number+kernel_frame_overlap;
                        frame_range=frame_range(frame_range>=slice_first_frame);
                        frame_range=frame_range(frame_range<=slice_last_frame);
                    otherwise
                        frame_range=local_frame_number;
                end
                
                if frame_range>0
                    frame=squeeze(FrameData{current_file}.Data.frames(:,:,frame_range));
                    [m,n,o]=size(frame);
                    frame=reshape(frame,m,n*o);
                    tmp = find_dispersion_parameters(frame,OCT.acqui_info.reference,wavenumbers,OCT.recons_info.dispersion);
                    dispersion_vec = [dispersion_vec; tmp.a];
                end
            end
            OCT.recons_info.dispersion.a=mean(dispersion_vec,1);
            figure;hist(dispersion_vec);
            OCT.jobsdone.dispersion_comp=1;
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

function [dispersion]= find_dispersion_parameters(frame,reference,wavenumbers,dispersion)
% This function will optimize dispersion compensation on the input frame
frame=double(frame);
[m,n]=size(frame);

%% Remove the reference
ref_2D=repmat(reference,[1 n]);
frame=(frame-ref_2D)./ref_2D;

%% Interpolate the data on the wavenumber space
frame=interp1(wavenumbers.pixels,frame,wavenumbers.linear,'linear'); %I tried to use interp1q, but this is faster

%% This will apply a hanning window to the Fourier data
frame=frame.*repmat(hann(m),[1 n]);

%% This is the step that will implement dispersion compensation
% frame_before_dispersion=abs(ifft(frame,[],1));
% figure(1);subplot(2,1,1);imagesc(frame_before_dispersion(50:200,:))
% title('Frame before dispersion compensation');pause(0.01)
dispersion.a = fminsearch(@(a) dispersion_optimization(frame,wavenumbers,a),dispersion.a);
end

function [M]=dispersion_optimization(frame,wavenumbers,a)
% This calculates the contrast of the image and returns M, the lower the
% value of M, the higher the contrast is.
[frame]=dispersion_compensation(frame,wavenumbers,a);

frame=ifft(frame,[],1);

frame_of_interest=abs(frame);
derivative=abs(diff(frame_of_interest));
M=1/sum(sum(derivative));
end
