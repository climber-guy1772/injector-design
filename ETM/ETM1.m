function qexch(data)

% qexch (heat exchange) takes an array of inputs in the form:
% {ITval,RTval,TCval,MDval,SHval}
% Where:                                          Units:
%   ITval:    inital temperature                    [degF]
%   RTval:    runtime (burntime for us) of system   [s]     (duh)
%   TCval:    thermal conductivity of material      [BTU/(h*ft*degF)]
%   MDval:    mass density of material              [slugs/ft^3]
%   SHval:    specific heat of material             [BTU/(lb*degF)]
% qexch outputs information relevant for modeling film cooling on the
% injection plate of PSP's Rocket 3.

% NOTE REGARDING UNITS: if input data is given in one system (e.g.
% imperial) output data will also be in that system.

%---Parse data array for physical information---%
ITval = data(1);
RTval = data(2);
TCval = data(3);
MDval = data(4);
SHval = data(5);

%---Obtain geometry for model---%
sface = -1;
fileID = -1;
errmsg = '';
while fileID < 0 
   disp(errmsg);
   filename = input('Open file: ', 's');
   [fileID,errmsg] = fopen(filename);
end

% Set model as:      [STEADY] or [TRANSIENT]
% Which uses params:    ITval          ITval
%                       RTval          RTval
%                                      MDval
%                                      TCval
%                                      SHval         

clf
model = createpde('thermal','transient');
geo = importGeometry(filename);
model.Geometry = geo;
numF = geo.NumFaces;
numC = geo.NumCells;
pdegplot(model,'FaceLabels','on')
title('Model Geometry')
print(['injecGeo-',date],'-dpng')

%---Define initial conditions for model---%
generateMesh(model);
% pdemesh(model)    -   Optional; displays mesh on plot (takes forever)
initCon = thermalIC(model,ITval); %#ok<*NASGU> 
size = RTval / 100;
tlist = 0:size:RTval;

tP = thermalProperties(model,'ThermalConductivity',TCval,'MassDensity',MDval,'SpecificHeat',SHval);

numT = input('No. of faces w/ distinctive properties: ');
arr = 0:1:(numT-1);
qn = 0:1:(numT-1);
lcv = 1;

%---Assign desired faces thermal properties---%
while numT > 0
    while sface < 0
        disp(errmsg);
        sface = input([newline,'Face no.: ']);
    end
    %---Chose one of the boundary condition options & define properties---%
    disp('Boundary condition options:'); disp('    1. Temperature BC'); disp('    2. Heat Flux BC'); disp('    3. Convection BC')
    bcselect = input('Enter boundary condition type: ');
    if bcselect == 1
        tmeas = input('Measured temp: ');
        thermalBC(model,'Face',sface,'Temperature',tmeas);
        arr(lcv) = sface;
        lcv = lcv + 1;
        sface = -1;
    elseif bcselect == 2
        hfmeas = input('Heat flux: ');
        thermalBC(model,'Face',sface,'HeatFlux',hfmeas);
        arr(lcv) = sface;
        lcv = lcv + 1;
        sface = -1;
    elseif bcselect == 3
        convc = input('Convection coefficient: ');
        tamb = input('Ambient temp: ');
        thermalBC(model,'Face',sface,'ConvectionCoefficient',convc,'AmbientTemperature',tamb);
        arr(lcv) = sface;
        lcv = lcv + 1;
        sface = -1;
    end
    numT = numT - 1;
end

%---Solve model; execution times taken to test efficiency---%
time1 = datetime('now');
disp([newline,'Solving...',newline])
%---Assign solved model to time solution array; allows graphing---%
result = solve(model,tlist);
sol = result.Temperature;
time2 = datetime('now');

i = 1;
timeSize = RTval / 4;
while i <= 4
    subplot(2,2,i)
    interval = i * timeSize;
    if mod(interval,1) ~= 0
        interval = interval - 0.5;
    end
    pdeplot3D(model,'ColorMapData',sol(:,interval))
    title(['Time ',num2str(interval)])
    i = i + 1;
end
print(['thermGeo-',date],'-dpng')
clf

% set up output file header (for fun)
header = "PSP Liquids - Injector Design Team"+newline+string(datetime('now'));

