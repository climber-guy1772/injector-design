function qexch()
% qexch (heat exchange) takes an array of inputs in the form:
% {initT,runtime,TCval,MDval,SHval}
%   initT:    inital temperature
%   runtime:  runtime (burntime for us) of system
%   TCval:    thermal conductivity of material
%   MDval:    mass density of material
%   SHval:    specific heat of material

sface = -1;
fileID = -1;
errmsg = '';
while fileID < 0 
   disp(errmsg);
   filename = input('Open file: ', 's');
   [fileID,errmsg] = fopen(filename);
end

% Set parameter to transient or steady state
% For any heat transfer problems involving mass density and thermal
% conductivity, use a transient state model

clf
model = createpde('thermal','transient');
geo = importGeometry(filename);
model.Geometry = geo;
numF = geo.NumFaces;
numC = geo.NumCells;
pdegplot(model,'FaceLabels','on')
title('Model Geometry')
print(['injecGeo-',date],'-dpng')

% Define initial conditions for model
generateMesh(model);
% pdemesh(model)    -   Optional; displays mesh on plot
initCon = thermalIC(model,initT); %#ok<*NASGU> 
size = runtime / 100;
tlist = 0:size:runtime;

tP = thermalProperties(model,'ThermalConductivity',TCval,'MassDensity',MDval,'SpecificHeat',SHval);

numT = input('No. of faces w/ distinctive properties: ');
arr = 0:1:(numT-1);
qn = 0:1:(numT-1);
counter = 1;

% Assign specific faces thermal properties
while numT > 0
    while sface < 0
        disp(errmsg);
        sface = input('Face no.: ');
    end
    disp('Boundary condition options:'); disp('1. Temperature BC'); disp('2. Heat Flux BC'); disp('3. Convection BC')
    bcselect = input('Enter boundary condition type: ');
    if bcselect == 1
        tmeas = input('Measured temp: ');
        thermalBC(model,'Face',sface,'Temperature',tmeas);
        arr(counter) = sface;
        counter = counter + 1;
        sface = -1;
    elseif bcselect == 2
        hfmeas = input('Heat flux: ');
        thermalBC(model,'Face',sface,'HeatFlux',hfmeas);
        arr(counter) = sface;
        counter = counter + 1;
        sface = -1;
    elseif bcselect == 3
        convc = input('Convection coefficient: ');
        tamb = input('Ambient temp: ');
        thermalBC(model,'Face',sface,'ConvectionCoefficient',convc,'AmbientTemperature',tamb);
        arr(counter) = sface;
        counter = counter + 1;
        sface = -1;
    end
    numT = numT - 1;
end

% Solve model; execution times taken to test efficiency
time1 = datetime('now');
% Assign solved model to time solution array; allows graphing
result = solve(model,tlist);
sol = result.Temperature;
time2 = datetime('now');

i = 1;
timeSize = runtime / 4;
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

delete("qtOut.txt")
diary("qtOut.txt")
diary on
disp('Heat Exchange Model Outputs')
disp(datetime('now'))
disp('Runtime: ')
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

% Convert entered boundary conditions to text output
disp('Boundary Conditions:')
while counter > 1
    counter = counter - 1;
    sface = arr(counter);
    tbc = findThermalBC(model.BoundaryConditions,'Face',sface);
    str = string(evalc('feature(''hotlinks'',''off'');disp(tbc)'));
    disp(str)
end

% Produce relevant charts and data
hold on
while counter <= numF
    qn = evaluateHeatRate(result,'Face',counter);
    disp(['Qn for F',num2str(counter),' on 0:',num2str(size),':',num2str(runtime)])
    table1 = table(tlist.',qn,'VariableNames',{'Time','Heat Flow Rate'});
    str = string(evalc('feature(''hotlinks'',''off'');disp(table1)'));
    disp(str)
    plot(tlist,qn)
    if counter == numF
        Legend = cell(numF,1);
        for iter=1:numF
            Legend{iter}=strcat('Face ',num2str(iter));
        end
        legend(string(Legend))
    end
    counter = counter + 1;
end
hold off
title('Heat Flow Rate for Burn Duration')
xlabel('Time')
ylabel('Heat Flow Rate')
print(['qFlow-',date],'-dpng')
diary off

end
