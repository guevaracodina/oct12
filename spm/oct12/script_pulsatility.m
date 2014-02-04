% script_pulsatility
%% Script map reconstructed Doppler & Structural files
addpath(genpath('D:\spm8\toolbox\oct12'))
addpath(genpath('D:\spm8\toolbox\pat12'))
addpath(genpath('D:\Edgar\ssoct\Matlab'))
figsFolder = 'D:\Edgar\Documents\Dropbox\Docs\Carotid';
load('D:\spm8\toolbox\oct12\doppler_color_map.mat')

%% Open Doppler Y
% ------------------------------------------------------------------------------
% Load OCT matrix
OCTmat = 'F:\Edgar\Data\OCT_Results\2012-10-12 - Souris NC06\Souris NC06 - MCAR01\Y\OCT.mat';
load(OCTmat)
uiopen('F:\Edgar\Data\OCT_Results\2012-10-12 - Souris NC06\Souris NC06 - MCAR01\Y\fig\ROI_pulse.fig',1)
imcontrast
%% Save PNG
export_fig(fullfile(figsFolder,[OCT.acqui_info.base_filename 'doppler']),'-png',gcf)
% ------------------------------------------------------------------------------

%% Open Doppler X
% ------------------------------------------------------------------------------
% Load OCT matrix
OCTmat = 'F:\Edgar\Data\OCT_Results\2012-10-12 - Souris NC06\Souris NC06 - MCAR01\X\OCT.mat';
load(OCTmat)
uiopen('F:\Edgar\Data\OCT_Results\2012-10-12 - Souris NC06\Souris NC06 - MCAR01\X\fig\ROI_pulse.fig',1)
imcontrast
%% Save PNG
export_fig(fullfile(figsFolder, [OCT.acqui_info.base_filename 'doppler']),'-png',gcf)
% ------------------------------------------------------------------------------

