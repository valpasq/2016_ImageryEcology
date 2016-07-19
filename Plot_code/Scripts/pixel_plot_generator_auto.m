function [] = pixel_plot_generator_auto(WRS, savedir, N_row, N_col, geplot, gedate, gedate2, gedate3, gedate4, plotout)
%% General Time Series Plotting Script - separate plots version
% This script can be used to generate a variety of time series plots
% This version creates two separate plots for sequential date and DOY 
% Can also turn on histogram plot and save (end of script)

% Author: Valerie Pasquarella

%% SET code directories
% Directory where script and functions are stored
toolsdir='/usr3/graduate/valpasq/Documents/2016_ImageryEcology/Plot_code/Tools/';
addpath(toolsdir);
addpath('/usr3/graduate/valpasq/Documents/2016_ImageryEcology/Plot_code/Tools/export_fig/');

codedir='/usr3/graduate/valpasq/Documents/2016_ImageryEcology/Plot_code/Scripts/';
addpath(codedir);

%% SET directory containing time series of Landsat images
%imagedir='/projectnb/buchans/students/valpasq/5km/p012r031/images/';

%imagedir='/projectnb/landsat/projects/Massachusetts/p011r031/images/'
%WRS='p012r031';

%imagedir='/projectnb/landsat/projects/CMS/stacks/Colombia/p008r056/images/'
%WRS='p008r056';

%imagedir='/projectnb/landsat/projects/Colombia/images/007059/images/';
%WRS='p007r059';

%imagedir='/projectnb/landsat/projects/Colombia/images/006060/images/'
%WRS='p006r060'; 

%imagedir='/projectnb/landsat/projects/Finland/189017/images/';
%WRS='p189r017';

%imagedir='/projectnb/landsat/projects/Vietnam/p125r053/images/';
%WRS='p125r053';

%% SPECIFY save directory for plots and CSV files
%savedir='/usr3/graduate/valpasq/Documents/2016_ImageryEcology/figures/cyclic/';

%% INPUTS: CONTROL PLOT INPUTS

% SPECIFY Pixel coordinates
%N_row = 4539 % row
%N_col = 4623 % column

%% SPECIFY WHERE TO READ DATA FROM - Image or CSV
csv_read='True';

switch csv_read
    case 'True'
        clrx=csvread([savedir WRS '_' num2str(N_row) '-' num2str(N_col) '_clrx.csv']);
        %clry=csvread([savedir WRS '_' num2str(N_row) '-' num2str(N_col) '_clry.csv'])
        clry=csvread([savedir WRS '_' num2str(N_row) '-' num2str(N_col) '_clry_BGW.csv']);
        
        datatype='TC';
        B_plotvec=[1 2 3];
        
    case 'False'
        % Read input data from images
        
        % CASE 1: stack with just 7 original bands + Fmask (8 bands)
        %stk_n = '_stack'; % original stack format
        %datatype='TC';  % need to transform to TC
        %nbands=8;
        %B_plotvec=[1 2 3];
        
        % CASE 2: stack that includes 7 bands + BGW + Fmask (11 bands)
        stk_n = '_all';  % stacked with BGW - 10 bands total, use 'band' option
        datatype='band';  % TC band available in stack - direct read
        nbands=11;
        B_plotvec=[8 9 10];
        
        % SPECIFY whether to use multitemporal cloud masking procedure
        multitempcloud='on';
        
end



%% PLOTTING SPECIFICATIONS

% SPECIFY plot attributes:
markcolor='k'; % marker color for solid plots

% TURN VERTICAL DATE LINES ON/OFF
%geplot='on';
%geplot='off';

% SPECIFY dates for any Google Earth (validation) images
gedate=datenum(gedate);  % add vertical line for a particular date (1)
gedate2=datenum(gedate2); % add vertical line for a particular date (2)
gedate3=datenum(gedate3);
%gedate4=datenum('09/11/2014');
%gedateDOY=237;

% SPECIFY threshold for 'thresh' plot
B_thresh=1; % if B_thresh > thresh, change symbology, plot line
thresh=5000;

%% PLOTS
% Specify TS plot style and DOY plot style

