function balpha=upSampleAlphaUsingImg(alpha,I,bI,varargin)
  
  
  coeff=getLinearCoeff(alpha,I,varargin{:}); %��ȡ����ϵ��
  
  bcoeff=upSmpIm(coeff,[size(bI,1),size(bI,2)]); %�ϲ���
  
  balpha=bcoeff(:,:,end);
  
  for k=1:size(bI,3)
    balpha=balpha+bcoeff(:,:,k).*bI(:,:,k);
  end
  