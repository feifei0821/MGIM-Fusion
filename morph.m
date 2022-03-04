I=imread('C:\Users\li\Desktop\t.jpg');
I=rgb2gray(I);
I=double(I);
se = strel('disk', 3);  %SE=strel(shape,parameters)创建由指定形状shape对应的结构元素；disk圆盘
% one scale focus-measure  单尺度聚焦测量
g1 = I - imopen(I, se); 
g2 = imclose(I,se) - I;
%g3 = imdilate(I, se) - imerode(I, se);
%figure,imshow(uint8(g3));
g = max(g1,g2);
%g = g + g3;
I1=uint8(g);
figure,imshow(I1);

se1 = strel('rectangle', [4 7]);  %SE=strel(shape,parameters)创建由指定形状shape对应的结构元素；disk圆盘
% one scale focus-measure  单尺度聚焦测量
g11 = I - imopen(I, se1); 
g21 = imclose(I,se1) - I;
%g3 = imdilate(I, se) - imerode(I, se);
%figure,imshow(uint8(g3));
g = max(g11,g21);
%g = g + g3;
I2=uint8(g);
figure,imshow(I2);

se2 = strel('line', 6, 45);  %SE=strel(shape,parameters)创建由指定形状shape对应的结构元素；disk圆盘
% one scale focus-measure  单尺度聚焦测量
%g12 = I - imopen(I, se2); 
%g22 = imclose(I,se2) - I;
g3 = imdilate(I, se2) - imerode(I, se2);
%figure,imshow(uint8(g3));
%g = max(g12,g22);
%g = g + g3;
I3=uint8(g3);
figure,imshow(I3);

se3 = strel('line', 6, 45);  %SE=strel(shape,parameters)创建由指定形状shape对应的结构元素；disk圆盘
% one scale focus-measure  单尺度聚焦测量
g13 = I - imopen(I, se3); 
g23 = imclose(I,se3) - I;
%g3 = imdilate(I, se) - imerode(I, se);
%figure,imshow(uint8(g3));
g = max(g13,g23);
%g = g + g3;
I4=uint8(g);
figure,imshow(I4);

