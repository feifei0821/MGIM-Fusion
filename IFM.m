function [ F ] = IFM(I1,I2)
if size(I1,3)==3
G1=rgb2gray_n(I1); %ת�Ҷ�ͼ
else
G1=I1;
end
if size(I2,3)==3
G2=rgb2gray_n(I2); %ת�Ҷ�ͼ
else
G2=I2;
end
% morphological filtering ��̬�˲�
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

function [G] = rgb2gray_n( I )  %ת�Ҷ�ͼ
N=size(I,4);
for i=1:N
    G(:,:,i)=rgb2gray(I(:,:,:,i));
end
%function [D] = MorF( I )  %��̬�˲�
%B=strel('disk',2);   %��״�ṹԪ��
%N = size(I,3);
%D = zeros(size(I,1),size(I,2),N); % Assign memory
%for i = 1:N
    %db=I(:,:,i)-imopen(I(:,:,i),B);  %imopen������
    %dd=imclose(I(:,:,i),B)-I(:,:,i);  %imclose������
    %D(:,:,i) = max(db,dd);  %�����任�����ֵ����Ϊ��Ӧ���صĽ���ֵ
%end
%D=uint8(D);
function [D] = MorF( I,num ) %�۽�����
img = double(I);
D = double(zeros(size(I)));
for ii = 1:num
    scale = 3 * ii + 1;
    se=strel('disk',scale);
    g1=img-imopen(img,se);
    g2=imclose(img,se)-img;
    g=max(g1,g2);
    D=D+1/scale*(g);
    
    %scale=5 * ii + 3;%��ֵ
    %[x,y]=gradient(img);   %��ȡ�ݶ�
    %t=sqrt(x.^2+y.^2);  
    %img(t>=scale)=255;           %�ݶ���ȡ��Ե ����
    %img(t<scale)=0;
    %D=D+1/scale*(img);
    
    %scale=2 * ii + 1;%��׼���С
    %window=double(uint8(3*scale)*2+1);%���ڴ�Сһ��Ϊ3*sigma
    %H=fspecial('gaussian', window, scale);%fspecial('gaussian', hsize, sigma)�����˲�ģ��
    %Ϊ�˲����ֺڱߣ�ʹ�ò���'replicate'������ͼ����ⲿ�߽�ͨ�������ڲ��߽��ֵ����չ��
    %img_gauss=imfilter(img,H,'replicate');
    %img1=img-img_gauss;
    %D=D+1/scale*(img1);
end
return
    %figure,imshow(D);

function [T] = TriG(D)  %�ָ�
[w h N]=size(D);
for i=1:N
   r=zeros(w,h);
   ED=D;
   ED(:,:,i)=[];
   [max_D]=max(ED,[],3);  %�����任�����ֵ������Ϊ��Ӧ���ؾ۽�ֵ
   r(find(D(:,:,i)>max_D))=1; %���ֵλ��ȡ1������ȡ0
   r=medfilt2(r,[8 8]);  %��ֵ�˲�
   r=bwmorph(r,'skel',5);  %bwmorph;�Զ�ֵͼ����̬ѧ������skel:n = Infʱ���Ƴ�Ŀ��߽����أ����ǲ�����Ŀ��ָ���������������������ϳ�ͼ��ĹǼ�
   r=medfilt2(r,[8 8]);  %��ֵ�˲�
   Enumber=[1:N];
   Enumber(Enumber==i)=[];
   Minu_D=D(:,:,i)-max(D(:,:,Enumber),[],3);  %C = max(A,[],dim)����A����dimָ����ά����Χ�е����ֵ
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
   T(:,:,j)=t;  %trimap ��������ͼ
   %figure,imshow(T);
   %T(:,:,j)=bwmorph(T(:,:,j), 'spur', Inf);
   %figure,imshow(T);
   %imwrite(T,'C:\Users\li\Desktop\1.png','png');
end
function [Alpha] = AlpE( I,T )
[r c N] = size(T); %��ȡ����ͼ�ߴ�
I=double(I)/255;
%%%parameters of the matting method ��ͼ�����Ĳ���
if (~exist('thr_alpha','var')) %�������Ƿ���ڣ����ڷ���1�������ڷ���0
  thr_alpha=[];
end
if (~exist('epsilon','var'))
  epsilon=[];
end
if (~exist('win_size','var'))
  win_size=[];
end

if (~exist('levels_num','var'))
    
    if r*c>768*768 %ѡ��levels_num
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
Alp(:,:,N+1)=1-double(uint8(sum(Alpha,3)*255))/255;  %uintǿ��ת������������255��ǿ����Ϊ255��С��255���ֲ��䡣sum(A,3)��ͨ���е�ÿ��ͨ��ֵ��Ӻ�
I=double(I)/255;
for i=1:N+1
    if size(I,4)>1
        F(:,:,:,i)=I(:,:,:,i).*repmat(Alp(:,:,i),[1 1 3]);%B = repmat(A, [mn p...]) %B = repmat(A, [mn p...]) B��m*n*p*...��A��ƽ�̶���
    else
        F(:,:,i)=I(:,:,i).*Alp(:,:,i);
    end
end
if size (I,4)>1
F=uint8(sum(F,4)*255);
else
F=uint8(sum(F,3)*255);
end


