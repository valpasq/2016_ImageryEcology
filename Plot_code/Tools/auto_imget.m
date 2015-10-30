function [outname,dir_new,ymd]=auto_imget(num_image,start_n)

% This function sort all the image follow the Julian days derived for folder name
% Valid both for MTL and WO
% Input:
% num_image: is just numble you want i.e. 1,2

% Ouptut:
% outname: this is for the name structure
% dir_new: new dir
% ymd: julian date;

% Output is a struct data with day, month, year and the cal file directory

if exist('start_n','var')==true
else
    start_n='L';
end

dir_current=pwd; % Remember the current dir 

image_name=dir([start_n,'*']);% folder names (* adjustable)

% get in the sub_folder
cd(image_name(num_image).name);
dir_new=pwd;

%% new auto_imget
% Get name for WO & MTL data and ymd from folder name
norMTL=dir('L*MTL.txt');
norWO=dir('L*WO.txt');
norl_name=[norMTL.name,norWO.name];
norln=strread(norl_name,'%s','delimiter','_');  %#ok<FPARK>
n_name=[dir_new,'/',char(norln(1))];

str_n=image_name(num_image).name;
n_year=str2double(str_n(10:13));
j_date=str2double(str_n(14:16));
ymd=datenummx(n_year,1,0)+j_date;

cal=dir('lndcal*hdf');
cal_name=[dir_new,'/',cal.name]; % cal name (ledaps)

th=dir('lndth*hdf');
th_name=[dir_new,'/',th.name]; % th name (ledaps)

sr=dir('lndsr*hdf');
sr_name=[dir_new,'/',sr.name]; % sr name (ledaps)

outname = struct('n_name',n_name,'cal_name',cal_name,'th_name',th_name,'sr_name',sr_name);

cd(dir_current); % change to previous dir

end
