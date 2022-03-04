I=imread('C:\Users\li\Desktop\t.jpg');
I=rgb2gray(I);
T=15;%阈值
[x,y]=gradient(double(I));   %获取梯度
t=sqrt(x.^2+y.^2);  
I(t>=T)=255;           %梯度提取边缘 画黑
I(t<T)=0;
I=uint8(I);
figure,imshow(I);

I=imread('C:\Users\li\Desktop\t.jpg');
I=rgb2gray(I);
num = 5;
img = double(I);
D = double(zeros(size(I)));
for ii = 1:num
    scale = 2 * ii + 1;
    se=strel('disk',scale);
    g1=img-imopen(img,se);
    g2=imclose(img,se)-img;
    g=max(g1,g2);
    D=D+1/scale*(g);
end
I2=uint8(D);
figure,imshow(I2)
