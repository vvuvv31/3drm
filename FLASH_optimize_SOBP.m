function [width, rf_pos, stf]= FLASH_optimize_SOBP(pln, ct, cst,machine,rounds)

    pln.propStf.bixelWidth = pln.propStf.bixelWidth;
    stf = matRad_generateStf(ct,cst,pln);
    rf_pos = [stf.ray.rayPos_bev];
    rf_pos = reshape(rf_pos,[3,length(rf_pos)/3]);
    
    emptyCells = cellfun(@isempty, stf.depth);
    stf.depth = stf.depth(~emptyCells);
    
    stf.exit = stf.exit(~emptyCells);
    stf.exit = cell2mat(stf.exit);
    
    stf.enter = stf.enter(~emptyCells);
    stf.enter = cell2mat(stf.enter);

    energy_ix = [machine.data.energy];
    totp = zeros(180,1);
    w_count = 1;
    for j = 1:stf.numOfRays
        energy = [stf.ray(j).energy];
        ix = zeros(numel(energy),1);
        peakpos = zeros(numel(energy),1);
        for i = 1:numel(energy)
            ix(i) = find(energy(i)==energy_ix);
            peakpos(i) = machine.data(ix(i)).peakPos;
        end
        beginDepth = min(peakpos);
        endDepth = max(peakpos);
        
        peak = [machine.data.peakPos];

        endIx= abs(beginDepth - peak);
        beginIx = abs(endDepth - peak);
        [~, endIx] = min(endIx);
        [~, beginIx] = min(beginIx);
        dist = zeros(180,endIx - beginIx+1);
        for i = 1:size(dist,2)
            dist(:,i) = machine.data(beginIx + i - 1).Z;
        end
        dist = dist / max(dist(:));

        beginDepth = find(beginDepth ==machine.data(1).depths);
        endDepth = find(endDepth ==machine.data(1).depths);
        peakNums = size(dist,2);
    
        widths=ones(size(dist,2),1);
        widths(1) = 3; 
        widths = widths/10;   
        
        costFunction = @(widths) FLASH_s_sobp_cost(widths, dist, beginDepth, endDepth);
        options = optimoptions('fmincon', ...
                               'Display', 'iter', ...
                               'Algorithm', 'interior-point', ...
                               'MaxIterations', 1000, ...
                               'OptimalityTolerance', 1e-10, ... 
                               'StepTolerance', 0.01, ...
                               'MaxFunctionEvaluations', 50000, ...
                               'FiniteDifferenceStepSize', 0.1);

        width_opt = fmincon_fixed_first_value(costFunction,widths,[],[],zeros(peakNums,1),[],[],options);
        w_opt = -diff(width_opt);w_opt(end+1) = width_opt(end);

        rounded_width = round(width_opt / rounds) * rounds;
        round_w_opt = -diff(rounded_width);round_w_opt(end+1) = rounded_width(end);
        
%         figure;
%         hold on
%         % plot(dist * w_opt/max(dist * w_opt),'k')
%         plot(dist * round_w_opt/max(dist * round_w_opt),'r')
%         hold off
%         pause
        width{j} = rounded_width;

%         weight = w_opt;
%         layer_thickness = 1;
%         wer_ratio = 1;
%         physical_base_thickness = layer_thickness;
%         bar_width = pln.propStf.bixelWidth;
%         bar_num = 1;
%     
%         [~,~,width{j}]=FLASH_rf_shape(weight, layer_thickness, wer_ratio, physical_base_thickness, bar_width, bar_num);
   
    end


    function x = fmincon_fixed_first_value(objective, x0, A, b, lb, ub, nonlcon, options)
        % 确定变量的数量
        n = length(x0);
        
        % 定义线性等式约束
        Aeq = zeros(1, n);
        Aeq(1) = 1;  % 第一个变量的系数为1
        beq = 3;     % 第一个变量的值为3

        % 定义线性不等式约束(变量必须递减)
        A_decreasing = zeros(n-1, n);
        for i = 1:(n-1)
            A_decreasing(i, i) = -1;
            A_decreasing(i, i+1) = 1;
        end
        b_decreasing = zeros(n-1, 1);
        
        % 合并线性约束
        A_combined = [A; A_decreasing];
        b_combined = [b; b_decreasing];

        % 调用fmincon函数,并传递线性等式约束
        x = fmincon(objective, x0, A_combined, b_combined, Aeq, beq, lb, ub, nonlcon, options);
    end



    function y = FLASH_s_sobp_cost(width, dist, beginIndex, endIndex)
        w = -diff(width);
        w(end+1) = width(end);
        totp = dist * w;
        relativeError = abs(totp(beginIndex:endIndex) - mean(totp(beginIndex:endIndex)));
        y = sum(relativeError.^2);
    end
end

