function [ BW ] = prewitt( A )
%PREWITT 此处显示有关此函数的摘要
%   此处显示详细说明
y_mask = [-1 -1 -1;0 0 0;1 1 1];  %建立Y方向的模板
x_mask = y_mask';  %建立X方向的模板
I = im2double(A);   %将图像数据转化为双精度
dx = imfilter(I, x_mask);  %计算X方向的梯度分量
dy = imfilter(I, y_mask);  %计算Y方向的梯度分量
grad = sqrt(dx.*dx + dy.*dy);  %计算梯度
grad = mat2gray(grad);   %将梯度矩阵转换为灰度图像
level = graythresh(grad);  %计算灰度阈值
BW = im2bw(grad,level);  %用阈值分割梯度图像

end

