% function Param = ParamDef_Oceanide(GeomDisks,RIGID)
%
% LB July 2013: written for experiments

function Param = ParamDef_Oceanide(RIGID,Np)

% Floes are rigid:
if ~exist('RIGID','var'); RIGID=10; end

% Number of disks
if ~exist('Np','var')
 Param.Np = 1;
else
 Param.Np = Np;
end

% thickness
Param.thickness = 33e-3; %33e-3;
% Param.thickness = 0.5;

% Accelaration due to gravity (in m\,s^{-2})
Param.g = 9.81*ones(Param.Np,1);   
% Param.g = 1*ones(Param.Np,1);    

% Density of fluid (in kg\,m^{-3})
% Param.rho_0 = %1000*ones(Param.Np,1);   
Param.rho_0 = 1000*ones(Param.Np,1);      

%%%%% Choose to give draught 1.8/100 %%%%%

% Densities of disks (in kg\,m^{-3})
Param.rho = 1.8*Param.rho_0/3.3; %500*ones(Param.Np,1);
% Param.rho = Param.rho_0;
% Param.rho = 20*Param.rho_0;

% Poisson's ratios
Param.nu = 0.3*ones(Param.Np,1);
% Param.nu = sqrt(11/12)*ones(Param.Np,1);

% Young modulii (in MPa)
if ~RIGID
 Param.E = 10e10*ones(Param.Np,1);
else
 Param.E = RIGID*(10^9)*ones(Param.Np,1);
end
% Param.E = 1;
% Param.E = 4*10^3;
    
% Draughts (in m)
Param.draft = Param.thickness.*Param.rho./Param.rho_0; 

% Flexural rigidities (in MPa\,m^3)
Param.D = Param.E.*Param.thickness.^3./(12*(1-Param.nu.^2));

% Scaled rigidity 
Param.beta = Param.D./(Param.g.*Param.rho_0);

% fluid depth (open/equilibrium)

%  Param.bed = 1;
Param.bed = 3.1;
% Param.bed = 10;

% MIZ length [m]

Param.MIZ_length = 5;

% diameter of floes [m]

Param.floe_diam = 0.99;
% Param.floe_diam = 1;

return