function [ F ] = MIFM(img1,img2)
if size(img1,3)==3
I1=rgb2gray(img1); %ת�Ҷ�ͼ
else
I1=img1;
end

if size(img2,3)==3
I2=rgb2gray(img2); %ת�Ҷ�ͼ
else
I2=img2;
end
 %morphological filtering ��̬�˲�
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


function [R] = TriG(D,max_D)  %�ָ�
[w h N]=size(D);
for i=1:N
   r=zeros(w,h);
   %[max_D]=max(D1,D2);  %�����任�����ֵ������Ϊ��Ӧ���ؾ۽�ֵ
   r(find(D>=max_D))=1; %���ֵλ��ȡ1������ȡ0
   r=medfilt2(r,[8 8]);  %��ֵ�˲�
   r=bwmorph(r,'skel',5);  %bwmorph;�Զ�ֵͼ����̬ѧ������skel:n = Infʱ���Ƴ�Ŀ��߽����أ����ǲ�����Ŀ��ָ���������������������ϳ�ͼ��ĹǼ�
   r=medfilt2(r,[8 8]);  %��ֵ�˲�
   Minu_D=D-max(D,[],3);  %C = max(A,[],dim)����A����dimָ����ά����Χ�е����ֵ
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
[r c N] = size(T); %��ȡ����ͼ�ߴ�
I=double(I)/255;
%%%parameters of the matting method ��ͼ�����Ĳ���
if (~exist('thr_alpha','var')) %�������Ƿ���ڣ����ڷ���1�������ڷ���1
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
    cM(T(:,:,i)~=0.5)=1;  %T�е�ֵ������0.5ʱ��cMֵΪ1
    cV=zeros(r,c);
    cV(T(:,:,i)==1)=1;   %T�е�ֵΪ1ʱ��cVֵΪ1
    if size(I,4)>1  %��ɫͼ��
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
%Alp(:,:,N+1)=1-double(uint8(sum(Alpha,3)*255))/255;  %uintǿ��ת������������255��ǿ����Ϊ255��С��255���ֲ��䡣sum(A,3)��ͨ���е�ÿ��ͨ��ֵ��Ӻ�
%I=double(I)/255;
%for i=1:N
    F=img1.*Alpha+img2.*(1-Alpha);
    F=uint8(F);
    %imgf=img1.*finalMap+img2.*(1-finalMap); 
    %if size(I,4)>1
       % F(:,:,:,i)=I(:,:,:,i).*repmat(Alp(:,:,i),[1 1 3]);%B = repmat(A, [mn p...]) %B = repmat(A, [mn p...]) B��m*n*p*...��A��ƽ�̶���
    %else
       % F(:,:,i)=I(:,:,i).*Alp(:,:,i);
   % end
%end
%if size (img1,4)>1
%F=uint8(sum(F,4)*255);
%else
%F=uint8(sum(F,3)*255);
%end






