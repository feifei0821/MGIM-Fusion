function coeff=getLinearCoeff(alpha,I,epsilon,win_size)
  
  if (~exist('epsilon','var'))
    epsilon=0.0000001;
  end  
  if (isempty(epsilon))
    epsilon=0.0000001;
  end
  if (~exist('win_size','var'))
    win_size=1;
  end
  if (isempty(win_size))
    win_size=1;
  end  
  neb_size=(win_size*2+1)^2;
  [h,w,c]=size(I);
  n=h; m=w;
  img_size=w*h;
  
  
  indsM=reshape([1:img_size],h,w); % b=reshape（a,m,n）先把矩阵a按列拆分，然后拼接成一个大小为m*n的向量。然后对这个向量每隔m间隔取一个元素组成一个向量b_i，之后的向量b_i+1也是这样生成，只不过第一个元素往下移一位。这样做完之后得到m个大小为n的行向量，将这些行向量拼接即可得到矩阵b

  coeff=zeros(h,w,c+1);
  
 
  for j=1+win_size:w-win_size
    for i=win_size+1:h-win_size
   
      win_inds=indsM(i-win_size:i+win_size,j-win_size:j+win_size);
      win_inds=win_inds(:);
      winI=I(i-win_size:i+win_size,j-win_size:j+win_size,:);
      winI=reshape(winI,neb_size,c);
      
      
      G=[[winI,ones(neb_size,1)];[eye(c)*epsilon^0.5,zeros(c,1)]]; %eye函数返回单位矩阵
      
      tcoeff=inv(G'*G)*G'*[alpha(win_inds);zeros(c,1)];
      coeff(i,j,:)=reshape(tcoeff,1,1,c+1);
      
     
    end
  end  
  
  
  coeff(1:win_size,:,:)=repmat(coeff(win_size+1,:,:),win_size,1);
  coeff(end-win_size+1:end,:,:)=repmat(coeff(end-win_size,:,:),win_size,1);
  coeff(:,1:win_size,:)=repmat(coeff(:,win_size+1,:),1,win_size);
  coeff(:,end-win_size+1:end,:)=repmat(coeff(:,end-win_size,:),1,win_size);
  