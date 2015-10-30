function [clrx,clry,idgood] = CCDC_XYMask1(num_t,line_t,nbands,sdate)
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
% If NDSI > 0.15, NIR > 1100 and Green > 1000 
% (and is "clear") --> set to snow

% line_m((line_t(:,2)-line_t(:,5))./(line_t(:,2)+line_t(:,5))>0.15&...
%    line_t(:,4)>1100&line_t(:,2)>1000&line_m<=1) = 3;

% CEHOLDEN change: FMask 3.2 snow mask -- 
line_m((line_t(:,2) - ... % B2 - B5
        line_t(:,5)) ./ ... % over
        (line_t(:,2) + ... % B2 + B5
        line_t(:,5)) > 0.15 & ... % NDSI > 0.15
        line_t(:,4) > 1100 & ... % B4 > 1100
        line_t(:,2) > 1000 & ... % B2 > 1000
        line_m <= 1) = 3; % and is already clear --> set to snow

%% Find Good IDs

% SNOW MASKED
% clear land or water pixels (remove snow mask)
idclear = line_m == 0|line_m == 1;

%SNOW NOT MASKED
%idclear = line_m ==0| line_m == 1| line_m == 3;

% RESULT - idgood: pixels that are clear and within physical range 
idgood = idclear & idrange;

% Find clear observations from mask output
clrx=sdate(idgood);
clry=line_t(idgood,1:nbands-1);


end