%TSplottype='solid';   % all observations one color
%TSplottype='years';   % observations symbolized by year
%TSplottype='months'; % observations symbolized by month
TSplottype='seasons'; % observations symbolized by season
%TSplottype='thresh';   % observations symbolized based on fixed threshhold

%DOYplottype='black';   % one panel, all points in black
DOYplottype='years';   % one panel, symbolized by year
%DOYplottype='months'; % observations symbolized by month
%DOYplottype='seasons';  % one panel, symbolized by season

% OUTPUT:
%plotout='combined';
%plotout='separate';


switch csv_read
    case 'False' % Read in image data    
        %% READ in X data (image dates) and Y data (reflectance values)
        [sdate,line_t,num_t] = ...
            CCDC_XYRead(codedir,imagedir,N_row,N_col,stk_n,nbands);
        
        %% MASK Step 1 (Fmask and physical constraints)
        [clrx, clry, idgood, cloudy_x, cloudy_y, shadow_x, shadow_y,...
            snow_x, snow_y, line_m] = CCDC_XYMask1_1(num_t,line_t,nbands,sdate);
        
        %[clrx,clry,idgood] = CCDC_XYMask1(num_t,line_t,nbands,sdate);
        
        %% Prepare input data
        
        switch datatype
            case 'band'
                switch multitempcloud
                    case 'on'
                        [timeseries,cloudx,cloudy,rfit_B2,rfit_B5] = ...
                            CCDC_XYMask2(clrx,clry,nbands);
                        idgood= timeseries(:,1) > -9999;
                        clrx=clrx(idgood);
                        clry=clry(idgood,:);
                        
                    case 'off'
                end
                
            case 'TC'
                % SPECIFY tasseled cap coefficients (for TC plot)
                %TC_input='DN';
                %TC_input='TOA_Reflect';
                TC_input='Surf_Reflect';
                
                [Brightness,Greenness,Wetness,Fourth,Fifth,Sixth] = ...
                    TasseledCap(clry,TC_input);
                
                dummy=zeros(length(Brightness),1);
                clry_TC=[Brightness Greenness Wetness Fourth Fifth Sixth dummy];
                
                switch multitempcloud
                    case 'on'
                        [timeseries,cloudx,cloudy,rfit_B2,rfit_B5] = ...
                            CCDC_XYMask2(clrx,clry,nbands);
                        idgood= timeseries(:,1) > -9999;
                        clrx=clrx(idgood);
                        clry=clry_TC(idgood,:);
                        
                    case 'off'
                        clry_orig=clry;
                        clry=clry_TC;
                end
                
        end
        
        %% Extract fmask values for reporting # observation stats
        fmask_all=(line_m<255);
        fmask_clear=(line_m<2);
        
        fmask_all=line_m(fmask_all);
        fmask_clear=line_m(fmask_clear);      
end

        %% Calculate DOY & Year & Month
        doy=clrx-datenum(year(clrx),1,1)+1;
        obs_year=year(clrx);
        obs_month=month(clrx);
              
        %% Separate data seasonsally
        
        % SPECIFY growing season start & end
        spr_early=120;
        spr_late=150;
        fall_early=280;
        fall_late=310;


%% SEQUENTIAL DATE plot

