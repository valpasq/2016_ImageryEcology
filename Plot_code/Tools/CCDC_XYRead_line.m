function [sdate,line_t,num_t,nbands] = ...
    CCDC_XYRead(codedir,imagedir,nrows,ncols,stk_n)
% XYRead 
% This function reads in X data (serial dates referenced
% to 0000 year) and Y data (reflectance values) from the image directory 

%% PREPROCESSING - Extract image variables
% Current defaults for Landsat imagery
cd(imagedir);

imf=dir('L*');        % Get folder names

% <CEHOLDEN EDIT>
% filter for Landsat folders
imf = regexpi({imf.name}, 'L(T5|T4|E7|C8|ND)(\w*)', 'match');
imf = [imf{:}];
imf = vertcat(imf{:});
% sort according to yeardoy
yeardoy = str2num(imf(:, 10:16));
[~, sort_order] = sort(yeardoy);
imf = imf(sort_order, :);
%%% </CEHOLDEN EDIT>

num_t=size(imf,1);    % Calculate total number of folders starting with "L"

num_byte = 2;   % Number of bytes: int16
nbands = 8;     % Number of bands in image (order: B1-5,7,6,Fmask)

exampim=auto_imget(1,'L'); % Get name of the first stacked imag
dim=envihdrread([exampim.n_name,stk_n]); % Read in dimension of the image
dim=fliplr(dim);      % Flip row, col

%% PREPROCESSING - Initialize X (sdate) and Y (line_t) vectors
sdate=zeros(num_t,1);       % Xs - serial dates of images
line_t=zeros(num_t,nbands*ncols); % Ys - reflectance values 

%% EXTRACT - Read in X and Y data from images

for i=1:num_t
    %%% <CEHOLDEN EDIT>
    im_dir = dir(imf(i, :));
    im = '';
    for f = 1:size(im_dir, 1)
        % use regular expression to match:
        %   'L(\w*)'    Any word begining with L that has any following chars
        %   stk_n       includes stack name somewhere after L
        %   '$'           ends with the stack name (e.g., no .hdr, .aux.xml)
        if regexp(im_dir(f).name, ['L(\w*)', 'stack', '$']) == 1
            im = [imf(i, :), '/', im_dir(f).name];
            break
        end
    end
    % Check to make sure we found something
    if strcmp(im, '')
        error('Could not find stack image for directory %s\n', imf(i));
    end
    % Find date for folder imf(i)
    yr = str2num(imf(i, 10:13));
    doy = str2num(imf(i, 14:16));
    sdate(i) = datenum(yr, 1, 0) + doy;
    %%% </CEHOLDEN EDIT>
    % [im,~,sdate(i)]=auto_imget_CCDC(i); % get Xs
    dummy_name=im;
    fid_t=fopen(dummy_name,'r'); % get file ids
    fseek(fid_t,num_byte*(nrows-1)*ncols*nbands,'bof');
    line_t(i,:)=fread(fid_t,nbands*ncols,'int16=>double','ieee-le'); % get Ys
end
fclose('all'); % close all files
%cd(codedir); % return 

end
