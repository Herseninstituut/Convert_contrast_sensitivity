function cimg = convert_contrast_sensitivity(im,cs,color_transformation,width,distance,show)
%convert_contrast_sensitivity. Reads image and shows it as seen with a specified contrast sensititivity
%
%   IMG = convert_contrast_sensitivity(IM,CS='mouse',COLOR_TRANSFORMATION='grayscale',WIDTH,DISTANCE,SHOW=true)
%         IM is name of jpg image file or an image array
%         CS is the name of an animal or contains 2xN matrix contrast sensitivity, with in the first
%         row the spatial frequencies and in the second row the sensitivities.
%         see or use CONTRAST_SENSITIVITIES for some example curves.
%
%         COLOR_TRANSFORMATION is the transformation used to display the 
%         color sensitivities. Only 'none', 'grayscale' and 'squirrel'
%         are implemented.
%
%         if the aim is to see what one would see with the specified
%         contrast sensitivity at the original camera position, then
%         WIDTH should be the width of the scene in the image in meters, and
%         DISTANCE is the distance of the foreground in the image in
%         meters. For the example image fieke.jpg, width is 1 m, and
%         distance is 2 m. 
%
%         if the aim is to see what one would see with the specified
%         contrast sensitivity when looking at the image at the monitor, then
%         WIDTH should be the width of the image (displayed at intrinsic
%         pixel resolution) in meters on the monitor, and DISTANCE is the 
%         distance of the monitor.
%
%         if SHOW is true, original and transformed image are shown side by
%         side
%
%
%    Example:
%        img = convert_contrast_sensitivity('fieke.jpg','squirrel','squirrel',1,2,true);
%
% See also: contrast_sensitivities, cs_gratings
%
% 2003-2023, Alexander Heimel
%

if nargin<1 || isempty(im)
    warning('No image name or image given')
    return
end
if ischar(im)
    img = imread(im);
else
    img = im;
end

if nargin<2 || isempty(cs)
    cs = 'mouse';
end
if nargin<3 || isempty(color_transformation)
    color_transformation = 'grayscale';
end

if ischar(cs)
    cs = contrast_sensitivities(cs);
end

if nargin<4 || isempty(width)
    % for example HD monitor
    monitor_width = 0.50; % m, width of the monitor 
    monitor_width_pxl = 1920; % HD standard
    width_pxl = size(img,2);
    width = width_pxl / monitor_width_pxl * monitor_width;
end

if nargin<5 || isempty(distance)
    % for example monitor distance
    distance = 0.50; % m, distance to monitor from eye
end

if nargin<6 || isempty(show)
    show = true;
end

width_pxl = size(img,2);
width_deg = atan(width/(2*distance))*2/pi*180;
ppd = width_pxl / width_deg;

% make rows and columns odd
if mod(size(img,1),2)==0
    img = img(1:end-1,:,:);
end
if mod(size(img,2),2)==0
    img = img(:,1:end-1,:);
end

% make square
if size(img,1)>size(img,2)
    img = img(1:size(img,2),:,:);
else
    img = img(:,1:size(img,1),:);
end

if size(img,3)==1 % i.e. grayscale image
    color_transformation = 'grayscale';
end

switch color_transformation
    case 'none'
        no_color = false;
        cimg(:,:,1) = convert_fourier(img(:,:,1),cs,ppd); 
        cimg(:,:,2) = convert_fourier(img(:,:,2),cs,ppd); 
        cimg(:,:,3) = convert_fourier(img(:,:,3),cs,ppd); 
    case 'grayscale'
        no_color = true;
        if size(img,3)==3
            cimg = rgb2gray(img);  % transform to gray image
            cimg = convert_fourier(cimg,cs,ppd)*255;

        end
    case 'squirrel'
        no_color = false;
        cimg = rgb2squirrel(img);
        cimg(:,:,2) = convert_fourier(cimg(:,:,2),cs,ppd); % M signal
        cimg(:,:,3) = convert_fourier(cimg(:,:,3),cs,ppd); % S signal
        cimg(:,:,1) = cimg(:,:,2);
    otherwise
        error(['Color transformation ' color_transformation ' is not implemented.'])
end


if show
    screensize = get(0,'ScreenSize');

    figure('WindowStyle','normal','Name','Original');
    image(img);
    sz = size(cimg);
    set_size(gca,sz(1:2));
    set(gcf,'Units','pixels');
    set(gcf,'Position',[round(screensize(3)/2)-sz(1) round(screensize(4)/2) sz(1) sz(2)] );

    figure('WindowStyle','normal','Name','Result');
    image(uint8(cimg));
    if no_color
        colormap(gray);
    end
    sz = size(cimg);
    set_size(gca,sz(1:2));
    set(gcf,'Units','pixels');
    set(gcf,'Position',[round(screensize(3)/2) round(screensize(4)/2) sz(1) sz(2)] );
end


end

%% Helper functions
function img2 = convert_fourier(img,cs,ppd)

% when restricting fouriers, there is a lot of spill over
fimg = fft2(img);

nrow = size(img,1);
ncol = size(img,2);
if ncol~=ncol
    error('Image not square');
end

% FFT matrix
%  0,0 0,.....

maskr = [ (1:floor( (nrow-1)/2))  (floor( (nrow-1)/2):-1:1) ];
maskrs = maskr(ones(1,ncol-1),:)';
maskc = [ (1:floor( (ncol-1)/2))  (floor( (ncol-1)/2):-1:1) ];
maskcs = maskc(ones(1,nrow-1),:);
mask = sqrt(maskrs.^2 + maskcs.^2);

totalmask = ones( nrow,ncol);
totalmask(2:end,2:end) = mask;
totalmask(1,2:end) = maskc;
totalmask(2:end,1) = maskr';

cs_human = contrast_sensitivities('human');

% rescale to relative contrastsensitivities:
cs(2,:) = cs(2,:)./interp1q(cs_human(1,:)',cs_human(2,:)',cs(1,:)')';
cs(2,(cs(2,:)>1)) = 1; % to avoid saturation, where contrast detection
% is better than human

% get sf in cycles per pixel:
cs(1,:) = cs(1,:)/ppd;

totalmask = totalmask/ncol;      % to get sf in cycles per pixel
mask2 = interp1q(cs(1,:)',cs(2,:)',totalmask(:) ) ;
totalmask = reshape(mask2,nrow,ncol);

totalmask(1,1) = 1; % no change in DC component

if any(isnan(mask))
    errorlog('Oops nan in mask');
end

fimg = fimg.*totalmask;
img2 = abs(ifft2(fimg));
end

function set_size(h,siz)
set(h,'Units','pixels');
set(h,'Position',[0 0 siz(1) siz(2)]);
end