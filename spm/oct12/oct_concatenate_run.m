function out = oct_concatenate_run(job)
% At this point, the folder contains a list of dat and mat files
% respectively containing acquisition information and data. This module
% will concatenate the acquisition info.

rev = '$Rev$'; %#ok

% Reference from previous computation.
OCTmat=job.OCTmat;

% Loop over acquisitions
for acquisition=1:size(OCTmat,1)
    
    load(OCTmat{acquisition});
    
    if( ~isfield(OCT.jobsdone,'concatenate') || job.redo )
        % Create the output data tree if necessary, also use when creating
        % more than one result tree
        OCT.top_input_data_dir=job.input_data_topdir{1};
        dirlen=size(OCT.top_input_data_dir,2);
        [pathstr, temp]=fileparts(OCTmat{acquisition});
        OCT.output_dir = fullfile(job.output_data_dir{1},pathstr(dirlen+1:end));
        if ~exist(OCT.output_dir,'dir'),mkdir(OCT.output_dir);end
        
        % This function will take the path to the first file of an acquisition and
        % determine how many files are part of the acquisition and concatenate all
        % the information into only one acqui_info file
        % If the work is done, then the dir below will give zero and nothing is
        % done.
        acquifiles = dir([OCT.input_dir,'*0.mat']);
        if (length(acquifiles)>0)
            filename_first_file=acquifiles(1).name;
            
            % Loads first acqui_info
            load([OCT.input_dir filename_first_file])
            
            % Strip extension
            [pathname_temp,filename_temp,ext]=fileparts([OCT.input_dir filename_first_file]);
            acqui_info.filename=[pathname_temp filesep filename_temp];
            
            % This will verify that the properties that are written in the
            % acqui_info structure correspond to the  actual properties of the
            % acquisition
            type=identifity_acquisition_type(filename_temp);
            if findstr(filename_temp,'Coupe selon');acqui_info.ramp_type=1;end
            if findstr(filename_temp,'3D rev fast axis');acqui_info.ramp_type=4;end
            if findstr(filename_temp,'3D HD');acqui_info.ramp_type=6;end
            if findstr(filename_temp,'Fantom');acqui_info.ecg=0;end
            
            if acqui_info.ecg==1&&~isfield(acqui_info,'bpm')&&isfield(acqui_info,'ecg_signal')
                [temp,acqui_info.bpm]=Find_ECG_peaks(acqui_info,0);
            end
            
            %This will clean up the FOV values to make sure everything is round to
            %the um
            acqui_info=check_FOV(acqui_info);
            
            switch acqui_info.ramp_type
                case 4
                    if ~isfield(acqui_info,'rev_fast_axis')
                        if findstr(filename_temp,'3D rev fast axis')
                            acqui_info.rev_fast_axis=1;
                        else
                            acqui_info.rev_fast_axis=0;
                        end
                    end
                case 6
                    if ~isfield(acqui_info,'HD_info')
                        acqui_info.HD_info.slicesperfile=10;
                        acqui_info.HD_info.framesperslice=40;
                    end
            end
            
            % This will determine the base_filename that will be used to find the other
            % files of the acquisition
            first_frame=acqui_info.framenumber(1);
            base_filename=regexprep(filename_first_file,[num2str(first_frame) '.mat'],'');
            acq_files=dir([OCT.input_dir base_filename,'*.mat']);
            base_filename_clean=clean_base_filename(base_filename);
            
            % This declares a new acqui_info for the complete acquisition,
            % remove ecg that will be concatenated below.
            acqui_info_all=acqui_info;
            if (acqui_info.version>3 && isfield(acqui_info_all,'ecg_signal'))
                acqui_info_all=rmfield(acqui_info_all,'ecg_signal');
            end
            % Add names that will be used for the concatenated acqui_info file
            acqui_info_all.filename=[OCT.input_dir base_filename_clean];
            acqui_info_all.base_filename=base_filename;
            acqui_info_all.nfiles=length(acq_files);
            
            % Load each file, add ECGs and move to Backup.
            for i=1:length(acq_files)
                load([OCT.input_dir, acq_files(i).name]);
                if (acqui_info.version>3 && isfield(acqui_info,'ecg_signal'))
                    % We also concatenate all the ecg information into the
                    % acqui_info_all structure
                    acqui_info_all.ecg_signal{i}=acqui_info.ecg_signal;
                end
            end
            OCT.acqui_info=acqui_info_all;
        end

        OCT.jobsdone.concatenate=1;
        save(fullfile(OCT.output_dir,'OCT.mat'),'OCT');
        OCTmat{acquisition}=fullfile(OCT.output_dir,'OCT.mat');
    end
