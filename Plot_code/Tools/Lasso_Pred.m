function outfity=Lasso_Pred(outfitx,fit_cft)
% Auto Trends and Seasonal Predict
% INPUTS:
% outfitx - Julian day [1; 2; 3];
% fit_cft - fitted coefficients;
% OUTPUTS:
% outfity - predicted reflectances [0.1; 0.2; 0.3];
% General model TSModel:
% f(x) =  a0 + b0*x + a1*cos(x*w) + b1*sin(x*w) 

%% INPUTS - must match inputs for autoTSFit
% Define annual cycle
w=2*pi/(365.25*10);

% Set coefficients for harmonic functions
h1=1;
h2=5;
h3=10;
h4=20;

%%
outfity=[ones(size(outfitx)),outfitx,...
        cos(h1*w*outfitx),sin(h1*w*outfitx),...
        cos(h2*w*outfitx),sin(h2*w*outfitx),...
        cos(h3*w*outfitx),sin(h3*w*outfitx),...
        cos(h4*w*outfitx),sin(h4*w*outfitx),...        
        ]*fit_cft; 
end
