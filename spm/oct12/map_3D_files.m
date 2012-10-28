function [Structure,Doppler1,acqui_info,recons_info]=map_3D_files(OCTmat)
%This function will generate the memmapfile handle for .struct3D and
%.dop13D files it will also load the information on the acquisition and
%reconstruction of the target data set
%_______________________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

if ~exist(OCTmat, 'file')
    [pathname,filename]=prompt_acquisition('Select !1! OCT.mat file to map');
    OCTmat=[pathname{1} filename{1}];
end

load(OCTmat)

if isfield(OCT, 'acqui_info')
    acqui_info = OCT.acqui_info;
end

if isfield(OCT, 'recons_info')
    recons_info = OCT.recons_info;
    datasize = OCT.recons_info.size;
    % --------------------------------------------------------------------------
    % Structural reconstruction
    % --------------------------------------------------------------------------
    if isfield(OCT.recons_info, 'struct_recons')
        D = dir(OCT.recons_info.struct_recons.filename);
        if prod(datasize)*2>D.bytes
            Structure = [];
        else
            Structure = memmapfile(OCT.recons_info.struct_recons.filename,...
                'Format',{'int16' datasize 'Data'});
        end
    else
        Structure = [];
    end
    % --------------------------------------------------------------------------
    % Doppler reconstruction
    % --------------------------------------------------------------------------
    if isfield(OCT.recons_info, 'dop_recons')
        D = dir(OCT.recons_info.dop_recons.filename);
        if prod(datasize)*2>D.bytes
            Doppler1 = [];
        else
            Doppler1 = memmapfile(OCT.recons_info.dop_recons.filename,...
                'Format',{'int16' datasize 'Data'});
        end
    else
        Doppler1 = [];
    end
    % --------------------------------------------------------------------------
else
    Doppler1    = [];
    Structure   = [];
end




assignin('base','Structure',Structure)
assignin('base','Doppler1',Doppler1)
assignin('base','acqui_info',acqui_info)
assignin('base','recons_info',recons_info)

% EOF
