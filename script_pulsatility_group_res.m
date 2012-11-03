%% Script group results for pulsatility experiments
addpath(genpath('D:\spm8\toolbox\oct12'))
addpath(genpath('D:\spm8\toolbox\pat12'))
addpath(genpath('D:\Edgar\ssoct\Matlab'))
figsFolder = 'D:\Edgar\Documents\Dropbox\Docs\Carotid';
load('D:\spm8\toolbox\oct12\doppler_color_map.mat')
load('D:\Edgar\Documents\Dropbox\Docs\Carotid\group_data.mat')

%% Retrieve data
% Means
y = [mean([NC_inc  NC_var ]) mean([CC_inc CC_var])];
% Swap columns 2 & 3
% y(:,[2,3]) = y(:,[3,2]);
y = reshape(y,[2 2]);
% SEM (std/sqrt(N))
e = [(std([NC_inc  NC_var ]))./sqrt(numel(NC_var)) (std([CC_inc CC_var]))./sqrt(numel(CC_var))];
% Swap columns 2 & 3
% e(:,[2,3]) = e(:,[3,2]);
e = reshape(e,[2 2]);

%% Plot error bars
% Font Sizes
titleFontSize   = 24;
axisFontSize    = 20;
labelFontSize   = 24;
legendFontSize  = 20;
% starFontSize    = 32;
figure; set(gcf,'color','w')
% colormap
colormap([0.5 0.5 0.5; 1 1 1])
% Custom bar graphs with error bars (1st arg: error)
barwitherr(e, y)
title('Pulsatility metric','interpreter','none','FontSize',titleFontSize)
set(gca,'FontSize',axisFontSize)
ylabel('%','FontSize',labelFontSize)
set(gca,'XTickLabel',{'Blood speed change', 'Variability from mean'},'FontWeight', 'b','FontSize',labelFontSize)
legend({'Controls NaCl' 'CaCl_2 induced'},'FontSize',legendFontSize)

%% Save PNG
export_fig(fullfile(figsFolder,'pulsatility_metrics'),'-png',gcf)