%% Map structural file X
% ------------------------------------------------------------------------------
OCTmat = 'F:\Edgar\Data\OCT_Results\2012-10-12 - Souris NC06\Souris NC06 - MCAR01\X\OCT.mat';
load(OCTmat)
pathName = 'F:\Edgar\Data\OCT_Results\2012-10-12 - Souris NC06\Souris NC06 - MCAR01\X';
datasize = OCT.recons_info.size;
f1 = fullfile(pathName,'Souris NC06 - MCAR01 - Coupe selon X.struct3D');
struct1 = memmapfile(f1,'Format',{'int16' datasize 'Data'});
xSlice  = mean(struct1.Data.Data, 3);
%% Plot structural image
h = figure;
maximize_figure(h, OCT.acqui_info)
% Font Sizes
axisFontSize    = 16;
labelFontSize   = 18;
subplot(1,2,1)
colormap(gray);
% build z, r axis to display scaled data //EGC
rAxis = 0:OCT.recons_info.step(1):OCT.recons_info.step(1)*(OCT.recons_info.size(1) - 1);
zAxis = 0:OCT.recons_info.step(2):OCT.recons_info.step(2)*(OCT.recons_info.size(2) - 1);
imagesc(rAxis,zAxis,xSlice');
% title('Choose an ROI containing a vessel','FontSize',titleFontSize,'interpreter','none')
set(gca,'FontSize',axisFontSize)
ylabel([OCT.recons_info.type{2} ' [\mum]'],'FontSize',labelFontSize);
xlabel([OCT.recons_info.type{1} ' [\mum]'],'FontSize',labelFontSize);
% imcontrast
%% Save PNG
export_fig(fullfile(figsFolder, [OCT.acqui_info.base_filename 'struct']),'-png',gcf)
% ------------------------------------------------------------------------------

%% Map structural file Y
% ------------------------------------------------------------------------------
OCTmat = 'F:\Edgar\Data\OCT_Results\2012-10-12 - Souris NC06\Souris NC06 - MCAR01\Y\OCT.mat';
load(OCTmat)
pathName = 'F:\Edgar\Data\OCT_Results\2012-10-12 - Souris NC06\Souris NC06 - MCAR01\Y';
datasize = OCT.recons_info.size;
recons_info = OCT.recons_info;
f1 = fullfile(pathName,'Souris NC06 - MCAR01 - Coupe selon Y.struct3D');
struct1 = memmapfile(f1,'Format',{'int16' datasize 'Data'});
ySlice  = mean(struct1.Data.Data, 3);
%% Plot structural image
h = figure;
maximize_figure(h, OCT.acqui_info)
% Font Sizes
axisFontSize    = 16;
labelFontSize   = 18;
subplot(1,2,1)
colormap(gray);
% build z, r axis to display scaled data //EGC
rAxis = 0:OCT.recons_info.step(1):OCT.recons_info.step(1)*(OCT.recons_info.size(1) - 1);
zAxis = 0:OCT.recons_info.step(2):OCT.recons_info.step(2)*(OCT.recons_info.size(2) - 1);
imagesc(rAxis,zAxis,ySlice');
% title('Choose an ROI containing a vessel','FontSize',titleFontSize,'interpreter','none')
set(gca,'FontSize',axisFontSize)
ylabel([OCT.recons_info.type{2} ' [\mum]'],'FontSize',labelFontSize);
xlabel([OCT.recons_info.type{1} ' [\mum]'],'FontSize',labelFontSize);
% imcontrast
%% Save PNG
export_fig(fullfile(figsFolder, [OCT.acqui_info.base_filename 'struct']),'-png',gcf)
% ------------------------------------------------------------------------------


%% Load data from figs
OCTmat = 'F:\Edgar\Data\OCT_Results\2012-10-12 - Souris NC06\Souris NC06 - MCAR01\X\OCT.mat';
load(OCTmat)
hy = hgload('F:\Edgar\Data\OCT_Results\2012-10-12 - Souris NC06\Souris NC06 - MCAR01\Y\fig\ROI_pulse.fig');
hx = hgload('F:\Edgar\Data\OCT_Results\2012-10-12 - Souris NC06\Souris NC06 - MCAR01\X\fig\ROI_pulse.fig');
% delve further into the axes/titles/legends by calling
chx = get(hx,'Children');
chy = get(hy,'Children');
% Call the children of the first axis
lx = get(chx(1),'Children');
% call the 'Xdata' and 'Ydata' fields of the line to retrieve original data.
tx = get(lx,'Xdata');
pulseX = get(lx,'Ydata');
% Call the children of the first axis
ly = get(chy(1),'Children');
% call the 'Xdata' and 'Ydata' fields of the line to retrieve original data.
ty = get(ly,'Xdata');
pulseY = get(ly,'Ydata');
close(hy); close(hx);
systole_positionX = find(pulseX==max(pulseX));
systole_positionY = find(pulseY==max(pulseY));
diastole_positionX = find(pulseX==min(pulseX));
diastole_positionY = find(pulseY==min(pulseY));
speed_change_variabilityX = std(abs(pulseX))/mean(abs(pulseX));
speed_change_variabilityY = std(abs(pulseY))/mean(abs(pulseY));
speed_change_X = (max(abs(pulseX)) - min(abs(pulseX))) / max(abs(pulseX));
speed_change_Y = (max(abs(pulseY)) - min(abs(pulseY))) / max(abs(pulseY));

%% Plot X-Y profiles on same plot
axisFontSize = 22;
labelFontSize = 24;
limPercent = 0.03;
varPosY = 20;
varPosX = 20;
lWidth = 6;
% Xcolor = [160 82 45]./255;
% Ycolor = [255 140 0]./255;
Xcolor = 'k';
Ycolor = 'r';
h = figure;
% maximize_figure(h, OCT.acqui_info)
set(h, 'color', 'w')

[haxes, hlineX, hlineY] = plotyy(tx,pulseX,ty,pulseY);
set(haxes,'FontSize',axisFontSize)
xlabel('Time in cardiac cycle [ms]','FontSize',labelFontSize);
axes(haxes(1));
ylabel('X Speed [mm/s]','FontSize',labelFontSize);
axes(haxes(2));
ylabel('Y Speed [mm/s]','FontSize',labelFontSize);
% X speed axis
set(haxes(1), 'Ylim', [(1-limPercent)*min(pulseX) (1+limPercent)*max(pulseX)],...
    'Ycolor', Xcolor, 'Ytick', [min(pulseX) mean(pulseX) max(pulseX)],...
    'YtickLabel', {sprintf('%0.2f',min(pulseX)) sprintf('%0.2f',mean(pulseX)) sprintf('%0.2f',max(pulseX))})
% Y speed axis
set(haxes(2), 'Ylim', [(1-limPercent)*min(pulseY) (1+limPercent)*max(pulseY)],...
    'Ycolor', Ycolor, 'Ytick', [min(pulseY) mean(pulseY) max(pulseY)],...
    'YtickLabel', {sprintf('%0.2f',min(pulseY)) sprintf('%0.2f',mean(pulseY)) sprintf('%0.2f',max(pulseY))})
% Time axis
set(haxes, 'Xlim', [min(tx) max(tx)])

% Set line properties
set(hlineX, 'LineStyle', '-', 'Color', Xcolor, 'LineWidth', lWidth)
set(hlineY, 'LineStyle', '-.', 'Color', Ycolor, 'LineWidth', lWidth)

% legend
legend({'Y Speed [mm/s]'; 'X Speed [mm/s]'}, 'Location', 'NorthWest');

axes(haxes(1));
hold on
% Pulsatility profile X
plot(tx, mean(pulseX)*ones(size(tx)), 'LineStyle', '-', 'Color', Xcolor, 'LineWidth', lWidth-2)
% X Speed change max/min
plot([tx(systole_positionX) tx(systole_positionX)],...
    [pulseX(diastole_positionX) pulseX(systole_positionX)],...
    'LineStyle', ':', 'Color', Xcolor, 'LineWidth', lWidth-2);
plot([tx(diastole_positionX) tx(systole_positionX)],...
    [pulseX(diastole_positionX) pulseX(diastole_positionX)],...
    'LineStyle', ':', 'Color', Xcolor, 'LineWidth', lWidth-2);
% Variablity X
plot([tx(systole_positionX+varPosX) tx(systole_positionX+varPosX)],...
    [mean(pulseX)+speed_change_variabilityX mean(pulseX)-speed_change_variabilityX],...
    'LineStyle', '-', 'Color', Xcolor, 'LineWidth', lWidth-2);
% Annotations X
text(tx(systole_positionX+varPosX-2),mean(pulseX)-speed_change_variabilityX,...
    sprintf('%0.1f%%',100*speed_change_variabilityX),'FontSize',labelFontSize,'Color',Xcolor)
text(tx(systole_positionX-5), 1.02*mean(pulseX),...
    sprintf('%0.1f%%',100*speed_change_X),'FontSize',labelFontSize,'Color',Xcolor)
% Arrow X
annotation('arrow',[0.5 0.6],[0.52 0.62],'Color', Xcolor, 'LineWidth', lWidth-2)
annotation('arrow',[0.3 0.4],[0.52 0.62],'Color', Xcolor, 'LineWidth', lWidth-2)

axes(haxes(2));
hold on
% Pulsatility profile Y
plot(ty, mean(pulseY)*ones(size(ty)), 'LineStyle', '-', 'Color', Ycolor, 'LineWidth', lWidth-2)
% Y Speed change max/min
plot([ty(systole_positionY) ty(systole_positionY)],...
    [pulseY(diastole_positionY) pulseY(systole_positionY)],...
    'LineStyle', ':', 'Color', Ycolor, 'LineWidth', lWidth-2);
plot([ty(diastole_positionY) ty(systole_positionY)],...
    [pulseY(diastole_positionY) pulseY(diastole_positionY)],...
    'LineStyle', ':', 'Color', Ycolor, 'LineWidth', lWidth-2);
% Variablity Y
plot([ty(systole_positionY+varPosY) ty(systole_positionY+varPosY)],...
    [mean(pulseY)+speed_change_variabilityY mean(pulseY)-speed_change_variabilityY],...
    'LineStyle', '-', 'Color', Ycolor, 'LineWidth', lWidth-2);
% Annotations Y
text(ty(systole_positionY+varPosY+2),mean(pulseY)-speed_change_variabilityY,...
    sprintf('%0.1f%%',100*speed_change_variabilityY),'FontSize',labelFontSize,'Color',Ycolor)
text(ty(systole_positionY+2), 1.02*mean(pulseY),...
    sprintf('%0.1f%%',100*speed_change_Y),'FontSize',labelFontSize,'Color',Ycolor)
% Arrow X
% annotation('arrow',[0.55 0.6],[0.60 0.65],'Color', Ycolor, 'LineWidth', lWidth-2)
% annotation('arrow',[0.55 0.5],[0.60 0.55],'Color', Ycolor, 'LineWidth', lWidth-2)


%% Save PNG
export_fig(fullfile(figsFolder, [OCT.acqui_info.base_filename 'speed_profile']),'-png',gcf)
% ------------------------------------------------------------------------------

% EOF

