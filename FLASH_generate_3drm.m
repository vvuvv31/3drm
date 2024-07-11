function peak_shift = FLASH_generate_3drm(rf_pos, savepath, purerange, stf, width, bar_width,layer_thickness)
    disp('generating 3drm...')
    posOfRF = rf_pos;
    
    count = 1;
    facet_normal = {[0 -1 0] [0 -1 0] [1 0 0] [1 0 0] [0 1 0] [0 1 0]...
                    [-1 0 0] [-1 0 0] [0 0 -1] [0 0 -1] [0 0 1] [0 0 1]};
    faces = [1 2 6; 1 6 5;
             2 3 7; 2 7 6;
             3 4 8; 3 8 7;
             4 1 5; 4 5 8;
             1 3 2; 1 4 3;
             5 6 7; 5 7 8];
    
    fid = fopen(strcat([savepath 'rf-ascii.stl']), 'w');
    fprintf(fid, 'solid cuboid\n');
    
    peak_shift = purerange - stf.exit;
    for n = 1:stf.numOfRays
    
    % generate single rf
        tmp = nnz(width{n});
        w = width{n}(1:tmp);
        l = ones(1,length(w)) * bar_width;
    
        bar_width = bar_width * 0.9999;
        l = l * 0.9999;
        w = w * 0.9999;
        h = ((1:length(l)) - 1) * layer_thickness;
    
        ix = FLASH_s_indexpair(w);
        vertices = cell([1,length(ix)]);
        for i = 1:numel(ix)/2 % 长方体顶点的位置
            vertices{i} = [0          0          peak_shift(n) + h(ix(i,1));
                           l(ix(i,1)) 0          peak_shift(n) + h(ix(i,1));
                           l(ix(i,1)) w(ix(i,1)) peak_shift(n) + h(ix(i,1));
                           0          w(ix(i,1)) peak_shift(n) + h(ix(i,1));
                           0          0          peak_shift(n) + h(ix(i,2))+0.9999 * layer_thickness;
                           l(ix(i,1)) 0          peak_shift(n) + h(ix(i,2))+0.9999 * layer_thickness;
                           l(ix(i,1)) w(ix(i,1)) peak_shift(n) + h(ix(i,2))+0.9999 * layer_thickness;
                           0          w(ix(i,1)) peak_shift(n) + h(ix(i,2))+0.9999 * layer_thickness];
            vertices{i} = vertices{i} + [posOfRF(1,n),posOfRF(3,n),0] - [l(ix(i,1))/2, w(ix(i,1))/2, 0];
        end
        
    % generate single rs
        vertices{length(ix)+1} = [0     0       0;
                           bar_width 0          0;
                           bar_width bar_width  0;
                           0         bar_width  0;
                           0         0          peak_shift(n)-0.0001;
                           bar_width 0          peak_shift(n)-0.0001;
                           bar_width bar_width  peak_shift(n)-0.0001;
                           0         bar_width  peak_shift(n)-0.0001];
        vertices{length(ix)+1} = vertices{length(ix)+1} + [posOfRF(1,n),posOfRF(3,n),0] - [bar_width/2, bar_width/2, 0];
    
    
        for i = 1:length(vertices)
            current_vertices = vertices{i};
        
            for j = 1:size(faces, 1)
                fprintf(fid, 'facet normal %d %d %d\n',facet_normal{j});
                fprintf(fid, '  outer loop\n');
                for k = 1:3
                    vert = current_vertices(faces(j, k), :);
                    fprintf(fid, '    vertex %f %f %f\n', vert);
                end
                fprintf(fid, '  endloop\n');
                fprintf(fid, 'endfacet\n');
            end
            count = count + 1;
        end
    end
    
    
    fprintf(fid, 'endsolid cuboid\n');
    fclose(fid);

    disp('generate 3drm successfully')
    disp(strcat([savepath 'rf-ascii.stl']))
end