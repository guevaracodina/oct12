%% Script map reconstructed Doppler & Structural files
addpath(genpath('D:\spm8\toolbox\oct12'))
addpath(genpath('D:\spm8\toolbox\pat12'))
% Load OCT matrix
OCTmat = 'E:\Edgar\Data\OCT_Results\2012-10-17 - Souris CC08\Souris CC08 - SSL01\3D\OCT.mat';
load(OCTmat)
load('D:\spm8\toolbox\oct12\doppler_color_map.mat')
% %%
% [Structure,Doppler1,acqui_info,recons_info] = map_3D_files(OCTmat);
% %% Display slices
% figure; set (gcf, 'color', 'w')
% colormap(doppler_color_map)
% minVal = min(Doppler1.Data.Data(:));
% maxVal = max(Doppler1.Data.Data(:));
% for iFrames = 1:recons_info.size(3),
%     imagesc(squeeze(Doppler1.Data.Data(:,:,iFrames))', [minVal maxVal]);
%     axis image; colorbar
%     title(sprintf('Frame %d of %d',iFrames, recons_info.size(3)))
%     pause(0.05)
% end

%% map Doppler files
pathName = 'E:\Edgar\Data\OCT_Results\2012-10-17 - Souris CC08\Souris CC08 - SSL01\3D';
datasize = OCT.recons_info.size;
recons_info = OCT.recons_info;
f1 = fullfile(pathName,'Souris CC08 - SSL01 - 3D rev fast axis-400.dopl3D');
f2 = fullfile(pathName,'Souris CC08 - SSL01 - 3D rev fast axis-800.dopl3D');
f3 = fullfile(pathName,'Souris CC08 - SSL01 - 3D rev fast axis-1200.dopl3D');
f4 = fullfile(pathName,'Souris CC08 - SSL01 - 3D rev fast axis-1600.dopl3D');
f5 = fullfile(pathName,'Souris CC08 - SSL01 - 3D rev fast axis-2000.dopl3D');
f6 = fullfile(pathName,'Souris CC08 - SSL01 - 3D rev fast axis-2400.dopl3D');
f7 = fullfile(pathName,'Souris CC08 - SSL01 - 3D rev fast axis-2800.dopl3D');
f8 = fullfile(pathName,'Souris CC08 - SSL01 - 3D rev fast axis-3200.dopl3D');
f9 = fullfile(pathName,'Souris CC08 - SSL01 - 3D rev fast axis-3600.dopl3D');
Doppler1 = memmapfile(f1,'Format',{'int16' datasize 'Data'});
Doppler2 = memmapfile(f2,'Format',{'int16' datasize 'Data'});
Doppler3 = memmapfile(f3,'Format',{'int16' datasize 'Data'});
Doppler4 = memmapfile(f4,'Format',{'int16' datasize 'Data'});
Doppler5 = memmapfile(f5,'Format',{'int16' datasize 'Data'});
Doppler6 = memmapfile(f6,'Format',{'int16' datasize 'Data'});
Doppler7 = memmapfile(f7,'Format',{'int16' datasize 'Data'});
Doppler8 = memmapfile(f8,'Format',{'int16' datasize 'Data'});
Doppler9 = memmapfile(f9,'Format',{'int16' datasize 'Data'});

%% Test
frame1 = squeeze(Doppler1.Data.Data(:,:,1));
frame9 = squeeze(Doppler9.Data.Data(:,:,1));
diffFrame = frame1-frame9;
figure; set (gcf, 'color', 'w')
colormap(doppler_color_map)
imagesc(diffFrame)
axis image; colorbar

%% Average Doppler
meanDoppler = double(Doppler1.Data.Data) + double(Doppler2.Data.Data) + double(Doppler3.Data.Data)...
    + double(Doppler4.Data.Data) + double(Doppler5.Data.Data) + double(Doppler6.Data.Data)...
    + double(Doppler6.Data.Data) + double(Doppler7.Data.Data) + double(Doppler8.Data.Data);
meanDoppler = meanDoppler ./ 9;
meanDoppler = meanDoppler(:,20:220,:);
meanDoppler = permute(meanDoppler,[3 1 2]);

%% display single frame
figure; set (gcf, 'color', 'w')
colormap(doppler_color_map)
imagesc(squeeze(meanDoppler(:,:,200)))
axis image; colorbar

%%
offset = 0;
figure; set (gcf, 'color', 'w')
colormap(doppler_color_map)
minVal = min(meanDoppler(:));
maxVal = max(meanDoppler(:));
for iFrames = 1:recons_info.size(3),
    imagesc(meanDoppler(:,:,iFrames)+offset, [minVal maxVal]);
    axis image; colorbar
    title(sprintf('Frame %d of %d',iFrames, recons_info.size(3)))
    pause(0.05)
end

%% Save as NiFTi
dim = size(meanDoppler);
dt = [spm_type('float64') spm_platform('bigend')];
pinfo = ones(3,1);
% Affine transformation matrix: Scaling
matScaling = eye(4);
matScaling(1,1) = recons_info.step(3);
matScaling(2,2) = recons_info.step(1);
matScaling(3,3) = recons_info.step(2);
% Affine transformation matrix: Rotation
matRotation = eye(4);
% matRotation(1,1) = 0;
% matRotation(1,2) = 1;
% matRotation(2,1) = -1;
% matRotation(2,2) = 0;
% Final Affine transformation matrix: 
mat = matScaling*matRotation;

hdrDoppler = pat_create_vol(fullfile(pathName,'DopplerNIfTI.nii'), dim, dt, pinfo, mat, 1,...
        meanDoppler);
