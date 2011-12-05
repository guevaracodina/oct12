function [doppler_angle]=doppler_processing(gamma,filter_kernel,window,mask,method)
%This will obtain the doppler frequency of a 2D complex information slice
%it uses a filter_kernel to high pass filter the static tissue contribution
% Syntax : [doppler_angle_norm]=doppler_processing(gamma_real,gamma_imag,filter_kernel,window,mask)
%       gamma_real and gamma_imag are the real and imaginary parts of the
%       data obtained from the fft operation
%       - filter_kernel is the filter applied to remove the doppler shift
%       from stationnary tissue
%       - window is the window over which the angle is calculated (it must be
%       a M by N 2D array of ones
%       - mask is a mask that has the same dimensions of the final Doppler
%       image that will threshold where there is Doppler Data. It has
%       values of ones and zeros.



% Bulk phase correction
a=gamma(:,1:end-1).*conj(gamma(:,2:end));
phi=angle(sum(a,1));
gamma(:,2:end)=gamma(:,2:end)*repmat(exp(j*phi),[length(gamma) 1]);


mask=double(mask);
filter_kernel=reshape(filter_kernel,1,length(filter_kernel));

% Load filter_kernel_default
use_fft = 1;
if use_fft
    OPTIONS.GPU = 0;
    OPTIONS.Power2Flag = 0;
    %OPTIONS.Brep = 1;
    M = convnfft(gamma, repmat(filter_kernel,size(gamma,1),1), 'same', 2,OPTIONS);
    %M = convnfft(gamma, filter_kernel, 'same', 2,OPTIONS);
    
    %     tf = fft([zeros(1,11) filter_kernel zeros(1,11)]);
    %     %tf = fft(filter_kernel);
    %     gf = fft(gamma,[],2);
    %     mf = gf.*repmat(tf,size(gf,1),1);
    %     %mf = gf.*repmat([zeros(1,11) tf zeros(1,11)],size(gf,1),1);
    %     M = ifft(mf,[],2);
else
    M = convn(gamma,filter_kernel,'same');
end
imghpf=abs(M); % A vérifier
if use_fft
    OPTIONS.GPU = 0;
    OPTIONS.Power2Flag = 0;
    imglpf = abs(convnfft(gamma, repmat(ones(size(filter_kernel)),[length(gamma) 1]), 'same', 2,OPTIONS));
else
    imglpf=abs(convn(gamma,ones(size(filter_kernel))));
end

%     hpftot = convn(imghpf,ones(size(h)),'same');
%     hpftotmat = cat(3,hpftotmat,hpftot(:,1:round(length(h)/2):end));
%     lpftot = convn(imglpf,ones(size(h)),'same');
%     lpftotmat = cat(3,lpftotmat,lpftot(:,1:round(length(h)/2):end));

% if(method==0)
%     A=M(:,1:end-1).*conj(M(:,2:end));
%
%     window=double(window);
%     if use_fft
%         OPTIONS.Brep = 0;
%         A_sum = convnfft(A,window,'same',1:2,OPTIONS);
%     else
%         A_sum=convn(A,window,'same');
%     end
%     A_sum=A_sum.*mask(:,1:end-1);
%
%     doppler_angle=angle(A_sum);
%     doppler_angle_original=doppler_angle;
%     doppler_angle_unwrapped=unwrap(doppler_angle);
%     difference=sum(doppler_angle_unwrapped~=doppler_angle);
%     positions_to_unwrap=find(difference~=0);
%
%     for i=positions_to_unwrap
%         %This is a more careful way of unwrapping that makes sure the operation
%         %is done in both directions
%         doppler_angle(:,i)=unwrap_single_line(doppler_angle(:,i));
%     end
%     %This will give the result file the same dimension as the input file
%     doppler_angle=[doppler_angle(:,1) doppler_angle/2]...
%         +[doppler_angle/2 doppler_angle(:,end)];
%
% else
end