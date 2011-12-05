function voxelvolume = dicom_read_volume(info)
% function for reading volume of Dicom files
%
% volume = dicom_read_volume(file-header)
%
% examples:
% 1: info = dicom_read_header()
%    V = dicom_read_volume(info);
%    imshow(squeeze(V(:,:,round(end/2))),[]);
%
% 2: V = dicom_read_volume('volume.dcm');

if(~isstruct(info)), info=dicom_read_header(info); end

voxelvolume=dicomread(info.Filenames{1});
nf=length(info.Filenames);

% Convert dicom images to voxel volume
h = waitbar(0,'Please wait...');
if(~isempty(strfind(info.ImageType,'MOSAIC')))
    if(isfield(info,'Private_0019_100a'))
        nSlices=single(info.Private_0019_100a);
    else
        sInfo=SiemensInfo(info);
        nSlices=single(sInfo.sSliceArray.lSize);
    end
    mimg=ceil(sqrt(nSlices));
    realwidth=single(info.Width)/mimg;
    realheight=single(info.Height)/mimg;
    
    % Initialize voxelvolume
    voxelvolume=zeros(realwidth,realheight,nSlices,nf,class(voxelvolume));
    for i=1:nf
        waitbar(i/nf,h)
        I=dicomread(info.Filenames{i});
        J=blockproc(I,[realwidth realheight],@(x)block(x));
        J=reshape(J,realwidth,realheight,[]);
        voxelvolume(:,:,:,i)=J(:,:,1:nSlices);
    end
else
    % Initialize voxelvolume
    if((size(voxelvolume,3)*size(voxelvolume,4))>1), return; end

    voxelvolume=zeros(info.Dimensions,class(voxelvolume));
    for i=1:nf,
        waitbar(i/nf,h)
        I=dicomread(info.Filenames{i});
        voxelvolume(:,:,i)=I;
    end
end
close(h);

function y=block(x)
y=x.data(:);


