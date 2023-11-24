function imgg=rgb2gray(img)
%RGB2GRAY converts rgb image to grayscale
%
% IMG = rgb2gray(IMG)
%
%    2003, Alexander Heimel
%
  
img = rgb2hsv(img);
imgg = img(:,:,3);
