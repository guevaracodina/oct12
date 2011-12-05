function No_of_A_lines_filtered=apply_filter_and_normalize(vol,filter,No_of_A_lines)
% This function will apply the filter defined by the 3D matrix filter onto
% the 3D global variable of the structure and the Doppler before they are
% normalized by the number of A-lines in each column. It will also
% filter the Number of A-lines by the filter defined by the sum along
% depths of the 3D filter. This new number of A-lines will then be used to
% normalize the 3D matrices

% keyboard

[m n o]=size(vol.Structure);

filter_2D=squeeze(sum(filter,2));
No_of_A_lines_filtered=imfilter(No_of_A_lines,filter_2D);

%This will go through every depth and apply the filter along the 2
%dimensions and normalize
for j=1:n
    vol.Structure(:,j,:)=imfilter(squeeze(vol.Structure(:,j,:)),...
        filter_2D)./No_of_A_lines_filtered;
    vol.Doppler(:,j,:)=imfilter(squeeze(vol.Doppler(:,j,:)),...
        filter_2D)./No_of_A_lines_filtered;
end