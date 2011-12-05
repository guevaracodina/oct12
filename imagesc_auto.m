function imagesc_auto(im)

imgmin = nanmean(min(im));
imgmax = nanmean(max(im));
if isnan(imgmin) || isnan(imgmax) imagesc(im);
else
    imagesc(im,[imgmin,imgmax]);
end
