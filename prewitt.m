function [ BW ] = prewitt( A )
%PREWITT �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
y_mask = [-1 -1 -1;0 0 0;1 1 1];  %����Y�����ģ��
x_mask = y_mask';  %����X�����ģ��
I = im2double(A);   %��ͼ������ת��Ϊ˫����
dx = imfilter(I, x_mask);  %����X������ݶȷ���
dy = imfilter(I, y_mask);  %����Y������ݶȷ���
grad = sqrt(dx.*dx + dy.*dy);  %�����ݶ�
grad = mat2gray(grad);   %���ݶȾ���ת��Ϊ�Ҷ�ͼ��
level = graythresh(grad);  %����Ҷ���ֵ
BW = im2bw(grad,level);  %����ֵ�ָ��ݶ�ͼ��

end

