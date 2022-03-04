% This procedure loads a sequence of images  加载一系列图像
%
% Arguments:
%   'path', refers to a directory which contains a sequence of images
%   指包含一系列图像的目录
%   'reduce' is an optional parameter that controls downsampling, e.g., reduce = .5
%   downsamples all images by a factor of 2.
%   'reduce'可选参数，控制降采样，等于0.5降采样两倍,等于1不进行降采样
% tom.mertens@gmail.com, August 2007
%

function I = load_images(path, reduce)

if ~exist('reduce')
    reduce = 1;
end

if (reduce > 1 || reduce <= 0)
    error('reduce must fulfill: 0 < reduce <= 1');  % 0 < reduce <= 1
end

% find all JPEG or PPM files in directory
files = dir([path '/*.tif']); %dir函数获得指定文件夹下的所有子文件夹和文件,并存放在一种为文件结构体数组中
N = length(files);
if (N == 0)
    files = dir([path '/*.jpg']);
    N = length(files);
    if (N == 0)
    files = dir([path '/*.gif']);
    N = length(files);
    if (N == 0)
    files = dir([path '/*.bmp']);
    N = length(files);
    if (N == 0)
    files = dir([path '/*.png']);
    N = length(files);
    if (N == 0)
    error('no files found');
    end
          end
         end
    end
end

% allocate memory 分配内存
sz = size(imread([path '/' files(1).name]));
r = floor(sz(1)*reduce);  %朝无穷大方向取整 floor(x)不超过x的最大整数
c = floor(sz(2)*reduce);
if length(sz)==3
    I=zeros(r,c,3,N);
else
I = zeros(r,c,N);
end
% read all files
for i = 1:N
    
    % load image
    filename = [path '/' files(i).name];
    im = imread(filename);
    if (size(im,1) ~= sz(1) || size(im,2) ~= sz(2))
        error('images must all have the same size');
    end
    
    % optional downsampling step
    if (reduce < 1)
    im = imresize(im,[r c],'bicubic');
    end
    if size(im,3)==3
    I(:,:,:,i) =im;
    else
    I(:,:,i) = im;
    end
    I=uint8(I);
end