%---Begin output file qtOut.txt---%
delete("qtOut.txt")
diary("qtOut.txt")
diary on
disp(header)
disp('Heat Exchange Model Outputs:')
disp('Elapsed runtime: ')
disp(time2-time1)
disp(['Geometry for "' filename '":'])
str = string(evalc('feature(''hotlinks'',''off'');disp(model)'));
disp(str)
str = string(evalc('feature(''hotlinks'',''off'');disp(geo)'));
disp(str)
disp('Initial Conditions:')
str = string(evalc('feature(''hotlinks'',''off'');disp(initCon)'));
disp(str)
disp('Physical Properties:')
str = string(evalc('feature(''hotlinks'',''off'');disp(tP)'));
disp(str)

%---Convert entered boundary conditions to text output---%
disp('Boundary Conditions:')
while lcv > 1
    lcv = lcv - 1;
    sface = arr(lcv);
    tbc = findThermalBC(model.BoundaryConditions,'Face',sface);
    str = string(evalc('feature(''hotlinks'',''off'');disp(tbc)'));
    disp(str)
end

%---Produce relevant charts and data---%
hold on
disp('Heat Flow Rate for Burn Duration:')
disp(['On time interval 0:',num2str(RTval),' incremented by ',num2str(size)])
while lcv <= numF
    qn = evaluateHeatRate(result,'Face',lcv);
    table1 = table(tlist.',qn,'VariableNames',{'Time','Heat Flow Rate'});
    table1 = table(table1,'VariableNames',{['Qn for Face ',num2str(lcv)]});
    str = string(evalc('feature(''hotlinks'',''off'');disp(table1)'));
    disp(str)
    plot(tlist,qn)
    if lcv == numF
        Legend = cell(numF,1);
        for iter=1:numF
            Legend{iter}=strcat('Face ',num2str(iter));
        end
        legend(string(Legend))
    end
    lcv = lcv + 1;
end
hold off
title('Heat Flow Rate for Burn Duration')
xlabel('Time')
ylabel('Heat Flow Rate')
print(['qFlow-',date],'-dpng')
diary off

%---Determine ideal injector face material---%
% We can optimize the performance of our injector face by discerning the
% ideal face material below (taken from NASA SP 8089)

% Heat Flux:        Material:
% 2 Btu/(in^2s)     [Stainless Steel]   - Rec ft < 1600 degF
% >10 Btu/(in^2s)   [Copper]            - Rec ft < 1000 degF 
% 2-10 Btu/(in^2s)  [Nickel]            - Rec ft ~ 1300 degF
% 2-8 Btu/(in^2s)   [Aluminium Alloys]  - Require ft < 400 degF

%---Output machining suggestions---%
diary("qtOut.txt")
diary on
disp('Design Characteristics:')
disp(['Units:',newline,'    Heat flux operation range:  Btu/(in^2s)',newline,'    Recommended face temp:      degF'])
Material = {'Stainless Steel';'Copper';'Nickel';'Aluminium Alloys'};
HeatFlux = {'2';'>10';'2-10';'2-8'};
FaceTemp = {'<1600';'<1000';'~1300';'<400'};
table2 = table(Material,HeatFlux,FaceTemp,'VariableNames',{'Material','Operable Heat Flux','Recommended Face Temp'});
str = string(evalc('feature(''hotlinks'',''off'');disp(table2)'));
disp(str)

%---Output maximum heat flux per face---%
MaxHeatFlux = 1:numF;
Face = 1:numF;
lcv = 1;
while lcv <= numF
    qn = evaluateHeatRate(result,'Face',lcv);
    MaxHeatFlux(lcv) = max(qn);
    lcv = lcv + 1;
end
table3 = table(Face.',MaxHeatFlux.','VariableNames',{'Face No.','Max Heat Flux'});
str = string(evalc('feature(''hotlinks'',''off'');disp(table3)'));
disp(str)

diary off
clc
disp(['Output directed towards qtOut.txt!',newline,'Figures:'])
disp(['  injecGeo-',date,'.png',newline,'  thermGeo-',date,'.png',newline,'  qFlow-',date,'.png'])

end
