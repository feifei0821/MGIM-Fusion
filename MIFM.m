function [ F ] = MIFM(img1,img2)
if size(img1,3)==3
I1=rgb2gray(img1); %转灰度图
else
I1=img1;
end

if size(img2,3)==3
I2=rgb2gray(img2); %转灰度图
else
I2=img2;
end
 %morphological filtering 形态滤波
num=3;
%D= MorF(G);
D1= multiscale_morph(I1,num);
D2= multiscale_morph(I2,num);
%figure,imshow(D1);
%imwrite(D1,'C:\Users\li\Desktop\focus information1.png','png');
%figure,imshow(D2);
%imwrite(D2,'C:\Users\li\Desktop\focus information2.png','png');
max_img=max(I1,I2);
max_D=max(D1,D2);
% trimap generation 
R1= TriG(D1,max_D);
R2= TriG(D2,max_D);

T1 = Trimap(I1,R1,R2);
T2 = Trimap(I2,R1,R2);
% alpha estimation (here the closed form matting method is used for the
% MATLAB implementation of the proposed method), the matting method actually
% has a little influence to the fusion performance
Alpha1=AlpE(img1,T1);
Alpha2=AlpE(img2,T2);
% Alpha3=AlpE(max_img,T1);

L_Alpha = L_Alpha(img1,Alpha1,Alpha2)
F=AlpF(img1,img2, L_Alpha);


function [R] = TriG(D,max_D)  %分割
[w h N]=size(D);
for i=1:N
   r=zeros(w,h);
   %[max_D]=max(D1,D2);  %两个变换的最大值被定义为相应像素聚焦值
   r(find(D>=max_D))=1; %最大值位置取1，否则取0
   r=medfilt2(r,[8 8]);  %中值滤波
   r=bwmorph(r,'skel',5);  %bwmorph;对二值图像形态学操作；skel:n = Inf时，移除目标边界像素，但是不允许目标分隔开，保留下来的像素组合成图像的骨架
   r=medfilt2(r,[8 8]);  %中值滤波
   Minu_D=D-max(D,[],3);  %C = max(A,[],dim)返回A中有dim指定的维数范围中的最大值
   r(Minu_D>127)=1;
   R(:,:,i)=r;
  % figure,imshow(R);
end

function [T] = Trimap(img1,R1,R2)
[w h N]=size(R1);
t=0.5.*ones(w,h);
for j=1:N
    p = prewitt(img1(:,:,j));
    set = strel('disk',2);
    p = imdilate(p,set);
    t(find(R1(:,:,j)==1&R2(:,:,j)==0))=1;
    t(find(p>0))=1;
    t(find(R1(:,:,j)==0&R2(:,:,j)==1))=0;   
    T(:,:,j)=t;
    figure,imshow(T);
end

function [Alpha] = AlpE( I,T )
[r c N] = size(T); %获取三分图尺寸
I=double(I)/255;
%%%parameters of the matting method 抠图方法的参数
if (~exist('thr_alpha','var')) %检测变量是否存在，存在返回1，不存在返回1
  thr_alpha=[];
end
if (~exist('epsilon','var'))
  epsilon=[];
end
if (~exist('win_size','var'))
  win_size=[];
end

if (~exist('levels_num','var'))
    
    if r*c>768*768
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
end

function L_Alpha= L_Alpha(img1,Alpha1,Alpha2)
[w h N]=size(Alpha1);
k=zeros(w,h);
for j=1:N
    p = prewitt(img1);
    figure,imshow(p);
    k(find(Alpha1(:,:,j)>0.5|Alpha2(:,:,j)>0.5))=1; 
   % k(find(p(:,:,j)))==1;
    k(find(Alpha1(:,:,j)<0.5|Alpha2(:,:,j)<0.5))=0;   
    L_Alpha(:,:,j)=k;
    L_Alpha(:,:,j)=medfilt2(L_Alpha(:,:,j),[4 4]);
   % figure,imshow(L_Alpha);
end

function [F] = AlpF(img1,img2, Alpha)
%N=size(Alpha,3);
%Alp=Alpha;
%figure,imshow(img1);
img1 = double(img1);
img2 = double(img2);
if size(img1,3)>1
    Alpha=repmat(Alpha,[1 1 3]); 
end
figure,imshow(Alpha);
%imwrite(Alpha,'E:\daima\my multi-focus image fusion\results\Mine\map7.png','png');
%Alp(:,:,N+1)=1-double(uint8(sum(Alpha,3)*255))/255;  %uint强制转换函数，大于255的强制置为255，小于255保持不变。sum(A,3)三通道中的每个通道值相加和
%I=double(I)/255;
%for i=1:N
    F=img1.*Alpha+img2.*(1-Alpha);
    F=uint8(F);
    %imgf=img1.*finalMap+img2.*(1-finalMap); 
    %if size(I,4)>1
       % F(:,:,:,i)=I(:,:,:,i).*repmat(Alp(:,:,i),[1 1 3]);%B = repmat(A, [mn p...]) %B = repmat(A, [mn p...]) B由m*n*p*...个A块平铺而成
    %else
       % F(:,:,i)=I(:,:,i).*Alp(:,:,i);
   % end
%end
%if size (img1,4)>1
%F=uint8(sum(F,4)*255);
%else
%F=uint8(sum(F,3)*255);
%end






