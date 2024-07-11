clear
addpath("Z:\ku_3drm\data")
thickness = [2:2:40];
idd = zeros(341,20);
load("X:\pure_matRad\basedata\protons_Generic.mat")
machine.data(21:end) = [];


for x = 1:length(thickness)
    load(strcat('Z:\ku_3drm\data\', num2str(thickness(x)), 'mm.mat'))
%     fileID = fopen(strcat("Z:\ku_3drm\basedata\legacy\dose",num2str(thickness(x)),".bin"), 'r');
%     img = fread(fileID, 'double');
%     img = reshape(img,[200,200,400]);
%     IDD = flip(squeeze(sum(sum(img,2),1)));

    idd(:,x) = IDD(1:341);
    [~, peakpos(x)] = max(IDD);
    machine.data(x).range = peakpos(x) + 2;
    machine.data(x).energy = thickness(x);
    machine.data(x).peakPos = peakpos(x);
    machine.data(x).Z = IDD(1:341)';
end

save('X:\mod_matRad\basedata\protons_3drm.mat', "machine")
save('Z:\ku_3drm\protons_3drm.mat', "machine")

fclose('all');