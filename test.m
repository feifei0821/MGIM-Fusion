clear all;
close all;

[imagename1, imagepath1]=uigetfile('Datasets\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the first input image');
img1 = imread (strcat(imagepath1,imagename1));
[imagename2, imagepath2]=uigetfile('Datasets\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the second input image');
img2 = imread (strcat(imagepath2,imagename2));

figure,imshow(img1);figure,imshow(img2);

%if size(img1, 3) == 3
    %img1 = rgb2gray(img1);
    %img2 = rgb2gray(img2);
%end 

%img1= double(img1);
%img2= double(img2); 

F=MIFM(img1,img2);
figure,imshow(F)
%imwrite(F,'C:\Users\li\Desktop\7.png','png');