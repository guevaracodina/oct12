function [gamma_abs,gamma_angle]=...
    frame2gamma(frame,reference,wavenumbers,recons_info, self_ref)
% This function will

frame=double(frame);
[m,n]=size(frame);

if( self_ref )
    ref_2D=repmat(mean(frame,2),[1 n]);
else
    ref_2D=repmat(reference,[1 n]);
end

%% Remove the reference

frame=(frame-ref_2D)./ref_2D;

%% Interpolate the data on the wavenumber space
frame=interp1(wavenumbers.pixels,frame,wavenumbers.linear,'linear'); %I tried to use interp1q, but this is faster

%% This will apply a Window to the data
frame=frame.*repmat(hann(m),[1 n]);

%%
if( recons_info.dispersion_enable )
    [frame]=dispersion_compensation(frame,wavenumbers,recons_info.dispersion.a);
end

%% This will do the ifft of the Data
frame=ifft(frame,[],1);

% This extracts the real and imaginary parts
gamma_abs=abs(frame(1:end/2,:));
gamma_angle=angle(frame(1:end/2,:));

end
