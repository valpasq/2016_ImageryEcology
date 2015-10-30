function [alldatesvec,timeseries] = CCDC_RegTS(sdate,clrx,clry,nbands)
%RegTS This function regularizes the the time series into 8-day intervals
%(minimum repeat time over full Landsat history). 

% Create time series with 8-day spacing
startdate=min(sdate);
enddate=max(sdate);
alldatesvec=startdate:8:enddate;
alldatesvec=transpose(alldatesvec);
nobs=length(alldatesvec);

% Find dates with clear observations
dateexist=ismember(alldatesvec,clrx);

% Initialize time series matrix to store clear observations
timeseries=zeros(nobs,nbands-1);

% For clear dates, pull reflectance values, otherwise NaN
for i=1:length(alldatesvec)
    if dateexist(i)==0
        timeseries(i,:)=NaN;
    elseif dateexist(i)==1
        date=alldatesvec(i);
        pos=find(clrx==date);
        timeseries(i,:)=clry(pos,:);
    end
end

end




