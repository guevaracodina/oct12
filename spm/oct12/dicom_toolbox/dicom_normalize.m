function V=dicom_normalize(V,info)
V=single(V);
% These Attributes shall be used only for Images with Photometric Interpretation (0028,0004)
% values of MONOCHROME1 and MONOCHROME2

V=V*info.RescaleSlope + info.RescaleIntercept;

% Treshold_min=info.WindowCenter- 0.5 - (info.WindowWidth-1)/2;
% Treshold_max=info.WindowCenter- 0.5 + (info.WindowWidth-1)/2;
% Scaling=((x-(info.WindowCenter-0.5))/(info.WindowWidth-1)+0.5)*(ymax-ymin)+ymin; 
% 
% if ( x <= )
%     y = ymin;
% elseif (x>c-0.5 + (w-1)/2), 
%     y = ymax;
% else
%     y=((x-(c-0.5))/(w-1)+0.5)*(ymax-ymin)+ymin; 
% end