for j=1:length(B_plotvec)
    
    B_plot=B_plotvec(j);
    
    if B_plot==1 || B_plot==8
        yrange=[0 10000]; % y axis limits
    elseif B_plot==2 || B_plot==9
        yrange=[-500 5000];
    elseif B_plot==3 || B_plot ==10
        yrange=[-5000 1000];
    end
    
    switch plotout
        case 'combined'
            figure(j)
            subplot(1,10,[1,2,3,4,5,6])
            set(gcf,'Position',[0 500 2500 500]);

        case 'separate'
            figure()
            set(gcf,'Position',[0 500 1000 500]);
    end
   
    set(gca,'FontSize',18)
    hold on
    
    B_max=max(yrange);
    B_min=min(yrange);
    t_max=max(clrx);
    
    % Add red 0-axis
    t_max=max(clrx);
    t_min=min(clrx);
    plot(723181:t_max+30,0,'k-','LineWidth',1.5)
    
    switch TSplottype
        case 'seasons'
            for i=1:length(doy)
                if doy(i) > fall_late || doy(i) <= spr_early
                    plot(clrx(i),clry(i,B_plot),'bo','Markersize',6,'MarkerFaceColor','b')
                elseif doy(i) > spr_late && doy(i) <= fall_early
                    plot(clrx(i),clry(i,B_plot),'go','Markersize',6,'MarkerFaceColor','g')
                else plot(clrx(i),clry(i,B_plot),'ko','Markersize',6')
                    
                end
            end
            
        case 'months'
            colormap(hsv(12));
            color_tab=hsv(12);
            
            month_i=1;
            for k=1:12
                for i=1:length(clrx)
                    if obs_month(i) == month_i
                        plot(clrx(i),clry(i,B_plot),'ko','Markersize',6,...
                            'MarkerEdgeColor',color_tab(k,:),'MarkerFaceColor',color_tab(k,:))
                    else continue
                    end
                end
                month_i=month_i+1;
            end
            
        case 'thresh'
            for i=1:length(doy)
                if clry(i,B_thresh) > thresh
                    plot(clrx(i),clry(i,B_plot),'co','Markersize',6,'MarkerFaceColor','c')
                else
                    plot(clrx(i),clry(i,B_plot),'bo','Markersize',6,'MarkerFaceColor','b')
                    
                end
            end
            
            if B_plot==B_thresh
                plot(723181:t_max+30,thresh,'b-','LineWidth',1)
            end
            

           
        case 'years'
            colormap(jet(range(obs_year)));
            color_tab=jet(range(obs_year));
            
            year_i=min(obs_year);
            for k=1:range(obs_year)
                for i=1:length(clrx)
                    if obs_year(i) == year_i
                        plot(clrx(i),clry(i,B_plot),'ko','Markersize',6,...
                            'MarkerEdgeColor',color_tab(k,:),'MarkerFaceColor',color_tab(k,:))
                    else continue
                    end
                end
                year_i=year_i+1;
            end
            
        case 'solid'
            plot(clrx,clry(:,B_plot),'ko','Markersize',6,'MarkerFaceColor',markcolor)
            
    end
    
    switch geplot
        case 'on'
            plot(gedate,B_min:B_max,':m')
            plot(gedate2,B_min:B_max,':m')
            plot(gedate3,B_min:B_max,':m')
            %plot(gedate4,B_min:B_max,':m')
        case 'off'
            
    end
      
    grid on
    
    %start = t_max;
    %last = t_min;
    %tk = datelist(start, last, 1:36);
    %set(gca, 'xlim', [start last], 'xtick', tk)
    %datetick('keepticks', 'keeplimits')
    
    %NumTicks = 8;
    %set(gca,'XTick',linspace(t_min,t_max,NumTicks))
    xlim([723181 t_max])
    datetick('x','keeplimits')
    %
    %L = get(gca,'XLim');


    
    xlabel('Year','FontSize',18,'FontWeight','bold','Color','k')
    
    ylim(yrange)
    
    %title(['Row/Col=',num2str(N_row),'/',num2str(N_col)]);
    title([]);
    
    switch datatype
        case 'band'
            B_num=B_plot;
            if B_plot==6
                B_num=7;
            elseif B_plot==7
                B_num=6;
            end
            
            if B_num == 6
                ylabel(['Band ',num2str(B_num),' Brightness Temperature (^oCX10^2)']);
            elseif B_plot == 8
                ylabel('TC Brightness x 10000','FontSize',20,'FontWeight','bold','Color','k');
            elseif B_plot == 9
                ylabel('TC Greenness x 10000','FontSize',20,'FontWeight','bold','Color','k');
            elseif B_plot == 10
                ylabel('TC Wetness x 10000','FontSize',20,'FontWeight','bold','Color','k');
            else
                ylabel(['Band ',num2str(B_num),' Surface Reflectance (X10^4)']);
            end
            
        case 'TC'
            if B_plot == 1
                ylabel('TC Brightness x 10000','FontSize',20,'FontWeight','bold','Color','k');
            elseif B_plot == 2
                ylabel('TC Greenness x 10000','FontSize',20,'FontWeight','bold','Color','k');
            elseif B_plot == 3
                ylabel('TC Wetness x 10000','FontSize',20,'FontWeight','bold','Color','k');
            elseif B_plot == 4
                ylabel('TC Fourth x 10000');
            elseif B_plot == 5
                ylabel('TC Fifth x 10000');
            elseif B_plot == 6
                ylabel('TC Sixth x 10000');
            elseif B_plot == 7
                ylabel('NO DATA!!');
            end
            
    end
    
    
    %% DAY OF YEAR plot
    
    switch plotout
        case 'combined'
            figure(j)
            subplot(1,10,[8,9,10])
            %set(gca,'YTickLabel',[]);
            
        case 'separate'
            figure()
            set(gcf,'Position',[0 0 650 500]);
    end
            
    set(gca,'FontSize',20)%,'FontWeight','bold')
    
    plot(0:365,0,'k-','LineWidth',1.5)
    switch DOYplottype
     
        case 'months'
            hold on
            colormap(hsv(12));
            color_tab=hsv(12);
            
            month_i=1;
            for k=1:12
                for i=1:length(doy)
                    if obs_month(i) == month_i
                        plot(doy(i),clry(i,B_plot),'ko','Markersize',6,...
                            'MarkerEdgeColor',color_tab(k,:),'MarkerFaceColor',color_tab(k,:))
                    else continue
                    end
                end
                month_i=month_i+1;
            end
        
        case 'years'
            hold on
            colormap(jet(range(1980:2016)));
            color_tab=(jet(range(1980:2016)));
            
            year_i=1980;
            for k=1:2015
                for i=1:length(doy)
                    if obs_year(i) == year_i
                        plot(doy(i),clry(i,B_plot),'ko','Markersize',6,...
                            'MarkerEdgeColor',color_tab(k,:),'MarkerFaceColor',color_tab(k,:))
                    else continue
                    end
                end
                year_i=year_i+1;
            end
            year_i=1980;
            
            %plot(0:365,thresh,'b-','LineWidth',1)
            
            %plot(gedateDOY,B_min:B_max,'m-')
            
            colorbar
            h = colorbar;
            set(h,'fontsize',16);
            
            ylabel(h, ['Years since ',num2str(year_i)],'FontSize',20)      
        
        case 'black'
            hold on
            set(gca,'YTickLabel',[]);
            plot(doy,clry(:,B_plot),'ko','Markersize',6,'MarkerFaceColor',markcolor)
            
        case 'seasons'
            hold on
            for i=1:length(doy)
                if doy(i) > fall_late || doy(i) <= spr_early
                    plot(doy(i),clry(i,B_plot),'bo','Markersize',6,'MarkerFaceColor','b')
                elseif doy(i) > spr_late && doy(i) <= fall_early
                    plot(doy(i),clry(i,B_plot),'go','Markersize',6,'MarkerFaceColor','g')
                else plot(doy(i),clry(i,B_plot),'ko','Markersize',6')
                end
            end
            
            %plot(gedateDOY,B_min:B_max,'m-')
            %plot(spr_early,B_min:B_max,'b-')
            %plot(spr_late,B_min:B_max,'g-')
            %plot(fall_early,B_min:B_max,'g-')
            %plot(fall_late,B_min:B_max,'b-')
            
    end
    
    xlabel('Day of Year','FontSize',18,'FontWeight','bold','Color','k')
    xlim([0 365])
    ylim(yrange)
    
    
    switch plotout
        case 'separate'
            
            switch datatype
                case 'band'
                    B_num=B_plot;
                    if B_plot==6
                        B_num=7;
                    elseif B_plot==7
                        B_num=6;
                    end
                    
                    if B_num == 6
                        %ylabel(['Band ',num2str(B_num),' Brightness Temperature (^oCX10^2)']);
                    elseif B_plot == 8
                        ylabel('TC Brightness x 10000','FontSize',20,'FontWeight','bold','Color','k');
                        %text(5,9500,['Total observations (',num2str(min(obs_year)),'-',...
                        %    num2str(max(obs_year)),') = ',num2str(length(fmask_all))],'FontSize', 16)
                        %text(5,9000,['Clear observations = ',num2str(length(fmask_clear))],'FontSize', 16)
                    elseif B_plot == 9
                        ylabel('TC Greenness x 10000','FontSize',20,'FontWeight','bold','Color','k');
                        %text(5,4500,['Total observations (',num2str(min(obs_year)),'-',...
                        %    num2str(max(obs_year)),') = ',num2str(length(fmask_all))],'FontSize', 16)
                        %text(5,4200,['Clear observations = ',num2str(length(fmask_clear))],'FontSize', 16)
                    elseif B_plot == 10
                        ylabel('TC Wetness x 10000','FontSize',20,'FontWeight','bold','Color','k');
                        %text(5,-4200,['Total observations (',num2str(min(obs_year)),'-',...
                        %    num2str(max(obs_year)),') = ',num2str(length(fmask_all))],'FontSize', 16)
                        %text(5,-4500,['Clear observations = ',num2str(length(fmask_clear))],'FontSize', 16)
                    else
                        %ylabel(['Band ',num2str(B_num),' Surface Reflectance (X10^4)']);
                    end
                    
                case 'TC'
                    if B_plot == 1
                        ylabel('TC Brightness x 10000','FontSize',20,'FontWeight','bold','Color','k');
                        
                        % Number of observations reporting
                        %text(5,9500,['Total observations (',num2str(min(obs_year)),'-',...
                        %    num2str(max(obs_year)),') = ',num2str(length(fmask_all))],'FontSize', 16)
                        %text(5,9000,['Clear observations = ',num2str(length(fmask_clear))],'FontSize', 16)
                        
                    elseif B_plot == 2
                        ylabel('TC Greenness x 10000','FontSize',20,'FontWeight','bold','Color','k');
                        
                        % Number of observations reporting
                        %text(5,4500,['Total observations (',num2str(min(obs_year)),'-',...
                        %    num2str(max(obs_year)),') = ',num2str(length(fmask_all))],'FontSize', 16)
                        %text(5,4200,['Clear observations = ',num2str(length(fmask_clear))],'FontSize', 16)
                        
                    elseif B_plot == 3
                        ylabel('TC Wetness x 10000','FontSize',20,'FontWeight','bold','Color','k');
                        
                        % Number of observations reporting
                        %text(5,-4200,['Total observations (',num2str(min(obs_year)),'-',...
                        %    num2str(max(obs_year)),') = ',num2str(length(fmask_all))],'FontSize', 16)
                        %text(5,-4500,['Clear observations = ',num2str(length(fmask_clear))],'FontSize', 16)
                    elseif B_plot == 4
                        ylabel('TC Fourth x 10000');
                    elseif B_plot == 5
                        ylabel('TC Fifth x 10000');
                    elseif B_plot == 6
                        ylabel('TC Sixth x 10000');
                    elseif B_plot == 7
                        ylabel('NO DATA!!');
                    end
            end
    end
    
    
    grid on
    
    %title(WRS,'FontSize',14,'FontWeight','bold');

    
   
    
end

%% Histogram Plot
%figure()
%set(gcf,'Position',[500 1000 450 500]);
%hist(doy,26)
%title(['Row/Col=',num2str(N_row),'/',num2str(N_col)]);
%ylabel('Number of Observations')
%xlabel('DOY - 2-week bins')

%h = findobj(gca,'Type','patch');
%h.FaceColor = 'k';
%h.EdgeColor = markcolor;

%xlim([0 365])
%ylim([0 25])


%% SAVE directory
% Save directory:
cd(savedir)

%% Save CSV

%switch csv_read
%#    case 'False'
%        switch datatype
%            case 'band'
%                csvwrite([WRS '_' num2str(N_row) '-' num2str(N_col) '_clrx.csv'],clrx)
%                csvwrite([WRS '_' num2str(N_row) '-' num2str(N_col) '_clry.csv'],clry(:, 1:7))
%                csvwrite([WRS '_' num2str(N_row) '-' num2str(N_col) '_clry_BGW.csv'],clry(:, 8:10))                
%            case 'TC'
%                csvwrite([WRS '_' num2str(N_row) '-' num2str(N_col) '_clrx.csv'],clrx)
%                csvwrite([WRS '_' num2str(N_row) '-' num2str(N_col) '_clry.csv'],clry_orig(:, 1:7))
%                csvwrite([WRS '_' num2str(N_row) '-' num2str(N_col) '_clry_BGW.csv'],clry(:, 1:3))
%        end
%end



%% SAVE plots
switch plotout
    case 'combined'
        SaveAllFigures_TC_Combined
    case 'separate'
        SaveAllFigures_TC_separate
end

close all

clear


