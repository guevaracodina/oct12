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
fprintf('Work in progress...\nEGC\n')
out.OCTmat = job.OCTmat;
return
% ------------------------------------------------------------------------------

rev = '$Rev$'; %#ok

% Reference from previous computation.
OCTmat = job.OCTmat;

dataFile = fullfile(job.save_data_dir{1},'diameter.csv');
fid = fopen(dataFile, 'w');
% Header of .csv file
fprintf(fid,'Name,  Diameter(µm)\n');

% Loop over acquisitions (FOVs)
for acquisition = 1:size(OCTmat,1)
    try
        load(job.OCTmat{acquisition})
        if isfield(OCT.jobsdone, 'ecg_doppler')
            % Retrieve ECG-gated Doppler images and compute vessel diameter
            vessel_diameter = get_ecg_doppler_vessel_diam(OCT);
            % Append data to .csv file
            fprintf(fid, '%s , %6.4f \n', OCT.acqui_info.base_filename, vessel_diameter);
            save(fullfile(OCT.output_dir, 'OCT.mat'),'OCT');
        else
            fprintf('ECG-gated pulsatility data not available for %s\n', OCT.acqui_info.base_filename);
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

function vessel_diameter = get_ecg_doppler_vessel_diam(OCT)
% Retrieve ECG-gated Doppler images and compute vessel diameter
dir_fig = fullfile(OCT.output_dir,'fig');
figName = fullfile(dir_fig,'ROI_pulse.fig');
h = open(figName);
% New figure position (figure h is in normalized units)
newPosition = [0.5 0.0074 1.0000 0.9639];
% Normalized units
set(h, 'Units', 'normalized');
% Maximize figure
set(h, 'OuterPosition', newPosition);
% Change shape of the pointer
set(h,'Pointer','crosshair')
% Go to first subplot
subplot(121)
% Get axes handles
hAxes = gca;
% Get horizontal axis
R = get(get(hAxes,'Children'),'XData');
% Find middle of the image
midR = max(R)/2;
% Go to interactive window
h2 = spm_figure('GetWin', 'Interactive');
% Clear interactive figure
spm_figure('Clear', 'Interactive');
% Display title
spm_input(sprintf('Draw vessel diameter %s',OCT.acqui_info.base_filename),'-1','d');
lineCount = 2;

% ------------------------------------------------------------------------------
% Horizontal diameter
% ------------------------------------------------------------------------------
% Go to Doppler figure
figure(h);
% creates a draggable Distance tool on the ECG-gated Doppler image
hDist = imdistline(hAxes,[0.8*midR 1.2*midR], [300 300]);
% Retrieve distance information and control other aspects of Distance
% tool behavior
api = iptgetapi(hDist);
% Prevent distance tool from being dragged outside the image
fcn = makeConstrainToRectFcn('imline', get(hAxes,'XLim'), get(hAxes,'YLim'));
api.setDragConstraintFcn(fcn);
% Sets color to black
api.setColor('k');
% Go to interactive window
figure(h2);
spm_input('Draw horizontal diameter of current vessel',lineCount,'d');
lineCount = lineCount + 1;
spm_input('Press OK when ready',lineCount,'b',{'OK' 'No'},[true false], true);
lineCount = lineCount + 1;
% Get horizontal diameter (already in um)
vesselDiam(1) = api.getDistance();
% Delete distance tool
api.delete();
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Vertical diameter
% ------------------------------------------------------------------------------
% Go to Doppler figure
figure(h);
% creates a draggable Distance tool on the ECG-gated Doppler image
hDist = imdistline(hAxes, [midR midR], [250 350]);
% Retrieve distance information and control other aspects of Distance tool
% behavior
api = iptgetapi(hDist);
% Prevent distance tool from being dragged outside the image
fcn = makeConstrainToRectFcn('imline', get(hAxes,'XLim'), get(hAxes,'YLim'));
api.setDragConstraintFcn(fcn);
% Sets color to black
api.setColor('k');
% Go to interactive window
figure(h2);
spm_input('Draw vertical diameter of current vessel',lineCount,'d');
lineCount = lineCount + 1;
spm_input('Press OK when ready',lineCount,'b',{'OK' 'No'},[true false], true);
% Get vertical diameter (already in um)
vesselDiam(2) = api.getDistance();
% Delete distance tool
api.delete();
% ------------------------------------------------------------------------------

% Close figure
close(h)
% Compute vessel diameter
vessel_diameter = max(abs(vesselDiam)); % In um

end
% EOF
