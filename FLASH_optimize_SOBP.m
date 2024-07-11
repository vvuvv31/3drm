function [width, rf_pos, bar_width, stf, layer_thickness]= FLASH_optimize_SOBP(pln, ct, cst,machine)

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
    totp = zeros(341,1);
    w_count = 1;
    for j = 1:stf.numOfRays
        energy = [stf.ray(j).energy];
        ix = zeros(numel(energy),1);
        peakpos = zeros(numel(energy),1);
        dist = zeros(341,numel(energy));
        for i = 1:numel(energy)
            ix(i) = find(energy(i)==energy_ix);
            peakpos(i) = machine.data(ix(i)).peakPos;
            dist(:,i) = machine.data(ix(i)).Z;
        end
        beginDepth = min(peakpos);
        endDepth = max(peakpos);
        
        peakNums = numel(energy);
    
        targetDose = 10;
        w=ones(peakNums,1);
        w(1) = 10; 
        w(end) = 3;
        w = w/10;   
        costFunction = @(w) FLASH_s_sobp_cost(w, dist, beginDepth, endDepth, targetDose);
        options = optimoptions('fmincon', ...
                               'Display', 'iter', ...
                               'Algorithm', 'interior-point', ...
                               'MaxIterations', 1000, ...
                               'OptimalityTolerance', 1e-10, ... 
                               'StepTolerance', 1e-16, ...
                               'MaxFunctionEvaluations', 50000);
    
    
        w_opt = fmincon(costFunction,w,[],[],[],[],zeros(peakNums,1),[],[],options);
        w_count = w_count + numel(w_opt);
    
        totp = totp + dist * w_opt;

%         figure;
%         plot(dist * w_opt)
%         hold on
%         for j=1:numel(energy)
%             plot(dist(:,j) .* w_opt(j))
%         end
%         hold off
%         pause


        weight = w_opt;
        layer_thickness = 2;
        wer_ratio = 1;
        physical_base_thickness = layer_thickness;
        bar_width = pln.propStf.bixelWidth;
        bar_num = 1;
    
        [~,~,width{j}]=FLASH_rf_shape(weight, layer_thickness, wer_ratio, physical_base_thickness, bar_width, bar_num);
   
        end
    end