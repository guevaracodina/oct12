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
nScans = size(OCTmat,1);
% Consolidated results vector
resultsMatrix = zeros([nScans 8]);
% Names list
nameList = cell([nScans 1]);
% Comma Separated values (csv) file with consolidated results.
dataFile = fullfile(job.save_data_dir{1},'basal_CBF.csv');
fid = fopen(dataFile, 'w');
% Header of .csv file
fprintf(fid,'Name, Max. Flow Depth(µm), Diameter(µm), Max. Flow(nL/s), Min. Flow(nL/s), ROI Area(× 10^{-3} mm^2), Cross-Section Area(× 10^{-3} mm^2), Type(NaCl=0/CaCl_2=1), Side(Left=0/Right=1)\n');
% Loop over acquisitions (FOVs/scans)
for acquisition = 1:nScans
    try
        load(job.OCTmat{acquisition})
        if ~isfield (OCT.jobsdone, 'basalCBFdone')|| job.redo
            if isfield(OCT.recons_info, 'dop_recons')
                % Compute basal CBF (flow)
                result = get_flow_3D(OCT, job);
                % Append results to .csv file and print to screen
                [fid, result] = append_results(fid, OCT, result, job.ID.treatmentString);
                % Save results in OCT matrix
                OCT.basal_CBF_results = result;
                % Basal CBF done!
                OCT.jobsdone.basalCBFdone = true;
                save(fullfile(OCT.output_dir, 'OCT.mat'),'OCT');
                % Gather group data
                [nameList, resultsMatrix] = gather_data(nameList, resultsMatrix,...
                    acquisition, OCT.acqui_info.base_filename, result, nScans);
            else
                fprintf('Doppler data not available for %s\n', OCT.acqui_info.base_filename);
            end % dop_recons
        else
            % Load data from OCT matrix
            result = OCT.basal_CBF_results;
            % Append results to .csv file and print to screen
            [fid, result] = append_results(fid, OCT, result, job.ID.treatmentString);
            % Gather group data
            [nameList, resultsMatrix] = gather_data(nameList, resultsMatrix,...
                acquisition, OCT.acqui_info.base_filename, result, nScans);
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
% Plot Flow vs. Diameter
plot_flow_vs_diameter(resultsMatrix, nameList, job)
end % oct_diameter_vessel_run

function [fid, result] = append_results(fid, OCT, result, ID)
% Check if mouse is treatment (1) or control (0)
result.isTreatment = ~isempty(regexp(OCT.acqui_info.base_filename, [ID '[0-9]+'], 'once'));
% Check if scan was performed on Right (1) or Left (0) hemisphere
result.isRight = ~all(cellfun(@isempty, regexp(OCT.acqui_info.base_filename, {['R' '[0-9]+'] ['FOV' '[0-9]' 'R']}, 'once')));
% Cross Section Area(× 10^{-3} mm^2)
result.crossSectionArea = 1000 * pi * (result.diameter/2000)^2;
% Append data to .csv file
fprintf(fid, '%s, %6.4f, %6.4f, %6.4f, %6.4f, %6.4f, %6.4f, %6.4f, %6.4f \n',...
    OCT.acqui_info.base_filename, result.depth_max_flow, ...
    result.diameter, result.max_flow, result.min_flow, result.ROIarea,...
    result.crossSectionArea, result.isTreatment, result.isRight);
% Display result
fprintf('Name: %s\n Depth Max. Flow: %6.4f(µm)\n Diameter: %6.4f(µm)\n Max. Flow: %6.4f(nL/s)\n Min. Flow: %6.4f(nL/s)\n Area: %6.4f(× 10^{-3} mm^2)\n Cross-Section Area: %6.4f(× 10^{-3} mm^2)\n Type(NaCl=0/CaCl_2=1): [%6.4f]\n Side(Left=0/Right=1): [%6.4f]\n',...
    OCT.acqui_info.base_filename, result.depth_max_flow, ...
    result.diameter, result.max_flow, result.min_flow, result.ROIarea, ...
    result.crossSectionArea, result.isTreatment, result.isRight);
