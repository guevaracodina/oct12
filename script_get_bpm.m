%% Gets average cardiac bpm for several subjects at once
% Top folder containing all subjects results(change as needed)
resFolder = 'F:\Edgar\Data\OCT_Results\';

[subjectList, sts] = cfg_getfile(Inf,'dir','Select subjects',[], resFolder, '^[0-9].*CC.*');
bpm_avg = zeros(size(subjectList));
if sts
    for iSubject = 1:numel(subjectList)
        bpm_avg(iSubject) = oct_get_avg_bpm_per_subject(subjectList{iSubject});
    end
end
