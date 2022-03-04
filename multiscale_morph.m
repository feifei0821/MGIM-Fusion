function FM = multiscale_morph(img, num)
%========================================================================
%This is a function to compute the multiscale morphological focus-measure
%计算多尺度形态学聚焦测量
%Input: 
%       img: the input image
%     scale: the number of the scales
%Output:
%        FM: Focus-measure
%========================================================================
img = double(img);
FM = double(zeros(size(img))); 

for ii = 1 : num
    %scale = 2 * ii + 1;
    %se = strel('disk', scale);  %SE=strel(shape,parameters)创建由指定形状shape对应的结构元素；disk圆盘
    % one scale focus-measure  单尺度聚焦测量
    %g1 = img - imopen(img, se); 
    %g2 = imclose(img,se) - img;
    %g = max(g1,g2);
    % the composite focus-measure  聚焦测量综合
    scale = 5 * ii + 1;%阈值
    [x,y]=gradient(double(img));   %获取梯度
    t=sqrt(x.^2+y.^2); 
    img(t>=T)=255;           %梯度提取边缘 画黑
    img(t<T)=0;
	FM = FM + 1 / scale *(img);
end

return
