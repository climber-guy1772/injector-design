function qexch(values,header)

% qexch (heat exchange) takes an array of inputs in the form:
% {ITval,RTval,TCval,MDval,SHval}
% Where:
%   ITval:    inital temperature
%   RTval:    runtime (burntime for us) of system
%   TCval:    thermal conductivity of material
%   MDval:    mass density of material
%   SHval:    specific heat of material

%---Parse "values" for physical information---%
ITval = values(1);
RTval = values(2);
TCval = values(3);
MDval = values(4);
SHval = values(5);

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
% Which use params:     ITval          ITval
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
% pdemesh(model)    -   Optional; displays mesh on plot
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
        sface = input('Face no.: ');
    end
    %---Chose one of the boundary condition options & define properties---%
    disp('Boundary condition options:'); disp('1. Temperature BC'); disp('2. Heat Flux BC'); disp('3. Convection BC')
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

%---Begin output file qtOut.txt---%
delete("qtOut.txt")
diary("qtOut.txt")
diary on
disp(header)
disp('Heat Exchange Model Outputs')
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
while lcv <= numF
    qn = evaluateHeatRate(result,'Face',lcv);
    disp(['Qn for F',num2str(lcv),' on 0:',num2str(size),':',num2str(RTval)])
    table1 = table(tlist.',qn,'VariableNames',{'Time','Heat Flow Rate'});
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

end
