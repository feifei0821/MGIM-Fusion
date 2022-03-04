function alpha=solveAlphaC2F(I,consts_map,consts_vals,levels_num,active_levels_num,varargin);

 
  
  
  if (length(varargin)>0) %length数组长度（行数或列数中的较大值）；varargin函数提供了一种函数可变参数列表机制，允许调用者调用该函数时根据需要来改变输入参数的个数。
    if (~isempty(varargin{1}))
      thr_alpha=varargin{1};
    end
  end  
 
  if (~exist('thr_alpha','var'))
    thr_alpha=0.02;
  end
  erode_mask_w=1;  %erode侵蚀
  active_levels_num=max(active_levels_num,1); %active_levels_num取值大于等于1
  if (levels_num>1)
    sI=downSmpIm(I,2); %对I下采样
    s_consts_map=round(downSmpIm(double(consts_map),2)); %round函数用于数据的四舍五入取整；double函数，强制类型转换，转换为double
    s_consts_vals=round(downSmpIm(double(consts_vals),2));
    s_alpha=solveAlphaC2F(sI,s_consts_map,s_consts_vals,levels_num-1,...
                          min(levels_num-1,active_levels_num),varargin{:});
    alpha=upSampleAlphaUsingImg(s_alpha,sI,I,varargin{2:end}); %根据图上采样
    talpha=alpha.*(1-consts_map)+consts_vals;
    consts_map=min(consts_map+imerode((alpha>=(1-thr_alpha)),ones(erode_mask_w*2+1))+imerode((alpha<=(thr_alpha)),ones(erode_mask_w*2+1)),1);  
    %imerode腐蚀
    consts_vals=round(talpha).*consts_map; %点运算是处理元素之间的运算，.*两矩阵的元素相乘
    %figure, imshow([consts_map,alpha])
  end
  if (active_levels_num>=levels_num)
    alpha=solveAlpha(I,consts_map,consts_vals,varargin{2:end});
  end
  

