%{
Purdue Space Program - Liquids
Rocket 3 ECP2 - Throttling
--------------------------
Contributors: Liam Schenk
Last Modified: 22 Jan., 2022
Description: Script for Rocket 3 bang bang throttling models and viability testing.
Version: v1.1.2
%}
clear;
clc;
lcv = 1; % Loop control variable!

% Allocate space:
outData = zeros(60,4);

% Gather input data:
inputData = readmatrix('inputs.throttling.xlsx');
% Data stored in order: [disCoef,ofRatio,mdot,chambP,deltaP,dnstLOX,dnstRP1,mdotLOX,mdotRP1,velRP1,velLOX,areaLOX,areaRP1]

% Assign input data:
disCoef = inputData(1,1); % [N/A]
mdot = inputData(1,3); % [lbm/s]; total mass flow rate
ofRatio = inputData(1,2); % [N/A]
chambP = inputData(1,4); % [psi]
throttle = 0.85; % [N/A]; INITIAL VALUE ONLY
deltaP = inputData(1,5); % [lbf/ft^2]

% Propellant properties:
dnstLOX = inputData(1,6); % [lbm/ft^3]
dnstRP1 = inputData(1,7); % [lbm/ft^3]
mdotRP1 = inputData(1,9); % [lbm/s]
mdotLOX = inputData(1,8); % [lbm/s]
velRP1 = inputData(1,10); % [ft/s]
velLOX = inputData(1,11); % [ft/s]
areaRP1 = inputData(1,13); % [ft^2]
areaLOX = inputData(1,12); % [ft^2]

% Meat:




% Generate tables:
table1 = array2table(outData,'VariableNames',{});

% Distribute results:
mainPath = cd;
dirExist = exist("ECP2.Output","dir");
while dirExist ~= 7
    mkdir ECP2.Output
    dirExist = exist("ECP2.Output","dir");
end
cd ..\ECP\ECP2.Output
outputPath = cd;

% Write data:
filename = ['Output.',datestr(now,'yyyymmddTHHMMSS'),'.xlsx'];
writetable(table1,filename,'Sheet',1,'Range','B2')

cd(mainPath)
