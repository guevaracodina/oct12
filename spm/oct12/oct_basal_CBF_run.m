function out = oct_basal_CBF_run(job)
% Retrieves figures from ECG-gated Doppler & prompts user to measure vessels
% diameter
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% ------------------------------------------------------------------------------
% REMOVE AFTER FINISHING THE FUNCTION //EGC
% ------------------------------------------------------------------------------
% fprintf('Work in progress...\nEGC\n')
% out.OCTmat = job.OCTmat;
% return
% ------------------------------------------------------------------------------

rev = '$Rev$'; %#ok

% Reference from previous computation.
OCTmat = job.OCTmat;

dataFile = fullfile(job.save_data_dir{1},'basal_CBF.csv');
fid = fopen(dataFile, 'w');
% Header of .csv file
fprintf(fid,'Name, Max. Flow Depth(µm), Diameter(µm), Max. Flow(nL/s), Min. Flow(nL/s), ROI Area(X 10^{-3} mm^2)\n');

% Loop over acquisitions (FOVs)
for acquisition = 1:size(OCTmat,1)
    try
        load(job.OCTmat{acquisition})
        if ~isfield (OCT.jobsdone, 'basalCBFdone')|| job.redo
            if isfield(OCT.recons_info, 'dop_recons')
                % Compute basal CBF (flow)
                result = get_flow_3D(OCT, job);
                % Append data to .csv file
                fprintf(fid, '%s, %6.4f, %6.4f, %6.4f, %6.4f, %6.4f\n',...
                    OCT.acqui_info.base_filename, result.depth_max_flow, ...
                    result.diameter, result.max_flow,...
                    result.min_flow, result.ROIarea);
                % Display result
                fprintf('Name: %s\n Depth Max. Flow: %6.4f(µm)\n Diameter: %6.4f(µm)\n Max. Flow: %6.4f(nL/s)\n Min. Flow: %6.4f(nL/s)\n Area: %6.4f(X 10^{-3} mm^2)\n',...
                    OCT.acqui_info.base_filename, result.depth_max_flow, ...
                    result.diameter, result.max_flow,...
                    result.min_flow, result.ROIarea);
                % Save results in OCT matrix
                OCT.basal_CBF_results = result;
                % Basal CBF done!
                OCT.jobsdone.basalCBFdone = true;
                save(fullfile(OCT.output_dir, 'OCT.mat'),'OCT');
            else
                fprintf('Doppler data not available for %s\n', OCT.acqui_info.base_filename);
            end % dop_recons
        else
            % Load data from OCT matrix
            result = OCT.basal_CBF_results;
            % Append data to .csv file
            fprintf(fid, '%s, %6.4f, %6.4f, %6.4f, %6.4f, %6.4f\n',...
                OCT.acqui_info.base_filename, result.depth_max_flow, ...
                result.diameter, result.max_flow,...
                result.min_flow, result.ROIarea);
            % Display result
            fprintf('Data preloaded for: %s\n Depth Max. Flow: %6.4f(µm)\n Diameter: %6.4f(µm)\n Max. Flow: %6.4f(nL/s)\n Min. Flow: %6.4f(nL/s)\n Area: %6.4f(X 10^{-3} mm^2)\n',...
                OCT.acqui_info.base_filename, result.depth_max_flow, ...
                result.diameter, result.max_flow,...
                result.min_flow, result.ROIarea);
        end % jobsdone
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        % Close all open files
        fclose all;
        out.OCTmat{acquisition} = job.OCTmat{acquisition};
    end
end % Acquisitions loop
% Close .csv file
fclose(fid);
out.OCTmat = OCTmat;
end % oct_diameter_vessel_run

