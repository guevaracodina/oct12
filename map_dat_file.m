function [FrameData,acqui_info]=map_dat_file(acqui_info)
% This function will generate the memmapfile handle for a .dat file

% The size of the data in the dat file is now stored in only one variable
% in the acqui_info structure. This if will ensure backwards compatibility
% while at the same time updating the acqui_info files to include this new
% simple variable

if ~isfield(acqui_info,'dat_size');
    if isfield(acqui_info,'full_frame');
        if acqui_info.full_frame==1
            width=acqui_info.ramp_length;
        else
            width=acqui_info.resolution;
        end
    else
        width=acqui_info.resolution;
    end
    acqui_info.dat_size=[acqui_info.frame_depth width acqui_info.nframes];
    resave_acqui_info;
end

if isfield(acqui_info,'nfiles')
    fileList = dir([acqui_info.filename '*.mat']); % //EGC
    for file_number=1:acqui_info.nfiles
        start_frame=(file_number-1)*acqui_info.nframes+acqui_info.framenumber(1);
        % Read start frame of each file //EGC
        [start_idx, end_idx, extents, matches] = regexp(fileList(file_number).name,'[0-9]+.mat');
        start_frame_file = str2double(matches{1}(1:end-4));
        if start_frame ~= start_frame_file,
            % Some files of the same scan do not have consecutive naming,
            % need to verify this quick fix //EGC
            start_frame = start_frame_file;
        end

        FrameData{file_number}=memmapfile([acqui_info.filename '-' num2str(start_frame) '.dat'],...
            'Format',{'int16' acqui_info.dat_size 'frames'});
    end
else
    FrameData=memmapfile([acqui_info.filename '.dat'],...
        'Format',{'int16' acqui_info.dat_size 'frames'});
end