end

out.OCTmat = OCTmat;
end

function acqui_info=check_FOV(acqui_info);
%This function makes sure that the FOV in the x and y direction are
%correctly set, sometimes an error in labview would make a FOV of dimension
%0 or 3770 um to be written this allows the user to correct this error.

default_FOV_length=800;

acqui_info.x_FOV_um=round(acqui_info.x_FOV_um);
acqui_info.y_FOV_um=round(acqui_info.y_FOV_um);
acqui_info.z_FOV_um=round(acqui_info.z_FOV_um);

position=findstr(acqui_info.filename,filesep);
filename=acqui_info.filename(position(end)+1:end);
direction='';
switch acqui_info.ramp_type
    case 1
        
        if ~isempty(findstr(filename,'Coupe selon X'))||~isempty(findstr(acqui_info.filename,'Coupe selon  X'))
            direction='X';
            default_x_FOV_um=default_FOV_length;
            default_y_FOV_um=0;
        elseif ~isempty(findstr(filename,'Coupe selon Y'))||~isempty(findstr(acqui_info.filename,'Coupe selon  Y'))
            direction='Y';
            default_x_FOV_um=0;
            default_y_FOV_um=default_FOV_length;
        elseif findstr(filename,'deg')
            direction='deg';
            angle=str2num(filename(findstr(filename,'selon')+5:findstr(filename,'deg')-1));
            default_x_FOV_um=round(default_FOV_length*cos(angle*pi/180));
            default_y_FOV_um=round(default_FOV_length*sin(angle*pi/180));
        end
    case 4
        default_x_FOV_um=default_FOV_length;
        default_y_FOV_um=default_FOV_length;
    case 6
        default_x_FOV_um=default_FOV_length;
        default_y_FOV_um=default_FOV_length;
end

if ~exist('default_x_FOV_um')
    disp('Unknown FOV correction')
    
end

invalid_FOV=0;

if acqui_info.ramp_type>1
    if acqui_info.x_FOV_um<1||acqui_info.y_FOV_um<1
        invalid_FOV=1;
    end
end
if acqui_info.x_FOV_um==3770||acqui_info.y_FOV_um==3770
    invalid_FOV=1;
end

if (strcmp(direction,'X')&&abs(acqui_info.x_FOV_um)<abs(acqui_info.y_FOV_um))||...
        (strcmp(direction,'Y')&&abs(acqui_info.y_FOV_um)<abs(acqui_info.x_FOV_um))
    invalid_FOV=1;
end

if invalid_FOV
    Message={filename;['FOV seems invalid : X=' num2str(acqui_info.x_FOV_um)...
        ', Y=' num2str(acqui_info.y_FOV_um) ' and Z=' num2str(acqui_info.z_FOV_um)];...
        ['Suggested change : X=' num2str(default_x_FOV_um)...
        ', Y=' num2str(default_y_FOV_um) ' and Z=' num2str(acqui_info.z_FOV_um)];...
        'Accept change ?'};
    button=questdlg(Message,'Invalid FOV','Yes','No','Custom','Yes');
    
    if strcmp(button,'Yes')
        acqui_info.x_FOV_um=default_x_FOV_um;
        acqui_info.y_FOV_um=default_y_FOV_um;
    elseif strcmp(button,'Custom')
        prompt={'X (um)';'Y (um)';'Z (um)'};
        answer= inputdlg(prompt,'New FOV',1,...
            {num2str(acqui_info.x_FOV_um);num2str(acqui_info.y_FOV_um);num2str(acqui_info.z_FOV_um)});
        acqui_info.x_FOV_um=str2num(answer{1});
        acqui_info.y_FOV_um=str2num(answer{2});
        acqui_info.z_FOV_um=str2num(answer{3});
    end
    
end
end


function type=identifity_acquisition_type(filename)

if ~isempty(findstr(filename,'Coupe selon X'))||...
        ~isempty(findstr(filename,'Coupe selon  X'))||...
        ~isempty(findstr(filename,'Scan selon X'))
    type='X';
elseif ~isempty(findstr(filename,'Coupe selon Y'))||...
        ~isempty(findstr(filename,'Coupe selon  Y'))||...
        ~isempty(findstr(filename,'Scan selon Y'))
    type='Y';
elseif ~isempty(findstr(filename,'3D rev fast axis'))
    type='ThreeD_rfa';
elseif ~isempty(findstr(filename,'3D HD'))
    type='HD';
elseif ~isempty(findstr(filename,'3D'))
    type='ThreeD';
elseif ~isempty(findstr(filename,'Coupe'))
    type='Slice';
else
    type='unknown';
end
end