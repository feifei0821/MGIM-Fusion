function [ F ] = IFM(I1,I2)
if size(I1,3)==3
G1=rgb2gray_n(I1); %转灰度图
else
G1=I1;
end
if size(I2,3)==3
G2=rgb2gray_n(I2); %转灰度图
else
G2=I2;
end
% morphological filtering 形态滤波
scale_num=5;
%D= MorF(G);
D1= MorF(G1,scale_num);
D2= MorF(G2,scale_num);

%D1= MSEG(G1);
%D2= MSEG(G2);
% trimap generation 
T1= TriG(D1);
figure,imshow(T1);
% imwrite(T1,'C:\Users\li\Desktop\T(3i+1).png','png');
T2= TriG(D2);
% alpha estimation (here the closed form matting method is used for the
% MATLAB implementation of the proposed method), the matting method actually
% has a little influence to the fusion performance
Alpha1=AlpE(I1,T1);
Alpha2=AlpE(I2,T2);
Alpha= L_Alpha(Alpha1,Alpha2);
 figure,imshow(Alpha);
 %imwrite(Alpha,'E:\daima\my multi-focus image fusion\results\Mine\CESHI.png','png');
F=AlpF(I1,Alpha);

function [G] = rgb2gray_n( I )  %转灰度图
N=size(I,4);
for i=1:N
    G(:,:,i)=rgb2gray(I(:,:,:,i));
end
%function [D] = MorF( I )  %形态滤波
%B=strel('disk',2);   %盘状结构元素
%N = size(I,3);
%D = zeros(size(I,1),size(I,2),N); % Assign memory
%for i = 1:N
    %db=I(:,:,i)-imopen(I(:,:,i),B);  %imopen开运算
    %dd=imclose(I(:,:,i),B)-I(:,:,i);  %imclose闭运算
    %D(:,:,i) = max(db,dd);  %两个变换的最大值定义为相应像素的焦点值
%end
%D=uint8(D);
function [D] = MorF( I,num ) %聚焦测量
img = double(I);
D = double(zeros(size(I)));
for ii = 1:num
    scale = 3 * ii + 1;
    se=strel('disk',scale);
    g1=img-imopen(img,se);
    g2=imclose(img,se)-img;
    g=max(g1,g2);
    D=D+1/scale*(g);
    
    %scale=5 * ii + 3;%阈值
    %[x,y]=gradient(img);   %获取梯度
    %t=sqrt(x.^2+y.^2);  
    %img(t>=scale)=255;           %梯度提取边缘 画黑
    %img(t<scale)=0;
    %D=D+1/scale*(img);
    
    %scale=2 * ii + 1;%标准差大小
    %window=double(uint8(3*scale)*2+1);%窗口大小一半为3*sigma
    %H=fspecial('gaussian', window, scale);%fspecial('gaussian', hsize, sigma)产生滤波模板
    %为了不出现黑边，使用参数'replicate'（输入图像的外部边界通过复制内部边界的值来扩展）
    %img_gauss=imfilter(img,H,'replicate');
    %img1=img-img_gauss;
    %D=D+1/scale*(img1);
end
return
    %figure,imshow(D);

function [T] = TriG(D)  %分割
[w h N]=size(D);
for i=1:N
   r=zeros(w,h);
   ED=D;
   ED(:,:,i)=[];
   [max_D]=max(ED,[],3);  %两个变换的最大值被定义为相应像素聚焦值
   r(find(D(:,:,i)>max_D))=1; %最大值位置取1，否则取0
   r=medfilt2(r,[8 8]);  %中值滤波
   r=bwmorph(r,'skel',5);  %bwmorph;对二值图像形态学操作；skel:n = Inf时，移除目标边界像素，但是不允许目标分隔开，保留下来的像素组合成图像的骨架
   r=medfilt2(r,[8 8]);  %中值滤波
   Enumber=[1:N];
   Enumber(Enumber==i)=[];
   Minu_D=D(:,:,i)-max(D(:,:,Enumber),[],3);  %C = max(A,[],dim)返回A中有dim指定的维数范围中的最大值
   r(Minu_D>127)=1;
   R(:,:,i)=r;
   %figure,imshow(R);
