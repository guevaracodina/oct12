%% Tube PE-10 flow script

% Top folder containing all subjects data (change as needed)
dataFolder = 'D:\Edgar\Data\OCT_Results\2012-10-05 - Fantom Tube\';
subjectFolder = '';
scanType = 'X';
load('D:\spm8\toolbox\oct12\doppler_color_map.mat')

if ~exist(dataFolder,'dir')
    dataFolder = matlabroot;
end
if isempty(subjectFolder) || ~exist(subjectFolder,'var')
    subjectFolder = uigetdir(dataFolder, 'Pick a subject directory');
    if subjectFolder == 0
        % User cancelled input
        disp('User cancelled input')
        return
    end
end

tic
fprintf('Averaging OCT scans...\n')

% Separate subdirectories and files:
d = dir(subjectFolder);
isub = [d(:).isdir];            % Returns logical vector
folderList = {d(isub).name}';
% Remove . and ..
folderList(ismember(folderList,{'.','..'})) = [];

% Scans (FOV) loop
for iScans = 1:length(folderList)
    currentFolder = fullfile(subjectFolder,folderList{iScans},scanType);
    % Find *.dopl3D files
    d = dir(fullfile(currentFolder,'*.dopl3D'));
    fileList = {d.name}';
    if isempty(fileList)
        fprintf('No .dopl3D files in folder %s\n',currentFolder)
    else
        octMat(iScans) = load(fullfile(currentFolder,'OCT.mat'));
        rStep(iScans) = octMat(iScans).OCT.recons_info.step(1);
        zStep(iScans) = octMat(iScans).OCT.recons_info.step(2);
        rSize(iScans) = octMat(iScans).OCT.recons_info.size(1);
        zSize(iScans) = octMat(iScans).OCT.recons_info.size(2);
        % build z, r axis to display scaled data //EGC
        rAxis(:,iScans) = 0:rStep(iScans):rStep(iScans)*(rSize(iScans) - 1);
        zAxis(:,iScans) = 0:zStep(iScans):zStep(iScans)*(zSize(iScans) - 1);
        labelX(iScans) = octMat(iScans).OCT.recons_info.type{1};
        labelY(iScans) = octMat(iScans).OCT.recons_info.type{2};
        % Loop through all .dopl3D files
        for iFiles=1:length(fileList)
            currentFile = fullfile(currentFolder,fileList{iFiles});
            parentFolder = regexp(fileparts(currentFolder),'[0-9]+$','once','match');
            % Memory map files
            assignin('base',sprintf('Doppler%s_%s_%03d',parentFolder,scanType,iFiles),memmapfile(currentFile,...
                'Format',{'int16' octMat(iScans).OCT.recons_info.size 'Data'}))
            % Average frames
            avgDoppler(:,:,iScans) = mean(evalin('base',[sprintf('Doppler%s_%s_%03d',parentFolder,scanType,iFiles) '.Data.Data']),3)';
        end
    end
end
fprintf('Averaging OCT scans done!\n')
disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')]);

%% Save results
save(fullfile(dataFolder,'meanDoppler.mat'),'avgDoppler','doppler_color_map',...
    'rAxis','zAxis','labelX','labelY','folderList','dataFolder')

%% Plot results
load('D:\Edgar\Data\OCT_Results\2012-10-05 - Fantom Tube\meanDoppler.mat')
vMax = 870e-9 / (4e-6*acqui_info.line_period_us); % max velocity in (m/s)
figure; set(gcf,'color','w')
colormap(doppler_color_map)
avgDoppler = vMax * avgDoppler * (max(avgDoppler(:)) - min(avgDoppler(:)))/ double(intmax('int16')); % in (mm/s)
minVal = min(avgDoppler(:));
maxVal = max(avgDoppler(:));
for iPlots = 1:numel(folderList)
    subplot(3,4,iPlots);
    imagesc(rAxis(:,iPlots),zAxis(:,iPlots),...
        squeeze(avgDoppler(:,:,iPlots)),[minVal maxVal]);
    axis image
    % Depth limits
    ylim([0 800])
    title([sprintf('Flow = %s',folderList{iPlots}) ' \muL/min'],'FontSize',14)
    xlabel([labelX(iPlots) ' [\mum]'],'FontSize',14);
    ylabel([labelY(iPlots) ' [\mum]'],'FontSize',14);
    set(gca,'FontSize',12)
end
subplot(3,4,iPlots+1);
imagesc(rAxis(:,iPlots),zAxis(:,iPlots),...
        squeeze(avgDoppler(:,:,iPlots)),[minVal maxVal]);
h = colorbar;
ylabel(h, '[mm/s]', 'FontSize', 14);
set(h, 'FontSize', 12)
cla; axis off;

%% Print graphics
addpath(genpath('D:\Edgar\ssoct\Matlab'))
export_fig(fullfile(dataFolder,'tube_uL_min'),'-png',gcf)
export_fig(fullfile('D:\Edgar\Documents\Dropbox\Docs\fcOIS\2012_10_15_Report','tube_uL_min'),'-png',gcf) 

%% Create mask
load('D:\Edgar\Data\OCT_Results\2012-10-05 - Fantom Tube\meanDoppler.mat')
load('D:\Edgar\Data\OCT_Data\2012-10-05 - Fantom Tube\020\X\Fantom Tube - 020_uL_min - Coupe selon X-4800.mat')
% mask = ioi_roi_spline(squeeze(avgDoppler(:,:,10)),[],[],'Mark spline points, then right-click in it to create mask');


% Compute flow
nFrames = numel(folderList);
realFlow = str2double(folderList);
calcFlow = zeros(size(realFlow));
meanDoppler = zeros(size(realFlow));
stdDoppler =  zeros(size(realFlow));
% PE-10 tube info
rTube = (0.011*25.4)/2; % in (mm)
rArea = pi*rTube^2; % in (mm^2)
vMax = 870e-9 / (4e-6*acqui_info.line_period_us); % max velocity in (m/s)
avgDoppler = vMax * avgDoppler * (max(avgDoppler(:)) - min(avgDoppler(:)))/ double(intmax('int16')); % in (mm/s)

for iFrames = 1:nFrames,
    tmpDoppler = squeeze(avgDoppler(:,:,iFrames));
%     tmpDoppler = tmpDoppler.*(max(tmpDoppler(:))-min(tmpDoppler(:))) ./
%     double(intmax('int16'));
    meanDoppler(iFrames) = mean(tmpDoppler(mask));
    stdDoppler(iFrames) = std(tmpDoppler(mask));
end


%% Plot flow results
figure; set(gcf,'color','w')
realDoppler = -realFlow / (rArea*1e3);
h = errorbar(realDoppler, meanDoppler, stdDoppler, 'ks');
set(h, 'MarkerFaceColor','k', 'LineWidth', 2)
hold on
plot(realDoppler, realDoppler, 'r--', 'LineWidth', 2)
axis image
title('Doppler velocity','FontSize',14)
xlabel('Imposed velocity [mm/s]','FontSize',14);
ylabel('Calculated velocity [mm/s]','FontSize',14);
set(gca,'FontSize',12)

%% Print graphics
addpath(genpath('D:\Edgar\ssoct\Matlab'))
export_fig(fullfile(dataFolder,'tube_vel_mm_s'),'-png',gcf)
export_fig(fullfile('D:\Edgar\Documents\Dropbox\Docs\fcOIS\2012_10_15_Report','tube_vel_mm_s'),'-png',gcf) 
