
%% Goland wing setup

nE       = 8;
halfspan = 6.096;
chord    = 1.829;
ea_z     = 0.33*2;         % from LE in %b

paraW.EA    = 1.0E+10;
paraW.GAy   = 1.0E+10; 
paraW.GAz   = 1.0E+10;
paraW.GJ    = 9.88E+05;
paraW.EIy   = 9.77E+07;  
paraW.EIz   = 9.77E+06;

paraW.mW0  = 217.74912/6.096;
paraW.roGx = 0.5;
paraW.cg_z = 0.20;

paraW.clamped        = 1;
paraW.plotProperties = 0;
paraW.RT = [0 0 1;1 0 0;0 1 0]; % Rotation matrix [dust -> paraW]

%% sdbox object

[str,geoW] = sdm_BeamModel6D(nE,halfspan,chord,ea_z,paraW);
str.damping = zeros(size(str.mass));

M = str.mass;
K = str.stiffness;
C = str.damping;

sd = sdb_system;
sd.mass = M;
sd.stiffness = K;
sd.damping = C;
sd.CalcEigenproblem;
sd.geo = geoW;

%% goland wing struct

golandWing.M = [zeros(54,6) [zeros(6,48);M]];
golandWing.K = [zeros(54,6) [zeros(6,48);C]];
golandWing.C = [zeros(54,6) [zeros(6,48);K]];
golandWing.constraint_matrix = geoW.constraintMatrix(1:54,:);
golandWing.eigenvalue = sd.eigenvalue;
golandWing.eigenvector = [zeros(6,96);sd.eigenvector];
