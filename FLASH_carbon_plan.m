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
pln.propStf.bixelWidth    = 3;
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



%% optimize rf shape
[width, rf_pos, bar_width, stf,layer_thickness]= FLASH_optimize_SOBP(pln, ct, cst,machine);

%% generate 3drm
peak_shift = FLASH_generate_3drm(rf_pos, savepath, purerange, stf, width, bar_width,layer_thickness);




