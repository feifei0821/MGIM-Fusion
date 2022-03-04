function FM = multiscale_morph(img, num)
%========================================================================
%This is a function to compute the multiscale morphological focus-measure
%�����߶���̬ѧ�۽�����
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
    %se = strel('disk', scale);  %SE=strel(shape,parameters)������ָ����״shape��Ӧ�ĽṹԪ�أ�diskԲ��
    % one scale focus-measure  ���߶Ⱦ۽�����
    %g1 = img - imopen(img, se); 
    %g2 = imclose(img,se) - img;
    %g = max(g1,g2);
    % the composite focus-measure  �۽������ۺ�
    scale = 5 * ii + 1;%��ֵ
    [x,y]=gradient(double(img));   %��ȡ�ݶ�
    t=sqrt(x.^2+y.^2); 
    img(t>=T)=255;           %�ݶ���ȡ��Ե ����
    img(t<T)=0;
	FM = FM + 1 / scale *(img);
end

return
