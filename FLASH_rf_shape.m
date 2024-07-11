function [xx,yy,width] = FLASH_rf_shape(weight, layer_thickness, wer_ratio, physical_base_thickness, bar_width, bar_num)
%   function [xx,yy,width] = script_rfshape(weight)
%   weight: pristine bragg peak weight
%   layer_thickness: water equivalent step of prisitine bragg peak
%   wer_ratio: manufacturing material stopping power ratio
%   physical_base_thickness: RF base
%   bar_width: RF peak width
%   bar_num: number of bar
%   xx(output): lateral coordinate
%   yy(output): height coordinate
%   clearvars x x0 x1 xx y y0 y1 yy

tot_weight = sum(weight);                   % 计算总权重                                
weight = weight/tot_weight;                 % 权重归一化
bar_half_width = 0.5*bar_width;             % 半个底部最大权重的宽度
if iscolumn(weight)                         % 权重转成横向量
    weight=weight';
end
inverse_weight = weight(end:-1:1);          % 反向权重矩阵
aperiod = [weight, inverse_weight];         % 从1mm到30mm再到1mm的排布
aperiod = cumsum(aperiod);                  % 计算水平方向上的累积分布，半边的权重是1，两边权重就是2
x1 = aperiod*bar_half_width;                % 把单位尺寸扩展到需要的最大脊形过滤器尺寸

x0 = x1(1:length(x1)-1);                    % 把index从0开始计算，x1是把权重扩展到脊形过滤器尺寸后的累积分布
x0 = [0, x0];
x(1:2:2*length(x0)) = x0;                   % 奇数=x0
x(2:2:2*length(x0)) = x1;                   % 偶数=x1

xx=[];
for i=1:bar_num                             % 根据脊形过滤器的数量整体添加一个偏移量，如果有多个脊形过滤器的话
    offset = (i-1)*bar_width;
    xx = [xx x+offset]; 
end

y0=[0:length(weight)-1]*layer_thickness/wer_ratio + physical_base_thickness;    % 生成权重数量的参数
y1=y0;                                      
y(1:2:2*length(y0)) = y0;                   % 奇数=y0 一共生成了2倍的步长数量，对于半边
y(2:2:2*length(y0)) = y1;                   % 偶数=y1 
inv_y = y(end:-1:1);                            
y = [y inv_y];                              % y的总长度是2x单边的数量x2=4倍步长的数量

yy=[];
for i=1:bar_num
    yy = [yy y];
end

width = bar_half_width - x0(1:length(x0)/2);
width = width'*2;