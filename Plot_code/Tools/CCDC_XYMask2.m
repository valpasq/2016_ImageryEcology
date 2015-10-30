function [timeseries,cloudx,cloudy,rfit_B2,rfit_B5] = CCDC_XYMask2(alldatesvec,timeseries,nbands)
%XYMask2 Removes residulal cloud/shadows/snow. Step 2 operates the athe
%pixel level using multi-temporal fitting

%% MASK - Multitemporal cloud masking

% Thresholds for cloud, shadow, and snow detection
T_B2 = 2*nanstd(timeseries(:,2)); 
T_B5 = 2*nanstd(timeseries(:,5));

span = 22; % Smoothing parameter = ~365/16
 
% Intialize vectors to store cloudy data
nobs=length(alldatesvec);
cloudx=NaN(nobs,1);
cloudy=NaN(nobs,nbands-1);

% Multitemporal cloud/snow detection (green)
rfit_B2 = smooth(alldatesvec,timeseries(:,2),span,'lowess');
% Multitemporal shadow/snow shadow detection (SWIR)
rfit_B5 = smooth(alldatesvec,timeseries(:,5),span,'lowess');


for i=1:length(alldatesvec)
    % If B2/B5 are outside threshold
    if rfit_B2(i)-timeseries(i,2) < -T_B2 ||...
    rfit_B5(i)-timeseries(i,5) > T_B5;

    % Assign data value to cloud vectors for plot
    cloudx(i)=alldatesvec(i);
    cloudy(i,:)=timeseries(i,:);
    
    % Replace time series data value with NaN
    timeseries(i,:)=-9999;
    end
end


end

