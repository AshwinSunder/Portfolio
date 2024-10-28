%% Initialize
clearvars;

TimeDomain  = 1;
saveObj     = 1;

myName = "sdbox_tractor_081k_Rot_MyEx_2";

%% Global Parameter
vel     = 50:5:140;
%vel     = 90;
sos     = 10000;    % speed of sound
density = 1.225;

%% Propeller Model
rpm     = 2500;
J       = 1.42;
kT      = 081000; % only Dummy
kP      = 081000; % only Dummy

radius  = 0.9;
cRef    = 0.22;

lgt     = -0.2;
cgR     = -0.4;
cgM     = -0.3;
constJ  = 0;
nBlades = 4;
mR      = 8.8;
mM      = 25;

% Propeller V2
dR    = 2*radius;
rpmC  = rpm;
mB    = mR/nBlades;
cgHub = cgR;

para.lgt          = lgt;
para.eta          = (0.01:0.01:1)';
para.numberBlades = nBlades;
para.massMotor    = mM;
para.cgMotor      = cgM;
para.name         = "PropMod8_V2";

pm = asi_propModel_v2(dR,cRef,rpmC,J,mB,cgHub,kT,kP,para);

pm.analysis.vel     = vel;
pm.analysis.der     = [];
pm.analysis.density = density;
pm.analysis.constJ  = constJ;
pm.CalcStructure();
pm.CalcPropAero(sos);
pm.CalcWhirlFlutter;

%% Time Domain Simulation
if(TimeDomain)
    propSD         = pm.getSDBsys();
    propSD.damping = propSD.damping + pm.structure.gyroRPM;

    dt                        = 0.001;
    propSD.setup.t_start      = 0;
    propSD.setup.t_duration   = 2;
    propSD.setup.samplingFreq = 1/dt;

    % define excitation force - as in MBDyn
    tForce = 0.01;
    freq   = 50;
    OmegaF = freq*2*pi;
    amp    = 5000;
    f      = propSD.CreateHarmonic('Amp',amp,'freq',OmegaF);
    fLoads = f.loadsVector;
    fLoads = amp-fLoads;
    dt     = 1/propSD.setup.samplingFreq;
    T      = 1/freq;
    fLoads(T/dt+1:end) = 0;
    fLoads = [zeros(1,tForce/dt-1),fLoads];

    propSD.rhs      = zeros(propSD.ndof,size(fLoads,2));
    propSD.rhs(1,:) = fLoads*0.4*1;

    % initial conditions
    propSD.initCond.displacement = zeros(propSD.ndof,1);
    propSD.initCond.velocity     = zeros(propSD.ndof,1);

    propSD.CalcTDResponse(2);
end

%% Save Object
if(saveObj)
    propSD.SaveSystem('Name',myName);
end