function result = get_flow_3D(OCT, job)
wavelength = 870e-6;                % Wavelength in m
load('doppler_color_map.mat');      % Doppler velocity colormap
clear acqui_info recons_info result % clear variables
acqui_info = OCT.acqui_info;        % Acquisition info
recons_info = OCT.recons_info;      % Reconstruction info
% Initialize 3D volume, it is a handle class to be able to pass across functions
Doppler1 = C_OCTVolume(OCT.recons_info.size);
% Map file into memory
Doppler1.openint16(OCT.recons_info.dop_recons.filename);
acquisition_valid = false;
% Object type
Doppler1_type = whos('Doppler1');
% Check data type sanity
if acqui_info.ramp_type==4 && exist('recons_info','var')&&...
        strcmp(Doppler1_type.class,'C_OCTVolume') && acqui_info.rev_fast_axis==1
    acquisition_valid = true;
end
if acquisition_valid
    if ~exist('result', 'var')
        result.temp = true;
    end
    %% This first part is to select the depths to analyse
    Doppler1_mean = mean(Doppler1.data,3);
    % Displays lateral MIP 
    draw_side_projection(92,Doppler1_mean,recons_info,result);
    
    if isfield(result,'top')
        button_answer=questdlg('Select new top and bottom?','Depths','Yes','No','Cancel','No');
    else
        button_answer='Yes';
    end
    
    if strcmp(button_answer,'Yes')
        % Displays lateral MIP 
        draw_side_projection(92,Doppler1_mean,recons_info,struct([]))
        title({acqui_info.base_filename;...
            'Select top and bottom of vessels'})
        top_bottom=ginput(2);
        top_bottom=top_bottom/recons_info.step(2);
        result.top=floor(min(top_bottom(:,2)));
        result.bottom=ceil(max(top_bottom(:,2)));
    end
    depth_range=result.top:result.bottom;
    
%     if ~isfield(result,'vessel_angle')
%         result.vessel_angle=determine_vessel_angle(Doppler1.Data.Data,recons_info);
%     end
    
    % Displays lateral MIP 
    draw_side_projection(92,Doppler1_mean,recons_info,result)
    
    if ~isfield(recons_info,'doppler_normalization')
        recons_info.doppler_normalization=pi;end
    
    % This will give the speed in the units of the wavelength
    [XY_speed_3D,max_speed] = getspeed(squeeze(Doppler1.data(:,depth_range,:)),...
        acqui_info.line_period_us, wavelength, recons_info.doppler_normalization);
    
    % This is the area of each pixel in mm^2
    area_per_pixel = recons_info.step(1)*recons_info.step(3)*1e-6;
    
    Speed_to_display = squeeze(max(abs(XY_speed_3D),[],2)).*squeeze(sign(mean(XY_speed_3D,2)));
    
    % Displays en face MIP 
    draw_top_projection(91,Speed_to_display,max_speed,recons_info,result)
    
    if isfield(result,'y_poly')
        button_answer = questdlg('Select new ROI?','ROI','Yes','No','Cancel','No');
    else
        button_answer = 'Yes';
    end
    
    if strcmp(button_answer,'Yes')
        % Displays en face MIP 
        draw_top_projection(91,Speed_to_display,max_speed,recons_info,struct([]))
        title({acqui_info.base_filename;...
            'Select ROI, double click to confirm'})
        [result.BW,result.y_poly,result.x_poly] = roipoly; %This will open up a roi selection tool
        draw_top_projection(91,Speed_to_display,max_speed,recons_info,result)
        title('Select diameter of vessel')
        pause(0.1)
        [result.diam_pos_y,result.diam_pos_x] = ginput(2);
    end
    
    % Displays en face MIP
    draw_top_projection(91,Speed_to_display,max_speed,recons_info,result)
    
    diameter=round(sqrt((result.diam_pos_y(1)-result.diam_pos_y(2))^2+...
        (result.diam_pos_x(1)-result.diam_pos_x(2))^2));
    ROIarea = sum(sum(result.BW))*area_per_pixel; % This is the area of the selected roi in mm^2
    
    title({OCT.acqui_info.base_filename;...
        ['Area ~' num2str(round(ROIarea*1000))...
        ' X 10^{-3} mm^2, Vessel diameter : ' num2str(diameter) ' um']})
    
    BW_3D = zeros(size(XY_speed_3D));
    for i=1:numel(depth_range)
        BW_3D(:,i,:) = result.BW;
    end
    
    flow_positive=sum(sum(BW_3D.*XY_speed_3D.*(XY_speed_3D>0),1),3)*area_per_pixel*1e3;
    flow_negative=sum(sum(BW_3D.*XY_speed_3D.*(XY_speed_3D<0),1),3)*area_per_pixel*1e3;
    flow_difference=abs(flow_positive+flow_negative);
    flow_sum=flow_positive-flow_negative;
    
