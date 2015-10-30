function [Brightness,Greenness,Wetness,Fourth,Fifth,Sixth] = ...
    TasseledCap(timeseries,TC_input)
%TASSELED CAP Brightness, Greenness, Wetness transformation for TM/ETM+
%   Applies Tasseled Cap transformation. Three options for coefficients
%   based on input data.


switch TC_input
    
    case 'DN'   % Crist & Cicone (1984)
        
        TC = [ 0.3037  0.2793  0.4743  0.5585  0.5082  0.1863;...
              -0.2848 -0.2435 -0.5436  0.7243  0.0840 -0.1800;...
               0.1509  0.1973  0.3279  0.3406 -0.7112 -0.4572;...
              -0.8242  0.0849  0.4392 -0.0580  0.2012 -0.2768;...
              -0.3280  0.0549  0.1075  0.1855 -0.4357  0.8085;...
               0.1084 -0.9022  0.4120  0.0573 -0.0251  0.0238 ];
           
    case 'TOA_Reflect'   % Huang et al. (2002)
        
        TC = [ 0.3561  0.3972  0.3904  0.6966  0.2286  0.1596;...
              -0.3344 -0.3544 -0.4556  0.6966 -0.0242 -0.2630;...
               0.2626  0.2141  0.0926  0.0656 -0.7629 -0.5388;...
               0.0805 -0.0498  0.1950 -0.1327  0.5752 -0.7775;...
              -0.7252 -0.0202  0.6683  0.0631 -0.1494 -0.0274;...
               0.4000 -0.8172  0.3832  0.0602 -0.1095  0.0985 ];
           
    case 'Surf_Reflect'   % Crist (1985) *CORRECTED 04/02/15*
        
        TC = [ 0.2043  0.4158  0.5524  0.5741  0.3124  0.2303;...
              -0.1603 -0.2819 -0.4934  0.7940 -0.0002 -0.1446;...
               0.0315  0.2021  0.3102  0.1594 -0.6806 -0.6109;...
              -0.2117 -0.0284  0.1302 -0.1007  0.6529 -0.7078;...
              -0.8669 -0.1835  0.3856  0.0408 -0.1132  0.2272;...
               0.3677 -0.8200  0.4354  0.0518 -0.0066 -0.0104 ];

end


% Brightness
band1_bright = TC(1,1)*timeseries(:,1);
band2_bright = TC(1,2)*timeseries(:,2);
band3_bright = TC(1,3)*timeseries(:,3);
band4_bright = TC(1,4)*timeseries(:,4);
band5_bright = TC(1,5)*timeseries(:,5);
band7_bright = TC(1,6)*timeseries(:,6);

Brightness = band1_bright + band2_bright + band3_bright + ...
                band4_bright + band5_bright + band7_bright;

% Greenness
band1_green = TC(2,1)*timeseries(:,1);
band2_green = TC(2,2)*timeseries(:,2);
band3_green = TC(2,3)*timeseries(:,3);
band4_green = TC(2,4)*timeseries(:,4);
band5_green = TC(2,5)*timeseries(:,5);
band7_green = TC(2,6)*timeseries(:,6);

Greenness = band1_green + band2_green + band3_green + ...
                band4_green + band5_green + band7_green;

% Wetness
band1_wet = TC(3,1)*timeseries(:,1);
band2_wet = TC(3,2)*timeseries(:,2);
band3_wet = TC(3,3)*timeseries(:,3);
band4_wet = TC(3,4)*timeseries(:,4);
band5_wet = TC(3,5)*timeseries(:,5);
band7_wet = TC(3,6)*timeseries(:,6);

Wetness = band1_wet + band2_wet + band3_wet + ...
            band4_wet + band5_wet + band7_wet;


% Fourth
band1_fourth = TC(4,1)*timeseries(:,1);
band2_fourth = TC(4,2)*timeseries(:,2);
band3_fourth = TC(4,3)*timeseries(:,3);
band4_fourth = TC(4,4)*timeseries(:,4);
band5_fourth = TC(4,5)*timeseries(:,5);
band7_fourth = TC(4,6)*timeseries(:,6);

Fourth = band1_fourth + band2_fourth + band3_fourth + ...
            band4_fourth + band5_fourth + band7_fourth;

% Fifth
band1_fifth = TC(5,1)*timeseries(:,1);
band2_fifth = TC(5,2)*timeseries(:,2);
band3_fifth = TC(5,3)*timeseries(:,3);
band4_fifth = TC(5,4)*timeseries(:,4);
band5_fifth = TC(5,5)*timeseries(:,5);
band7_fifth = TC(5,6)*timeseries(:,6);

Fifth = band1_fifth + band2_fifth + band3_fifth + ...
            band4_fifth + band5_fifth + band7_fifth;

% Sixth
band1_sixth = TC(6,1)*timeseries(:,1);
band2_sixth = TC(6,2)*timeseries(:,2);
band3_sixth = TC(6,3)*timeseries(:,3);
band4_sixth = TC(6,4)*timeseries(:,4);
band5_sixth = TC(6,5)*timeseries(:,5);
band7_sixth = TC(6,6)*timeseries(:,6);

Sixth = band1_sixth + band2_sixth + band3_sixth + ...
            band4_sixth + band5_sixth + band7_sixth;

end

