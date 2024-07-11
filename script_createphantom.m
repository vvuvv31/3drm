clear
matRad_rc;
matRad_cfg.propDoseCalc.defaultLateralCutOff = 0.995;

%% Create a CT image series
xDim = 100;
yDim = 400;
zDim = 100;

ct.cubeDim      = [yDim xDim zDim]; % second cube dimension represents the x-coordinate
ct.resolution.x = 1;
ct.resolution.y = 1;
ct.resolution.z = 1;
ct.numOfCtScen  = 1;
 
ct.cubeHU{1} = ones(ct.cubeDim) * -1000; % assign HU of Air

ixOAR = 1;
ixPTV = 2;

% define general VOI properties
cst{ixOAR,1} = 0;
cst{ixOAR,2} = 'contour';
cst{ixOAR,3} = 'OAR';

cst{ixPTV,1} = 1;
cst{ixPTV,2} = 'target';
cst{ixPTV,3} = 'TARGET';
 
% define optimization parameter for both VOIs
cst{ixOAR,5}.TissueClass  = 1;
cst{ixOAR,5}.alphaX       = 0.1000;
cst{ixOAR,5}.betaX        = 0.0500;
cst{ixOAR,5}.Priority     = 2;
cst{ixOAR,5}.Visible      = 1;
cst{ixOAR,5}.visibleColor = [0 0 0];

% define objective as struct for compatibility with GNU Octave I/O
cst{ixOAR,6}{1} = struct(DoseObjectives.matRad_SquaredOverdosing(10,30));

cst{ixPTV,5}.TissueClass = 1;
cst{ixPTV,5}.alphaX      = 0.1000;
cst{ixPTV,5}.betaX       = 0.0500;
cst{ixPTV,5}.Priority    = 1;
cst{ixPTV,5}.Visible     = 1;
cst{ixPTV,5}.visibleColor = [0 1 1];

% define objective as struct for compatibility with GNU Octave I/O
cst{ixPTV,6}{1} = struct(DoseObjectives.matRad_SquaredDeviation(800,60));

%% Lets create either a cubic or a spheric phantom

TYPE = 'cubic';   % either 'cubic' or 'spheric'

% first the OAR
cubeHelper = zeros(ct.cubeDim);

switch TYPE
   
   case {'cubic'}
        xLowOAR  = 1;
        xHighOAR = 100;
        yLowOAR  = 1;
        yHighOAR = 400;
        zLowOAR  = 1;
        zHighOAR = 100;

      for x = xLowOAR:1:xHighOAR
         for y = yLowOAR:1:yHighOAR
            for z = zLowOAR:1:zHighOAR
               cubeHelper(y,x,z) = 1;
            end
         end
      end
      
   case {'spheric'}
      
      radiusOAR = xDim/4;
      
      for x = 1:xDim
         for y = 1:yDim
            for z = 1:zDim
               currPost = [y x z] - round([ct.cubeDim./2]);
               if  sqrt(sum(currPost.^2)) < radiusOAR
                  cubeHelper(y,x,z) = 1;
               end
            end
         end
      end
      
end

cst{ixOAR,4}{1} = find(cubeHelper);

% second the PTV
cubeHelper = zeros(ct.cubeDim); 
% TYPE = 'spheric';
switch TYPE
   
   case {'cubic'}
      xLowPTV  = 40;
      xHighPTV = 60;
      yLowPTV  = 290;
      yHighPTV = 310;
      zLowPTV  = 40;
      zHighPTV = 60;
      
      cubeHelper = zeros(ct.cubeDim);
      
      for x = xLowPTV:1:xHighPTV
         for y = yLowPTV:1:yHighPTV
            for z = zLowPTV:1:zHighPTV
               cubeHelper(y,x,z) = 1;
            end
         end
      end
      
   case {'spheric'}
      
      radiusPTV = 15;
      
      for x = 1:xDim
         for y = 1:yDim
            for z = 1:zDim
               currPost = [x y z] - [100 100 100]; % [x y z] - round([ct.cubeDim./2]);
               if  sqrt(sum(currPost.^2)) < radiusPTV
                  cubeHelper(y,x,z) = 1;
               end
            end
         end
      end
end

cst{ixPTV,4}{1} = find(cubeHelper);

vIxOAR = cst{ixOAR,4}{1};
vIxPTV = cst{ixPTV,4}{1};

ct.cubeHU{1}(vIxOAR) = 0;
ct.cubeHU{1}(vIxPTV) = 0;
