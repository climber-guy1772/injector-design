% This program is only half complete: fluids modeling is needed to obtain
% convection/heat transfer from combustion. Data passed to qexch will
% change.

% qexch (heat exchange) takes an array of inputs in the form:
% {ITval,RTval,TCval,MDval,SHval}
% Where:                                          Units:
%   ITval:    inital temperature                    [degF]
%   RTval:    runtime (burntime for us) of system   [s]     (duh)
%   TCval:    thermal conductivity of material      [BTU/(h*ft*degF)]
%   MDval:    mass density of material              [slugs/ft^3]
%   SHval:    specific heat of material             [BTU/(lb*degF)]
ITval = 50;
RTval = 20;             % Approximate burn duration: 20                 s
TCval = 8.672639736;    % Thermal conductivity of stainless steel: ~15  W/(mK)
MDval = 14.552402;      % Mass density of stainless steel: ~7,500       kg/m3
SHval = 0.112;          % Specific heat of stainless steel: 0.112       BTU/(lb*degF)

data = [ITval,RTval,TCval,MDval,SHval];
% qexch (heat exchange) takes an array of inputs in the form:
% {initT,runtime,TCval,MDval,SHval}
qexch(data)
