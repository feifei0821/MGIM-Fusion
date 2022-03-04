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

s1=[0 0 0 0 0;0 0 0 0 0;1 1 1 1 1;0 0 0 0 0;0 0 0 0 0]; 
s2=[0 0 0 0 0;0 0 0 0 1;0 0 1 0 0;1 0 0 0 0;0 0 0 0 0];
s3=[0 0 0 0 1;0 0 0 1 0;0 0 1 0 0;0 1 0 0 0;1 0 0 0 0];
s4=[0 0 0 1 0;0 0 0 0 0;0 0 1 0 0;0 0 0 0 0;0 1 0 0 0];
s5=[0 0 1 0 0;0 0 1 0 0;0 0 1 0 0;0 0 1 0 0;0 0 1 0 0];
s6=[0 1 0 0 0;0 0 0 0 0;0 0 1 0 0;0 0 0 0 0;0 0 0 1 0];
s7=[1 0 0 0 0;0 1 0 0 0;0 0 1 0 0;0 0 0 1 0;0 0 0 0 1];
s8=[0 0 0 0 0;1 0 0 0 0;0 0 1 0 0;0 0 0 0 1;0 0 0 0 0];

%se = strel('disk', 3); 
g1 = I - imopen(I, s1); 
g2 = imclose(I,s1) - I;
g11 = max(g1,g2);

g1 = I - imopen(I, s2); 
g2 = imclose(I,s2) - I;
g22 = max(g1,g2);

g1 = I - imopen(I, s3); 
g2 = imclose(I,s3) - I;
g33 = max(g1,g2);

g1 = I - imopen(I, s4); 
g2 = imclose(I,s4) - I;
g44 = max(g1,g2);

g1 = I - imopen(I, s5); 
g2 = imclose(I,s5) - I;
g55 = max(g1,g2);

g1 = I - imopen(I, s6); 
g2 = imclose(I,s6) - I;
g66 = max(g1,g2);

g1 = I - imopen(I, s7); 
g2 = imclose(I,s7) - I;
g77 = max(g1,g2);

g1 = I - imopen(I, s8); 
g2 = imclose(I,s8) - I;
g88 = max(g1,g2);

g = (g11+g22+g33+g44+g55+g66+g77+g88);

I1=uint8(g);
figure,imshow(I1);