end % append_results

function [nameList, resultsMatrix] = gather_data(nameList, resultsMatrix,...
    acquisition, acqName, result, nScans)
% Save name list
nameList{acquisition}           = acqName;
resultsMatrix(acquisition,1)    = result.depth_max_flow;
% Save Diameter
resultsMatrix(acquisition,2)    = result.diameter;
% Save Max. Flow
resultsMatrix(acquisition,3)    = result.max_flow;
% Save Min. Flow
resultsMatrix(acquisition,4)    = result.min_flow;
% Save ROI area
resultsMatrix(acquisition,5)    = result.ROIarea;
% SAve cross-section area
resultsMatrix(acquisition,6)    = result.crossSectionArea;
% Check if mouse is treatment (1) or control (0)
resultsMatrix(acquisition,7)    = result.isTreatment;
% Save Right (1) or Left (0) hemisphere
resultsMatrix(acquisition,8)    = result.isRight;
fprintf('Scan %s (%d of %d) done!\n', acqName, acquisition, nScans)
end % gather_data

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
    draw_side_projection(92,Doppler1_mean,recons_info,result,job);
    
    if isfield(result,'top')
        button_answer = questdlg('Select new top and bottom?','Depths','Yes','No','Cancel','No');
    else
        button_answer = 'Yes';
    end
    
    if strcmp(button_answer,'Yes')
        % Displays lateral MIP
        draw_side_projection(92,Doppler1_mean,recons_info,struct([]),job)
        title({acqui_info.base_filename;...
            'Select top and bottom of vessels'}, 'interpreter','none','FontSize',job.optFig.titleFontSize)
        top_bottom=ginput(2);
        top_bottom=top_bottom/recons_info.step(2);
        result.top=floor(min(top_bottom(:,2)));
        result.bottom=ceil(max(top_bottom(:,2)));
    end
    depth_range=result.top:result.bottom;
    
    % Displays lateral MIP
    draw_side_projection(92,Doppler1_mean,recons_info,result,job)
    
    if ~isfield(recons_info,'doppler_normalization')
        recons_info.doppler_normalization = pi;
    end
    
    % This will give the speed in the units of the wavelength
    [XY_speed_3D,max_speed] = get_speed(squeeze(Doppler1.data(:,depth_range,:)),...
        acqui_info.line_period_us, wavelength, recons_info.doppler_normalization);
    
    % This is the area of each pixel in mm^2
    area_per_pixel = recons_info.step(1)*recons_info.step(3)*1e-6;
    
    Speed_to_display = squeeze(max(abs(XY_speed_3D),[],2)).*squeeze(sign(mean(XY_speed_3D,2)));
    
    %% This second part is to select the ROI from the en face projection
    
    % Displays en face MIP
    draw_top_projection(91,Speed_to_display,max_speed,recons_info,result,job)
    
    if isfield(result,'y_poly')
        button_answer = questdlg('Select new ROI?','ROI','Yes','No','Cancel','No');
    else
        button_answer = 'Yes';
    end
    
    if strcmp(button_answer,'Yes')
        % Displays en face MIP
        draw_top_projection(91,Speed_to_display,max_speed,recons_info,struct([]),job)
        title({acqui_info.base_filename;...
            'Select ROI, double click to confirm'},'interpreter','none','FontSize',job.optFig.titleFontSize)
        [result.BW,result.y_poly,result.x_poly] = roipoly; %This will open up a roi selection tool
        draw_top_projection(91,Speed_to_display,max_speed,recons_info,result,job)
        title('Select diameter of vessel', 'interpreter','none','FontSize',job.optFig.titleFontSize)
        pause(0.1)
        [result.diam_pos_y,result.diam_pos_x] = ginput(2);
    end
    
    % Displays en face MIP
    draw_top_projection(91,Speed_to_display,max_speed,recons_info,result,job)
    
    diameter=round(sqrt((result.diam_pos_y(1)-result.diam_pos_y(2))^2+...
        (result.diam_pos_x(1)-result.diam_pos_x(2))^2));
    ROIarea = sum(sum(result.BW))*area_per_pixel; % This is the area of the selected roi in mm^2
    
    title({OCT.acqui_info.base_filename;...
        ['Area ~' num2str(round(ROIarea*1000))...
        ' X 10^{-3} mm^2, Vessel diameter : ' num2str(diameter) ' \mum']},'FontSize',job.optFig.titleFontSize)
    
    BW_3D = zeros(size(XY_speed_3D));
    for i=1:numel(depth_range)
        BW_3D(:,i,:) = result.BW;
    end
    
    flow_positive=sum(sum(BW_3D.*XY_speed_3D.*(XY_speed_3D>0),1),3)*area_per_pixel*1e3;
    flow_negative=sum(sum(BW_3D.*XY_speed_3D.*(XY_speed_3D<0),1),3)*area_per_pixel*1e3;
    flow_difference=abs(flow_positive+flow_negative);
    flow_sum=flow_positive-flow_negative;
    
    speed=sum(sum(BW_3D.*XY_speed_3D,1),3);
    flow_uLps=speed*area_per_pixel;
    % Liters/Min
    flow_Lpm=flow_uLps*1e-6*60;
    flow_nLps=flow_uLps*1e3;
    max_flow=max(abs(flow_nLps));
    min_flow=min(abs(flow_nLps));
    depth_max_flow=depth_range(find(abs(flow_nLps)==max_flow));
    
    %% This thrid part dispaky blood flow profile vs. depth
    figure(93); set(gcf,'color','w');
    plot(depth_range*recons_info.step(2),flow_nLps./sign(flow_uLps))
    title({['Mean flow : ' num2str(mean(flow_nLps)./sign(mean(flow_nLps))) ' nL/s, Std : '...
        num2str(std(flow_nLps))];...
        ['Max flow : ' num2str(round(max_flow*10)/10) ' nL/s, Min flow : '...
        num2str(round(min_flow*10)/10) ' nL/s']},'interpreter','none','FontSize',job.optFig.titleFontSize)
    xlabel('Depth (\mum)','FontSize',job.optFig.xLabelFontSize)
    ylabel('Blood Flow (nL/s)','FontSize',job.optFig.yLabelFontSize)
    % Valid results flag
    result.valid = true;
    
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
    
    %% Optionally print/save figures
    if job.save_figures
        dir_fig = fullfile(OCT.output_dir,'fig');
        if ~exist(dir_fig,'dir'),mkdir(dir_fig);end
        set(91,'name',[acqui_info.base_filename 'roi']);
        set(92,'name',[acqui_info.base_filename 'depth']);
        set(93,'name',[acqui_info.base_filename 'flow']);
        % Specify window units
        set(91, 'units', 'inches')
        % Change figure and paper size
        set(91, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        set(91, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        % Specify window units
        set(92, 'units', 'inches')
        % Change figure and paper size
        set(92, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        set(92, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        % Specify window units
        set(93, 'units', 'inches')
        % Change figure and paper size
        set(93, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        set(93, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
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
else
    disp(['Acquisition ' num2str(acquisition) ' invalid for 3D flow measurement'])
end % end acquisition_valid
end % get_flow_3D

function [speed, max_speed] = get_speed(doppler_int16,line_period_us,...
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
end % get_speed

function draw_top_projection(figure_handle,Speed_to_display,max_speed,...
    recons_info,result,job)
% Displays en face MIP of Doppler velocity 3D data
load('doppler_color_map.mat')
figure(figure_handle)
set(gcf,'color','w')
% subplot(1,2,1)
FOV = recons_info.step.*recons_info.size;
imagesc([0 FOV(3)],[0 FOV(1)],Speed_to_display,max_speed*[-1 1]/2)
axis image
colormap(doppler_color_map);
xlabel('Y (\mum)','FontSize',job.optFig.xLabelFontSize);
ylabel('X (\mum)','FontSize',job.optFig.yLabelFontSize)
set(gca,'FontSize',job.optFig.axisFontSize);
colorbar_handle=colorbar;
set(get(colorbar_handle,'ylabel'),'String', 'Z speed (mm/s)','FontSize',job.optFig.axisFontSize);

if isfield(result,'y_poly')
    h_line=line(result.y_poly,result.x_poly);set(h_line,'Color','k');...
        set(h_line,'LineWidth',2) %This will draw the roi that was selected
    xlabel('Y (\mum)','FontSize',job.optFig.xLabelFontSize);
    ylabel('X (\mum)','FontSize',job.optFig.yLabelFontSize)
end

if isfield(result,'diam_pos_y')
    h_diameter=line(result.diam_pos_y,result.diam_pos_x);
    set(h_diameter,'Color','k');set(h_diameter,'LineWidth',2);...
        set(h_diameter,'LineStyle',':')
end

end % draw_top_projection

function draw_side_projection(figure_handle,Doppler1_mean,recons_info,result,job)
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
set(gca,'FontSize',job.optFig.axisFontSize);
xlabel('Y (\mum)','FontSize',job.optFig.xLabelFontSize);
ylabel('Z (\mum)','FontSize',job.optFig.yLabelFontSize)
axis equal tight
colormap(doppler_color_map)

if isfield(result,'top')
    h(1)=line([1 m],result.top*[1 1]*recons_info.step(2));
    h(2)=line([1 m],result.bottom*[1 1]*recons_info.step(2));
    thickness=abs(result.bottom-result.top)*recons_info.step(2);
    text(0,(result.top+result.bottom)/2*recons_info.step(2),['Thickness ' num2str(round(thickness)) '\mum'])
    set(h,'color','k','linestyle',':')
end
end % draw_side_projection

function plot_flow_vs_diameter(resultsMatrix, nameList, job)
h = figure(99);
set(h,'color','w');
flow        = resultsMatrix(:,3);
diameter    = resultsMatrix(:,2);
isTreatment = logical(resultsMatrix(:,7));
isRight     = logical(resultsMatrix(:,8));
% Control
plot(diameter(~isTreatment), flow(~isTreatment), 'ok');
hold on
plot(diameter(isTreatment), flow(isTreatment), 'sr');
axis normal
legend(job.optFig.legends.legendShow.legendStr,'FontSize',...
    job.optFig.legends.legendShow.legendFontSize,'location',...
    job.optFig.legends.legendShow.legendLocation);
set(gca,'FontSize',job.optFig.axisFontSize);
xlabel('Vessel Diameter (\mum)','FontSize',job.optFig.xLabelFontSize);
ylabel('Blood Flow (nL/s)','FontSize',job.optFig.yLabelFontSize);
xlim([10 200]);
ylim([0 10]);
dir_fig = job.save_data_dir{1};
% Column headers
colHeaders = {  'Max. Flow Depth(µm)'
                'Diameter(µm)'
                'Max. Flow(nL/s)'
                'Min. Flow(nL/s)'
                'ROI Area(× 10^{-3} mm^2)'
                'Cross-Section Area(× 10^{-3} mm^2)'
                'NaCl=0/CaCl_2=1'
                'Side(Left=0/Right=1)'}';
% Save results in mat file
save(fullfile(dir_fig, 'basal_CBF'),'nameList', 'resultsMatrix', 'isTreatment', 'isRight','colHeaders')

%% Optionally print/save figures
if job.save_figures
    if ~exist(dir_fig,'dir'),mkdir(dir_fig);end
    set(h,'name','flow_vs_diameter');
    % Specify window units
    set(h, 'units', 'inches')
    % Change figure and paper size
    set(h, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
    set(h, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
    % Save as PNG
    print(h,fullfile(dir_fig,'flow_vs_diameter'),'-dpng','-r300');
    % Save as a figure
    saveas(h,fullfile(dir_fig,'flow_vs_diameter'),'fig');
    close(h)
end
end % plot_flow_vs_diameter

% EOF
