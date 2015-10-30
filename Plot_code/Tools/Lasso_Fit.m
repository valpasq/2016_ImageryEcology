function [fit_cft,rmse,lambda,yhat]=Lasso_Fit(x,y)
% Using lasso for timeseries modeling (01/27/2013)
% Auto Trends and Seasonal Fit between breaks
% INPUTS:
% x - Julian day [1; 2; 3];
% y - predicted reflectances [0.1; 0.2; 0.3];
%
% OUTPUTS:
% fit_cft - fitted coefficients;
% General model TSModel:
% f(x) =  a0 + b0*x + a1*cos(x*w) + b1*sin(x*w)

%% INPUTS - must match inputs for autoTSPred
n=length(x); % number of clear pixels

w=2*pi/(365.25*10); % annual cycle
df=10; %degree of freedom

% Set coefficients for harmonic functions
h1=1; % annual cycle - required
h2=5;
h3=10;
h4=20;

% 2 - 6 month cycles
% 3 - 4 month cycles
% 4 - 3 month cycles
% 6 - 2 month cycles
% 12 - 1 month cycles

%%% TSFit
% build X - Fourier harmonics
X=zeros(n,df-1);

%Slope - linear trend
X(:,1)=x;

% Harmonic 1
X(:,2)=cos(h1*w*x);
X(:,3)=sin(h1*w*x);

% Harmonic 2
X(:,4)=cos(h2*w*x);
X(:,5)=sin(h2*w*x);

% Harmonic 3
X(:,6)=cos(h3*w*x);
X(:,7)=sin(h3*w*x);

% Harmonic 4
X(:,8)=cos(h4*w*x);
X(:,9)=sin(h4*w*x);

% Generate fit
NumLambda=100;

% CROSS-VALIDATE
%crossnum=4; % k-fold cross validation
%
%[B,FitInfo]=lassoglm(X,y,'normal','CV',crossnum,...
%    'NumLambda',NumLambda);

%fit_cft = zeros(df,1);
%a0=FitInfo.Intercept(FitInfo.IndexMinDeviance);
%bvals=B(:,FitInfo.IndexMinDeviance);
%curr_cft=[a0;bvals];
%fit_cft(1:length(curr_cft)) = curr_cft;
%lambda=FitInfo.Lambda(FitInfo.IndexMinDeviance);

% W/O CROSS VALIDATION
[B,FitInfo]=lassoglm(X,y,'normal',...
    'NumLambda',NumLambda);

fit_cft = zeros(df,1);
IndexMinDev=find(FitInfo.Deviance==min(FitInfo.Deviance));
a0=FitInfo.Intercept(IndexMinDev);
bvals=B(:,IndexMinDev);
curr_cft=[a0;bvals];
fit_cft(1:length(curr_cft)) = curr_cft;
lambda=FitInfo.Lambda(IndexMinDev);


yhat=Lasso_Pred(x,fit_cft);


%rmse=norm(y-yhat)/sqrt(n-df);  % original CCDC calculation

% The following seem to all produce the same result:
rmse=norm(y-yhat)/sqrt(n);
%rmse=sqrt(mean((y-yhat).^2));
%rmse=sqrt(sum((y-yhat).^2)/numel(y));





end
