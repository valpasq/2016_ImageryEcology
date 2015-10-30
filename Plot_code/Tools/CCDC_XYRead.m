function [sdate,line_t,num_t] = ...
    CCDC_XYRead(codedir,imagedir,N_row,N_col,stk_n,nbands)
% XYRead 
% This function reads in X data (serial dates referenced
% to 0000 year) and Y data (reflectance values) from the image directory 

%% PREPROCESSING - Extract image variables
% Current defaults for Landsat imagery
cd(imagedir);

imf=dir('L*');        % Get folder names
num_t=size(imf,1);    % Calculate total number of folders starting with "L"

num_byte = 2;   % Number of bytes: int16

exampim=auto_imget(1,'L'); % Get name of the first stacked imag
dim=envihdrread([exampim.n_name,stk_n]); % Read in dimension of the image
dim=fliplr(dim);      % Flip row, col

%% PREPROCESSING - Initialize X (sdate) and Y (line_t) vectors
sdate=zeros(num_t,1);       % Xs - serial dates of images
line_t=zeros(num_t,nbands); % Ys - reflectance values 

%% SORT IMAGES
%%% <CEHOLDEN EDIT>
% filter for Landsat folders
%imf = regexpi({imf.name}, 'L(T5|T4|E7|C8|ND)(\w*)', 'match');
%imf = [imf{:}];
%imf = vertcat(imf{:});
% sort according to yeardoy
%yeardoy = str2num(imf(:, 10:16));
%[~, sort_order] = sort(yeardoy);
%imf = imf(sort_order, :);
%%% </CEHOLDEN EDIT>

%% EXTRACT - Read in X and Y data from images

for i=1:num_t
    % CEHOLDEN (5/23/2013): Change to allow missing MTL files
	% Find the stacked file in folder imf(i)
    im_dir = dir(imf(i).name);
    im = '';
    for f = 1:size(im_dir, 1)
        % use regular expression to match:
        %   'L(\w*)'  Any word begining with L that has any following chars
        %   stk_n     includes stack name somewhere after L
        %   '$'       ends with the stack name (e.g., no .hdr, .aux.xml)
        if regexp(im_dir(f).name, ['L(\w*)', stk_n, '$']) == 1
            im = [imf(i).name, '/', im_dir(f).name];
            break
        end
    end
    if strcmp(im, '')
        fprintf('Could not find stack image for directory %s\n', ...
            imf(i).name);
        quit()
    end
    % Find the date for folder imf(i)
    yr = str2double(imf(i).name(10:13));
    doy = str2double(imf(i).name(14:16));
    sdate(i) = datenum(yr, 1, 0) + doy;
    % Now that we have image and date, open and read in
    fid_t = fopen(im, 'r');
    if fid_t == -1
        fprintf('Could not open stack for %s\n', imf(i).name);
        quit()
    end
 
%    [im,~,sdate(i)]=auto_imget(i); % get Xs
%    dummy_name=[im.n_name,stk_n];'category',[]
%    fid_t=fopen(dummy_name,'r'); % get file ids
%    fseek(fid_t,num_byte*(nrows-1)*ncols*nbands,'bof');
%    line_t(i,:)=fread(fid_t,nbands*ncols,'int16=>double','ieee-le'); % get Ys

    fseek(fid_t,num_byte*((N_row-1)*dim(2)+N_col-1)*nbands,'bof');
    line_t(i,:)=fread(fid_t,nbands,'int16=>double','ieee-le'); % get Ys
end
fclose('all'); % close all files
cd(codedir); % return 

end
