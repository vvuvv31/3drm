clear;clc
matRad_rc
addpath('Z:\ku_3drm')
addpath('X:\test')

savepath = 'Z:\ku_3drm\';
load("X:\mod_matRad\basedata\protons_3drm.mat")
purerange = 317;
%% set plan parameter
load("Z:\ku_3drm\phantom.mat")

pln.radiationMode = 'protons';            
pln.machine       = '3drm';
pln.propOpt.bioOptimization = 'none';                                              
pln.numOfFractions        = 30;
pln.propStf.gantryAngles  = 0;
pln.propStf.couchAngles   = 0;
pln.propStf.bixelWidth    = 4;
pln.propStf.numOfBeams    = numel(pln.propStf.gantryAngles);
pln.propStf.isoCenter     = ones(pln.propStf.numOfBeams,1) * matRad_getIsoCenter(cst,ct,0);
pln.propOpt.runDAO        = 0;
pln.propOpt.runSequencing = 0;
pln.propDoseCalc.doseGrid.resolution.x = ct.resolution.x; % [mm]
pln.propDoseCalc.doseGrid.resolution.y = ct.resolution.y; % [mm]
pln.propDoseCalc.doseGrid.resolution.z = ct.resolution.z; % [mm]

stf = matRad_generateStf(ct,cst,pln);

exp1_posOfRF = [stf.ray.rayPos_bev];
exp1_posOfRF = reshape(exp1_posOfRF,[3,length(exp1_posOfRF)/3]);

rounds = 0.1;
%% optimize rf shape
[width, rf_pos, stf]= FLASH_optimize_SOBP(pln, ct, cst,machine, rounds);

exp_rf_pos = zeros(3,10);
exp_rf_pos(:,1:5) = rf_pos(:,1:5);
exp_rf_pos(:,6:10) = rf_pos(:,21:25);
exp_rf_pos(1,1:5) = exp_rf_pos(1,1:5) - pln.propStf.bixelWidth;
exp_rf_pos(1,6:10) = exp_rf_pos(1,6:10) + pln.propStf.bixelWidth;

%% generate 3drm
peak_shift = FLASH_generate_3drm(rf_pos, savepath, purerange, stf, width, pln.propStf.bixelWidth ,1, exp_rf_pos); % bar_width and layer_thickness