end


for j=1:N-1
    t=0.5.*ones(w,h);
    ER=R;
    ER(:,:,j)=[];
   [max_R]=max(ER,[],3);
   %p = prewitt(I(:,:,i));
   t(find(R(:,:,j)==1&max_R==0))=1; 
   t(find(R(:,:,j)==0&max_R==1))=0;   
   T(:,:,j)=t;  %trimap 最终三分图
   %figure,imshow(T);
   %T(:,:,j)=bwmorph(T(:,:,j), 'spur', Inf);
   %figure,imshow(T);
   %imwrite(T,'C:\Users\li\Desktop\1.png','png');
end
function [Alpha] = AlpE( I,T )
[r c N] = size(T); %获取三分图尺寸
I=double(I)/255;
%%%parameters of the matting method 抠图方法的参数
if (~exist('thr_alpha','var')) %检测变量是否存在，存在返回1，不存在返回0
  thr_alpha=[];
end
if (~exist('epsilon','var'))
  epsilon=[];
end
if (~exist('win_size','var'))
  win_size=[];
end

if (~exist('levels_num','var'))
    
    if r*c>768*768 %选择levels_num
    levels_num=4;
    elseif r*c>512*512
    levels_num=3;
    elseif r*c>256*256
        levels_num=2;
    else
        levels_num=1;
    end
end  
if (~exist('active_levels_num','var'))
  active_levels_num=1;
end
%%%%
for i=1:N
    cM=zeros(r,c);
    cM(T(:,:,i)~=0.5)=1;  %T中的值不等于0.5时，cM值为1
    cV=zeros(r,c);
    cV(T(:,:,i)==1)=1;   %T中的值为1时，cV值为1
    if size(I,4)>1  %彩色图像
    Alpha(:,:,i)=solveAlphaC2F(I(:,:,:,i),cM,cV,levels_num, ...
                    active_levels_num,thr_alpha,epsilon,win_size);
    else
    Alpha(:,:,i)=solveAlphaC2F(I(:,:,i),cM,cV,levels_num, ...
                    active_levels_num,thr_alpha,epsilon,win_size);
    end
    %p = prewitt(I(:,:,i));
    %a(find(p>0| Alpha(:,:,i)>0))=1;   
    %A(:,:,i)=a;
    %Alpha=medfilt2(Alpha,[8 8]);
   % figure,imshow(Alpha);
end
function Alpha= L_Alpha(Alpha1,Alpha2)
[w h N]=size(Alpha1);
k=zeros(w,h);
for j=1:N
    k(find(Alpha1(:,:,j)>=0.5&Alpha2(:,:,j)<=0.5))=1;
    k(find(Alpha1(:,:,j)<0.5&Alpha2(:,:,j)>0.5))=0;   
    Alpha(:,:,j)=k;
    Alpha(:,:,j)=medfilt2(Alpha(:,:,j),[4 4]);
   
end
function [F] = AlpF(I,Alpha)
N=size(Alpha,3);
Alp=Alpha;
Alp(:,:,N+1)=1-double(uint8(sum(Alpha,3)*255))/255;  %uint强制转换函数，大于255的强制置为255，小于255保持不变。sum(A,3)三通道中的每个通道值相加和
I=double(I)/255;
for i=1:N+1
    if size(I,4)>1
        F(:,:,:,i)=I(:,:,:,i).*repmat(Alp(:,:,i),[1 1 3]);%B = repmat(A, [mn p...]) %B = repmat(A, [mn p...]) B由m*n*p*...个A块平铺而成
    else
        F(:,:,i)=I(:,:,i).*Alp(:,:,i);
    end
end
if size (I,4)>1
F=uint8(sum(F,4)*255);
else
F=uint8(sum(F,3)*255);
end