%     figure(95);
%     h = plot(depth_range*recons_info.step(2),[flow_positive;-1*flow_negative;flow_difference;flow_sum]');
%     set(h(1),'color','r')
%     set(h(2),'color','b')
%     set(h(3),'color','k')
%     
%     legend('Positive flow','Negative flow','Flow difference','Flow sum')
%     xlabel('Depth (\mum)')
%     ylabel('Blood Flow (nL/s)')
    
    speed=sum(sum(BW_3D.*XY_speed_3D,1),3);
    flow_uLps=speed*area_per_pixel;
    
    flow_Lpm=flow_uLps*1e-6*60;
    flow_nLps=flow_uLps*1e3;
    max_flow=max(abs(flow_nLps));
    min_flow=min(abs(flow_nLps));
    depth_max_flow=depth_range(find(abs(flow_nLps)==max_flow));
    
    figure(93); set(gcf,'color','w');
    plot(depth_range*recons_info.step(2),flow_nLps./sign(flow_uLps))
    title({['Mean flow : ' num2str(mean(flow_nLps)./sign(mean(flow_nLps))) ' nL/s, Std : '...
        num2str(std(flow_nLps))];...
        ['Max flow : ' num2str(round(max_flow*10)/10) ' nL/s, Min flow : '...
        num2str(round(min_flow*10)/10) ' nL/s']})
    xlabel('Depth (\mum)')
    ylabel('Blood Flow (nL/s)')
    
    %         position_initial=get(1,'position');
    %         set(1,'position',[200 500 position_initial(3) position_initial(4)])
    %         set(3,'position',[850 500 position_initial(3) position_initial(4)])
    
%     button_keep=questdlg('Keep Data?','Data Valid','Keep','Reject','Cancel','Keep');
%     
%     if strcmp(button_keep,'Keep')
%         result.valid = true;
%     elseif strcmp(button_keep,'Reject')
%         result.valid = false;
%     else
%     end
    
    % pause(0.5)
    result.valid = true;
    if job.save_figures
        dir_fig = fullfile(OCT.output_dir,'fig');
        if ~exist(dir_fig,'dir'),mkdir(dir_fig);end
        set(91,'name',[acqui_info.base_filename 'roi']);
        set(92,'name',[acqui_info.base_filename 'depth']);
        set(93,'name',[acqui_info.base_filename 'flow']);
        % Save as PNG
        print(91,fullfile(dir_fig,[acqui_info.base_filename 'roi']),'-dpng','-r300');
        print(92,fullfile(dir_fig,[acqui_info.base_filename 'depth']),'-dpng','-r300');
        print(93,fullfile(dir_fig,[acqui_info.base_filename 'flow']),'-dpng','-r300');
        % Save as a figure
        saveas(91,fullfile(dir_fig,[acqui_info.base_filename 'roi']),'fig');
        saveas(92,fullfile(dir_fig,[acqui_info.base_filename 'depth']),'fig');
        saveas(93,fullfile(dir_fig,[acqui_info.base_filename 'flow']),'fig');
        close(91:93)
    end
    
    %% Units conversion
    depth_range             = depth_range*recons_info.step(2);      % um
    depth_max_flow          = depth_max_flow*recons_info.step(2);   % um
    diameter                = diameter;                             % um
    flow_nLps               = flow_nLps;                            % nL/s
    max_flow                = round(max_flow*10)/10;                % nL/s
    min_flow                = round(min_flow*10)/10;                % nL/s
    ROIarea                 = round(ROIarea*1000);                  % X 10^{-3} mm^2
    
    result.depth_range      = depth_range;                          % um
    result.depth_max_flow   = depth_max_flow;                       % um
    result.diameter         = diameter;                             % um
    result.flow_nLps        = flow_nLps;                            % nL/s
    result.max_flow         = max_flow;                             % nL/s
    result.min_flow         = min_flow;                             % nL/s
    result.ROIarea          = ROIarea;                              % X 10^{-3} mm^2
else
    disp(['Acquisition ' num2str(acquisition) ' invalid for 3D flow measurement'])
end
% end acquisition loop
end % get_flow_3D

function [speed, max_speed] = getspeed(doppler_int16,line_period_us,...
    wavelength,doppler_normalization)
% This will give the speed in the units of the wavelength
if ~exist('doppler_normalization')
    doppler_normalization = pi;
end
Doppler_frequency = doppler_normalization/pi*double(doppler_int16)...
    /double(intmax('int16'))/2/line_period_us/1e-6;
speed = Doppler_frequency*wavelength/2;
speed = speed/2; %This is the correction factor determined by the test on the fantom

max_doppler_frequency = 1/2/line_period_us/1e-6; %Acquisition frequency in Hz
max_speed = max_doppler_frequency*wavelength/2; %Speed in mm/s

max_speed = max_speed/2; %This is an experimentally determined correction factor. Needs to be verified.
end % getspeed

function draw_top_projection(figure_handle,Speed_to_display,max_speed,recons_info,result)
% Displays en face MIP of Doppler velocity 3D data
load('doppler_color_map.mat')
figure(figure_handle)
set(gcf,'color','w')
% subplot(1,2,1)
FOV = recons_info.step.*recons_info.size;
imagesc([0 FOV(3)],[0 FOV(1)],Speed_to_display,max_speed*[-1 1]/2)
axis image
colormap(doppler_color_map);xlabel('Y (um)');ylabel('X (um)')
colorbar_handle=colorbar;
set(get(colorbar_handle,'ylabel'),'String', 'Z speed (mm/s)');

if isfield(result,'y_poly')
    h_line=line(result.y_poly,result.x_poly);set(h_line,'Color','k');...
        set(h_line,'LineWidth',2) %This will draw the roi that was selected
    xlabel('Y (um)');ylabel('X (um)')
end

if isfield(result,'diam_pos_y')
    h_diameter=line(result.diam_pos_y,result.diam_pos_x);
    set(h_diameter,'Color','k');set(h_diameter,'LineWidth',2);...
        set(h_diameter,'LineStyle',':')
end

end % draw_top_projection

function draw_side_projection(figure_handle,Doppler1_mean,recons_info,result)
% Displays lateral MIP  of Doppler velocity 3D data
figure(figure_handle)
set(gcf,'color','w')
[m n]=size(Doppler1_mean);
maxVal = max(Doppler1_mean(:));
% 
dispPerc = 0.2;
if maxVal > 0,
    maxVal = (1-dispPerc)*maxVal;
else
    maxVal = (1+dispPerc)*maxVal;
end
minVal = min(Doppler1_mean(:));
if minVal > 0,
    minVal = (1+dispPerc)*minVal;
else
    minVal = (1-dispPerc)*minVal;
end
load('doppler_color_map.mat')
% imagesc([0 recons_info.size(1)*recons_info.step(1)],...
%     [0 recons_info.size(2)*recons_info.step(2)],Doppler1_mean',5000*[-1 1])
imagesc([0 recons_info.size(1)*recons_info.step(1)],...
    [0 recons_info.size(2)*recons_info.step(2)],Doppler1_mean',[minVal maxVal])
xlabel('Y (um)');ylabel('Z (um)')
axis equal tight
colormap(doppler_color_map)

if isfield(result,'top')
    h(1)=line([1 m],result.top*[1 1]*recons_info.step(2));
    h(2)=line([1 m],result.bottom*[1 1]*recons_info.step(2));
    thickness=abs(result.bottom-result.top)*recons_info.step(2);
    text(0,(result.top+result.bottom)/2*recons_info.step(2),['Thickness ' num2str(round(thickness)) 'um'])
    set(h,'color','k','linestyle',':')
end
end % draw_side_projection

% EOF
