%{
Purdue Space Program - Liquids
Rocket 3 ECP1 - Pintle Sizing
-----------------------------
Contributors: Liam Schenk, Jan Ayala
Last Modified: 23 Jan., 2022
Description: Script for Rocket 3 pintle injector sizing and optimization.
Version: v1.3.2
%}
clear;
clc;
lcv = 1; % Loop control variable

% Allocate space (grrrr):
injData = zeros(100,9);
adtData = zeros(100,4);
optData = zeros(2,13);

% Generic properties:
skipDist = 1; % [N/A]
disCoef = 0.8; % [N/A]
mdot = 15.5; % [lbm/s]; total mass flow rate
ofRatio = 2.65; % [N/A]
chambP = 250; % [psi]
halfAgl_LMR = 65; % [deg]; https://arc-aiaa-org.ezproxy.lib.purdue.edu/doi/pdf/10.2514/6.2019-0152
halfAgl_TMR = 45; % [deg]
numHoles = 20; % [N/A]; INITIAL VALUE TO ITERATE FROM

% Constants/other data:
grav = 32.2; % [ft/s^2]
bitSizes = [0.0512;0.052;0.055;0.0551;0.0591;0.0595;0.0625;0.063;0.0635;0.0669;0.07;0.0709;0.073;0.0748;0.076;0.0781;0.0785;0.0787;0.0810;0.0820;0.0827;0.0860;0.0866;0.0890;0.0906;0.0935;0.0938;0.0945;0.096;0.098;0.0984;0.0995;0.1015;0.1024;0.104]; % [in]

% Propellant properties:
dnstLOX = 0.04364; % [lbm/in^3]
dnstRP1 = 0.0289; % [lbm/in^3]
mdotRP1 = mdot/(ofRatio+1); % [lbm/s]
mdotLOX = mdotRP1*ofRatio; % [lbm/s]

% Simple geometries:
deltaP = 0.25*chambP; % [psi]
chambDiam = 9.5; % [in]
shaftDiam = chambDiam/5; % [in]
shaftRad = shaftDiam/24; % [ft]
shaftLength = skipDist*shaftDiam; % [in]

% Convert units:
dnstLOX = dnstLOX*1728; % now [lbm/ft^3]
dnstRP1 = dnstRP1*1728; % now [lbm/ft^3]
deltaP = deltaP*144; % now [lbf/ft^2]

% Formatting (see line 88):
givenData = [skipDist,mdot,ofRatio,chambP,deltaP,disCoef,dnstLOX,dnstRP1,mdotLOX,mdotRP1];
msmtData = [chambDiam,shaftDiam,shaftRad,shaftLength];

