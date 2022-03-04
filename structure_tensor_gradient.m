close all;
clc;

I = double(rgb2gray(imread('C:\Users\li\Desktop\t.jpg')));
%figure;
%imshow(I);
[m,n] = size(I);
%the gradient of image

[Ix,Iy] = gradient(I);
%second derivative

Ix2 = Ix.^2;
Iy2 = Iy.^2;
Ixy = Ix.*Iy;

k = 1;
%relationship between det and trace
lam = zeros(m*n,2);
for i = 1:m
    for j = 1:n
        %Structure Tensor Matrix
        ST = [Ix2(i,j) Ixy(i,j);Ixy(i,j) Iy2(i,j)];
        K = det(ST);    %det of ST
        H = trace(ST);  %trace of ST
       if H < 50                                   %smooth area
          I(i,j) = 0;
       end
         if H > 50 && abs(K) < 0.01*10^(-9)        %marginal area
          I(i,j) = 255;

         end

     if H > 50 && abs(K) > 0.01*10^(-9)            %corner are

          I(i,j) = 255;

      end           

            

        lam(k,:) = [K,H];

        k = k + 1;

    end

end

 

figure;

plot(lam(:,1),lam(:,2),'.');

ylabel('trace');

xlabel('det');

 

figure;

imshow(I,[]),title('corner area');   %自动调整输出格式
