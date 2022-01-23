%{
Purdue Space Program - Liquids
Rocket 3 ECP1 - Pintle Sizing
-----------------------------
Contributors: Liam Schenk
Last Modified: 22 Jan., 2022
Description: Script for Rocket 3 pintle injector sizing and optimization.
%}
clear;
clc;

% Generic properties:
skipDist = 1; % [N/A]
disCoef = 0.8; % [N/A]
mdot = 15.5; % [lbm/s]; total mass flow rate
ofRatio = 2.65; % [N/A]
chambP = 250; % [psi]
halfAgl_LMR = 65; % [deg]; https://arc-aiaa-org.ezproxy.lib.purdue.edu/doi/pdf/10.2514/6.2019-0152
halfAgl_TMR = 45; % [deg]
numHoles = 60; % [N/A]
grav = 32.2; % [ft/s^2]

% Propellant properties:
dnstLOX = 1.141; % [g/mL]
dnstRP1 = 1.02; % [g/mL]; highest density from range 0.81-1.02
mdotRP1 = mdot/(ofRatio+1); % [lbm/s]
mdotLOX = mdotRP1*ofRatio; % [lbm/s]

% Simple geometries:
deltaP = 0.25*chambP; % [psi]
chambDiam = 9.5; % [in]
shaftDiam = chambDiam/5; % [in]
shaftRad = shaftDiam/24; % [ft]

% Convert units:
dnstLOX = dnstLOX*62.428; % now [lbm/ft^3]
dnstRP1 = dnstRP1*62.428; % now [lbm/ft^3]
deltaP = deltaP*144; % now [lbf/ft^2]

% Math! (Oxidizer @ center)
areaLOX = mdotLOX/(sqrt(2*deltaP*dnstLOX*grav)*disCoef); % [ft^2]
areaLOX = areaLOX*144; % [in^2]
diamLOX = 2*sqrt(areaLOX/(pi*numHoles)); % [in]

% Define real size (by machining capabilities):
bitSizes = [0.0785;0.0787;0.0810;0.0820;0.0827;0.0860;0.0866]; % [in]
tempMatrix = repmat(diamLOX,[1 length(bitSizes)]);
[minVal,indexMin] = min(abs(tempMatrix-bitSizes'));
diamLOX_real = bitSizes(indexMin); % [in]
areaLOX_real = pi*numHoles*(diamLOX_real/2)^2; % [in]

% Update units:
diamLOX_real = diamLOX_real/12; % now [ft]
areaLOX_real = areaLOX_real/144; % now [ft]

% Math! (Fuel around outer):
annThk = (pi*dnstLOX*diamLOX_real)/(4*dnstRP1*(ofRatio^2)); % [ft]
areaRP1 = (pi*(shaftRad+annThk)^2)-(pi*(shaftRad)^2); % [ft^2]

% Injector velocities:
velRP1 = mdotRP1/(areaRP1*dnstRP1); % [ft/s]
velLOX = mdotLOX/(areaLOX_real*dnstLOX); % [ft/s]
TMR = (mdotLOX*velLOX)/(mdotRP1*velRP1); % [N/A]

%{
To do:
- Calculate moment ratio
- Calculate actual O/F ratio
- Iterate to optimize sizes
- Get impingement points
- Try at different Cds
- Finish output file
%}

% Distribute results:
mainPath = cd;
dirExist = exist("ECP1.Output","dir");
while dirExist ~= 7
    mkdir ECP1.Output
    dirExist = exist("ECP1.Output","dir");
end
cd ..\ECP\ECP1.Output
outputPath = cd;
cd(mainPath)