while numHoles <= 121
    % Math! (Oxidizer @ center)
    areaLOX = mdotLOX/(sqrt(2*deltaP*dnstLOX*grav)*disCoef); % [ft^2]
    areaLOX = areaLOX*144; % [in^2]
    diamLOX = 2*sqrt(areaLOX/(pi*numHoles)); % [in]

    % Define real size (by machining capabilities):
    tempMatrix1 = repmat(diamLOX,[1 length(bitSizes)]);
    [~,indexMin] = min(abs(tempMatrix1-bitSizes'));
    diamLOX_real = bitSizes(indexMin); % [in]
    areaLOX_real = pi*numHoles*(diamLOX_real/2)^2; % [in]

    % Update units:
    diamLOX_real = diamLOX_real/12; % now [ft]
    areaLOX_real = areaLOX_real/144; % now [ft^2]

    % Math! (Fuel around outer):
    annThk = (pi*dnstLOX*diamLOX_real)/(4*dnstRP1*(ofRatio^2)); % [ft]
    areaRP1 = (pi*(shaftRad+annThk)^2)-(pi*(shaftRad)^2); % [ft^2]

    % Injector velocities:
    velRP1 = mdotRP1/(areaRP1*dnstRP1); % [ft/s]
    velLOX = mdotLOX/(areaLOX_real*dnstLOX); % [ft/s]
    TMR = (mdotLOX*velLOX)/(mdotRP1*velRP1); % [N/A]

    % Additional calculations:
    momentRat = (dnstRP1*(velRP1^2)*annThk*diamLOX_real*4)/(dnstLOX*(velLOX^2)*pi*diamLOX_real^2);
    ofRatio_real = velRP1/velLOX;
    blkgFac = (numHoles*diamLOX_real*6)/(pi*shaftDiam);

    % Update and loop:
    injData(lcv,1:9) = [numHoles,diamLOX,areaLOX,diamLOX_real,areaLOX_real,annThk,areaRP1,velRP1,velLOX];
    adtData(lcv,1:4) = [TMR,momentRat,ofRatio_real,blkgFac];
    lcv = lcv + 1;
    numHoles = numHoles + 1;
end

% Find optimal results:
actOFData = adtData(1:end,3);
tempMatrix2 = repmat(ofRatio,[1 length(actOFData)]);
[~,indexMin] = min(abs(tempMatrix2-adtData(1:end,3)));
indexMin = floor(mean(indexMin));
optData(1,1:end) = [injData(indexMin,1:end),adtData(indexMin,1:end)];

momRatData = adtData(1:end,2);
tempMatrix3 = ones(1,length(momRatData));
[~,indexMin] = min(abs(tempMatrix3-adtData(1:end,2)));
indexMin = floor(mean(indexMin));
optData(2,1:end) = [injData(indexMin,1:end),adtData(indexMin,1:end)];

% Output optimal data for throttling code:
throttleData(1,1:9) = [disCoef,ofRatio,mdot,chambP,deltaP,dnstLOX,dnstRP1,mdotLOX,mdotRP1];
throttleData(1,10:11) = optData(1,8:9);
throttleData(1,12) = optData(1,5);
throttleData(1,13) = optData(1,7);

% Generate tables:
table1 = array2table(givenData,'VariableNames',{'Skip Distance','Total MDot [lbm/s]','O/F','Chamber Pressure [psi]','Pressure Drop [lbf/ft^2]','Cd','LOX Density [lbm/ft^3]','RP1 Density [lbm/ft^3]','LOX MDot [lbm/s]','RP1 MDot [lbm/s]'});
table2 = array2table(injData,'VariableNames',{'Number of Holes','LOX Diam [in]','LOX Area [in^2]','Real LOX Diam [ft]','Real LOX Area [ft^2]','Annular Thickness [ft]','RP1 Area [ft^2]','RP1 Vel [ft/s]','LOX Vel [ft/s]'});
table3 = array2table(adtData,'VariableNames',{'TMR','Moment Ratio','Actual OF Ratio','Blockage Factor'});
table4 = array2table(msmtData,'VariableNames',{'Chamber Diam [in]','Shaft Diam [in]','Shaft Rad [ft]','Shaft Length [in]'});
table5 = array2table(optData,'VariableNames',{'Number of Holes','LOX Diam [in]','LOX Area [in^2]','Real LOX Diam [ft]','Real LOX Area [ft^2]','Annular Thickness [ft]','RP1 Area [ft^2]','RP1 Vel [ft/s]','LOX Vel [ft/s]','TMR','Moment Ratio','Actual OF Ratio','Blockage Factor'});

% Distribute results:
mainPath = cd;
dirExist = exist("ECP1.Output","dir");
while dirExist ~= 7
    mkdir ECP1.Output
    dirExist = exist("ECP1.Output","dir");
end
cd ..\ECP\ECP1.Output
outputPath = cd;

% Write tables to excel sheet 1:
filename = ['Output.',datestr(now,'yyyymmddTHHMMSS'),'.xlsx'];
writetable(table1,filename,'Sheet',1,'Range','B2')
writetable(table2,filename,'Sheet',1,'Range','B8')
writetable(table3,filename,'Sheet',1,'Range','L8')
writetable(table4,filename,'Sheet',1,'Range','B5')
writematrix('Optimal Results:',filename,'Sheet',1,'Range','B112')
writematrix('By O/F',filename,'Sheet',1,'Range','B114')
writematrix('By Moment Ratio',filename,'Sheet',1,'Range','B115')
writetable(table5,filename,'Sheet',1,'Range','C113')

cd(mainPath)

% Create readables for throttling function:
filename = 'inputs.throttling.xlsx';
writematrix(throttleData,filename)
