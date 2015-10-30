function [idgood,line_m] = CCDC_XYMask(num_t,line_t,nbands)
% XYMask Find clear pixels for CCDC analysis
%   CCDC run for places where more than 50% of images have data
%   Remove clouds, cloud shadows, snow -- Use only clear observations for
%   model fit

%% INITIALIZE mask vector
line_m=line_t(:,nbands);

%% CHECK that at least 50% of images have data
% CEHOLDEN change: code upgrade to skip pixels with <50% of data
% Only run CCDC for places where more than 50% of images has data
idexist = line_m < 255;
overlap_pct = 100 * sum(idexist) / num_t;
    if overlap_pct < 50
    fprintf('Less than 50%% of images have data (%.2f%%)!\n',overlap_pct);
    return;
    else
    fprintf('More than 50%% of images have data (%.2f%%)!\n',overlap_pct);
    end

%% MASKING - create vector of clear surface reflectance observations
% Pixel values should follow physical rules
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

% improved snow mask == 3
%line_m((line_t(:,2)-line_t(:,5))./(line_t(:,2)+line_t(:,5))>0.15&...
%    line_t(:,4)>1100&line_t(:,2)>1000&line_m<=1) = 3;

% CEHOLDEN change: FMask 3.2 snow mask
% improved snow mask (will be removed if using Fmask 3.2 version 
line_m((line_t(:,2) - ... % B2 - B5
        line_t(:,5)) ./ ... % over
        (line_t(:,2) + ... % B2 + B5
        line_t(:,5)) > 0.15 & ... % NDSI > 0.15
        line_t(:,4) > 1100 & ... % B4 > 1100
        line_t(:,2) > 1000 & ... % B2 > 1000
        line_m <= 1) = 3; % and is already clear --> set to snow

% clear land or water pixels (remove snow mask)
idclear = line_m == 0|line_m == 1;

% RESULT - idgood: pixels that are clear and within physical range 
idgood = idclear & idrange;

end

