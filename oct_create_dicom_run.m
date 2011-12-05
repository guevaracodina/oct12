function out = oct_create_dicom_run(job)

rev = '$Rev$'; 

addpath(['.' filesep 'dicom_toolbox'])

% Reference from previous computation.
OCTmat=job.OCTmat;

% Loop over acquisitions
for acquisition=1:size(OCTmat,1)
    
    load(OCTmat{acquisition});
    recons_info = OCT.recons_info;
    
    if(job.do_struct)
        filename=recons_info.struct_recons.filename;
        tmp=C_OCTVolume([0 0 0]);
        tmp.openint16(filename);
        savedir=fileparts(filename);
        mkdir(savedir,'dicom_struct')
        info=struct;
        % Make random series number
        SN=round(rand(1)*1000);
        % Get date of today
        info.SeriesNumber=SN;
        info.AcquisitionNumber=SN;
        info.StudyDate=[datestr(now,'yyyy') datestr(now,'mm') datestr(now,'dd')];;
        info.StudyID=num2str(SN);
        info.PatientID=num2str(SN);
        info.PatientPosition='HFS';
        info.AccessionNumber=num2str(SN);
        info.StudyDescription=['StudyMAT' num2str(SN)];
        info.SeriesDescription=['StudyMAT' num2str(SN)];
        info.Manufacturer='LIOM OCT';
        info.SliceThickness=OCT.recons_info.step(3);
        info.PixelSpacing=OCT.recons_info.step(1:2);
        info.SliceLocation=0;
        tmp_vol=int16(tmp.data);
        dicom_write_volume(tmp_vol,[savedir, filesep, 'dicom_struct', filesep, 'Struct'], OCT.recons_info.step, info)
    end
    if(job.do_doppler)
        filename=recons_info.dop_recons.filename;
        tmp=C_OCTVolume([0 0 0]);
        tmp.openint16(filename);
        savedir=fileparts(filename);
        mkdir(savedir,'dicom_doppler')
        info=struct;
        % Make random series number
        SN=round(rand(1)*1000);
        % Get date of today
        info.SeriesNumber=SN;
        info.AcquisitionNumber=SN;
        info.StudyDate=[datestr(now,'yyyy') datestr(now,'mm') datestr(now,'dd')];;
        info.StudyID=num2str(SN);
        info.PatientID=num2str(SN);
        info.PatientPosition='HFS';
        info.AccessionNumber=num2str(SN);
        info.StudyDescription=['StudyMAT' num2str(SN)];
        info.SeriesDescription=['StudyMAT' num2str(SN)];
        info.Manufacturer='LIOM OCT';
        info.SliceThickness=OCT.recons_info.step(3);
        info.PixelSpacing=OCT.recons_info.step(1:2);
        info.SliceLocation=0;
        tmp_vol=int16(tmp.data);
        dicom_write_volume(tmp_vol,[savedir, filesep, 'dicom_doppler', filesep, 'Doppler'], OCT.recons_info.step, info)
    end
    if(job.do_ecg)
        filename=recons_info.ecg_recons.filename;
        tmp=C_OCTVolume([0 0 0]);
        tmp.openint16(filename);
        savedir=fileparts(filename);
        mkdir(savedir,'dicom_ecg_gated')
        info=struct;
        % Make random series number
        SN=round(rand(1)*1000);
        % Get date of today
        info.SeriesNumber=SN;
        info.AcquisitionNumber=SN;
        info.StudyDate=[datestr(now,'yyyy') datestr(now,'mm') datestr(now,'dd')];;
        info.StudyID=num2str(SN);
        info.PatientID=num2str(SN);
        info.PatientPosition='HFS';
        info.AccessionNumber=num2str(SN);
        info.StudyDescription=['StudyMAT' num2str(SN)];
        info.SeriesDescription=['StudyMAT' num2str(SN)];
        info.Manufacturer='LIOM OCT';
        info.SliceThickness=OCT.recons_info.step(3);
        info.PixelSpacing=OCT.recons_info.step(1:2);
        info.SliceLocation=0;
        tmp_vol=int16(tmp.data);
        dicom_write_volume(tmp_vol,[savedir, filesep, 'dicom_ecg_gated', filesep, 'ECG'], OCT.recons_info.step, info)
    end
    
    
end
out.OCTmat = OCTmat;
end