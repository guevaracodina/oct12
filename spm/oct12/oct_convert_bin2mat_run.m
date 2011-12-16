function out = oct_convert_bin2mat_run(job)
% Function that converts all files in the directory path to .dat files
% which are memmap versions of the data. A choice was made to do this in
% place so that no copy of the data is done.

rev = '$Rev$'; 

% This function will convert all the .bin files in a directory to the .dat
% and .mat standard. After this, we don't need to rerun since no data is
% lost. However the dir below will eliminate any rerun if the batch was
% called again.
OCTmat={};

for dir_index = 1:size(job.rawdata_dir,1)
    
    directory=job.rawdata_dir{dir_index}; 
    OCT.input_dir=directory;
   
    % If already converted, this will run fast
    disp(['Converting bin files'])
    
    %This will process the files in the specified directory
    n_files=0;
    clear filenames
    current_folder=dir(directory);
    for j=1:length(current_folder)
        if strfind(current_folder(j).name,'.bin')
            n_files=n_files+1;
            filenames{n_files}=current_folder(j).name;
        end
    end
    if n_files>0
        [conv_info]=Process_bin2dat(filenames,[directory filesep]);
    else
        conv_info=0;
    end

    OCT.conv_info=conv_info;
    OCT.jobsdone.bin2mat=1;
    save([OCT.input_dir, 'OCT.mat'],'OCT');
    OCTmat{dir_index}=[OCT.input_dir,'OCT.mat'];
end
out.OCTmat = OCTmat';

function [conversion_info]=Process_bin2dat(filenames,path);
%This function will take a .bin file and transfer the data to a .dat and
%the acquisition acqui_info to a .mat file. It will also trim the data to
%remove the galvo return A-lines.

if ~isequal(filenames,0)    
    for i=1:length(filenames)
        [current_path, current_filename, ext]=fileparts([path filenames{i}]);
        assignin('base','current_filename',current_filename)
        
        Hbin=fopen([current_path filesep current_filename '.bin']);
        file_info=dir([current_path filesep current_filename '.bin']);
        
        acqui_info.date=file_info.date;
        acqui_info=read_bin_header(Hbin,acqui_info);
        
        file_size=file_info.bytes;
        
        acqui_info.nframes=fread(Hbin,1,'int16');
        acqui_info.framenumber(1)=fread(Hbin,1,'int16');
        size_frame=fread(Hbin,4,'int16');
        acqui_info.ramp_length=size_frame(1);
        
        if ~isfield(acqui_info,'resolution')
            acqui_info.resolution=acqui_info.ramp_length*8/9;
        end
        
        acqui_info.frame_depth=size_frame(3);
        
        currentprogress=1/acqui_info.nframes;
        nframes_string=num2str(acqui_info.nframes);
        
        % Open the .dat file
        acqui_info.filename=[current_path filesep current_filename];
        Hdat=fopen([acqui_info.filename '.dat'],'w');
        
        if acqui_info.version>3;
            acqui_info.ecg_signal=int16(zeros(acqui_info.ramp_length,acqui_info.nframes));
        end
        if acqui_info.version>=6&&acqui_info.electrophysio
            acqui_info.electrophysio_0=int16(zeros(acqui_info.ramp_length,acqui_info.nframes));
            acqui_info.electrophysio_1=int16(zeros(acqui_info.ramp_length,acqui_info.nframes));
        end
        
        
        %This section will rewrite the data in the bin file to a new .dat file that
        %only contains the frame Data
        
        wb=waitbar(currentprogress,['Extracting bin file : '...
            num2str(round(currentprogress*100)) '% of ' nframes_string ' frames']);
        
        tic;
        timeperiteration=0;
        
        for j=1:acqui_info.nframes
            pos(j)=ftell(Hbin);
            if j==3
                frame_data_size_bytes=pos(end)-pos(end-1);
                estimated_file_size=ftell(Hbin)+(acqui_info.nframes-(j-1))*frame_data_size_bytes;
                file_size;
                if estimated_file_size~=file_size;
                    break
                end
            end
            
            if j>1
                acqui_info.framenumber(j)=fread(Hbin,1,'int16');
                currentprogress=j/acqui_info.nframes;
                if length(filenames)>1
                    waitbar_text_line1=['Extracting ' current_filename '.bin (' num2str(i) ' of ' num2str(length(filenames)) ')'];
                else
                    waitbar_text_line1=['Extracting ' current_filename '.bin'];
                end
                
                waitbar_text={waitbar_text_line1;...
                    [num2str(round(currentprogress*100)) '% of ' nframes_string ' frames, ETA : '...
                    num2str(round(timeperiteration*(acqui_info.nframes-j))) ' s']};
                
                waitbar(currentprogress,wb,waitbar_text);
                size_frame=fread(Hbin,4,'int16');
            end
            
            frame=fread(Hbin,acqui_info.ramp_length*acqui_info.frame_depth,'int16');
            
            frame=reshape(frame,acqui_info.frame_depth,acqui_info.ramp_length);
            if acqui_info.version>1
                if findstr(acqui_info.filename,'3D HD');acqui_info.ramp_type=6;end
                if acqui_info.ramp_type==6
                    % For 3D HD acquisitions, we want to keep the extra A-lines
                    % taken when the scan is stationnary because it contains
                    % Doppler information.
                    fwrite(Hdat,frame,'int16');
                    acqui_info.full_frame=1;
                    acqui_info.dat_size=[acqui_info.frame_depth acqui_info.ramp_length acqui_info.nframes];
                else
                    %This will remove the A-lines taken on the galvo return and write the
                    %new Data to a .dat file
                    fwrite(Hdat,frame(:,1:acqui_info.resolution),'int16');
                    acqui_info.full_frame=0;
                    acqui_info.dat_size=[acqui_info.frame_depth acqui_info.resolution acqui_info.nframes];
                end
            end
            
            if acqui_info.version>3
                if acqui_info.ecg;
                    acqui_info.ecg_signal(:,j)=fread(Hbin,acqui_info.ramp_length,'int16');
                end
            end
            if acqui_info.version>=6
                if acqui_info.electrophysio
                    acqui_info.electrophysio_0(:,j)=fread(Hbin,acqui_info.ramp_length,'int16');
                    acqui_info.electrophysio_1(:,j)=fread(Hbin,acqui_info.ramp_length,'int16');
                end
            end
            totaltime=toc;
            timeperiteration=totaltime/j;
            
        end
        
        close(wb);
        fclose(Hbin);
        fclose(Hdat);
        
        if estimated_file_size==file_size
            save(acqui_info.filename,'acqui_info')
            disp(['Transfer of ' current_filename '.bin successful'])
            delete([current_path filesep current_filename '.bin'])
        else
            disp(['Transfer of ' current_filename '.bin failed, file removed'])
            if exist([current_path filesep current_filename '.dat']);delete([current_path filesep current_filename '.dat']);end
        end
    end
    conversion_info=[num2str(length(filenames)) ' files extracted in ' path];

else
    conversion_info=0;
end