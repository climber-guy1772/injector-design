ITval = 50;   % Initial temperature of the model
RTval = 40;   % Burntime of the model
TCval = 40;   % Thermal conductivity of the model
MDval = 10;   % Mass density value of the model
SHval = 10;   % Specific heat of the model

% set up output file header (for fun)
header = "PSP Liquids - Injector Design Team"+newline+string(datetime('now'));

values = [ITval,RTval,TCval,MDval,SHval];
% qexch (heat exchange) takes an array of inputs in the form:
% {initT,runtime,TCval,MDval,SHval}
qexch(values,header)