%%%the MATLAB code for the paper "Image matting for fusion of multi-focus images
%%%in dynamic scenes" Author: Xudong Kang
%%%Donot hesitate to contact me if you meet any problems when implementing
%%%this code.
%%%Author: Xudong Kang;                                                            
%%%Email:xudong_kang@163.com
%%%Homepage:http://xudongkang.weebly.com

%%% Input I: two or more than two multifocus images
%%% Output F: a fused image
clear all;
close all;
%%%% gray image fusion
I1 = load_images( '.\sourceimages\image\a',1); 
I2 = load_images( '.\sourceimages\image\aa',1);
%figure,imshow(I);
tic;
F = IFM(I1,I2);
toc;
figure,imshow(F);
%imwrite(F,'E:\daima\my multi-focus image fusion\results\Mine\c.png','png');
% %%%% color image fusion
% I = load_images( '.\sourceimages\grayset',1); 
% F = IFM(I);
% figure,imshow(F);