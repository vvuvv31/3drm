function indexPairs = FLASH_s_indexpair(array)
    n = length(array); % 获取数组长度
    indexPairs = []; % 初始化结果数组
    beginIndex = 1; % 初始段的开始索引

    for i = 2:n % 从数组的第二个元素开始遍历
        if array(i) ~= array(i-1) % 如果当前元素与前一个元素不相同
            % 添加前一个段的开始和结束索引到结果数组
            indexPairs = [indexPairs; [beginIndex, i-1]];
            beginIndex = i; % 更新新段的开始索引
        end
    end

    % 处理数组最后一个数字段
    indexPairs = [indexPairs; [beginIndex, n]]; % 添加最后一个段的索引对
end