function [clrx,clry] = CCDC_XYMask1(num_t,line_t,nbands,sdate)
%XYMASK1 Find clear pixels for CCDC analysis based on physical contraints
% and Fmask results. Step 1 operates at pixel level within an individual
%   image.

%% INITIALIZE mask vector
line_m=line_t(:,nbands);

%% CHECK that at least 50% of images have data
% CEHOLDEN change: code upgrade to skip pixels with <50% of data
% Only run CCDC for places where more than 50% of images has data
idexist = line_m < 255;
overlap_pct = 100 * sum(idexist) / num_t;
    if overlap_pct < 50
    return;
    else
    end

%% MASK -  Pixel values should follow physical rules
% Surface reflectance (Bands 1-6) should be  greater than 0, but less than
% 10,000; Thermal band data (band 7) should be greater than -8,900 but less
% than 5,800.
idrange=line_t(:,1)>0&line_t(:,1)<10000&...
    line_t(:,2)>0&line_t(:,2)<10000&...
    line_t(:,3)>0&line_t(:,3)<10000&...
    line_t(:,4)>0&line_t(:,4)<10000&...
    line_t(:,5)>0&line_t(:,5)<10000&...
    line_t(:,6)>0&line_t(:,6)<10000&...
    line_t(:,7)>-8900&line_t(:,7)<5800;

%% MASK - Improved snow mask (Fmask/NDSI)
% Kepp clear land (0), clear water (1), snow(3)
% clear land or water pixels 
idclear = line_t(:,nbands) == 0|line_t(:,nbands) == 1 | line_t(:,nbands)==3;

% RESULT - idgood: pixels that are clear and within physical range 
idgood = idclear & idrange;

% Find clear observations from mask output
clrx=sdate(idgood);
clry=line_t(idgood,1:nbands-1);


end

