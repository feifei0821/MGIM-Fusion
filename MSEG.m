function [ g ] = MSEG( I )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
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

g =(g11+g22+g33+g44+g55+g66+g77+g88);

end

