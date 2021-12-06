% Program: Basic injector geometry calculations
% Outputs: Can calculate the spray cone half angle and breakup length for
%          both close and open-type coaxial swirl injectors. This file will
%          output graphical representations of spray patterns.

% Inner injector inputs
deltaP1 = input('Enter change in pressure [Pa] for propellant: ');
numInlet1 = input('Enter number of inlet holes for propellant: ');
rho1 = input('Enter density of fluid [kg/m^3] for propellant: ');

% Outer injector inputs
deltaP2 = input('Enter change in pressure [Pa] for oxidizer: ');
numInlet2 = input('Enter number of inlet holes for oxidizer: ');
rho2 = input('Enter density of fluid [kg/m^3] for oxidizer: ');

% Given geometry:
%       Inner Injector:
%       Closed type coaxial swirl
% Ryan/Jacob math here

%       Outer Injector:
%       Open type coaxial swirl
rInlet2 = 0.001;     % Radius of inlet holes (m)
rV2 = 0.005;         % Radius of vortex chamber (m)
rN2 = rV2;            % Radius of vortex chamber at base (m)
rIn2 = rV2-rInlet2;    % Swirl arm (m)
viscosity2 = 10^-6;  % Kinematic viscosity of water (m^2/s)
%nozCo = rIn/rN;      Coefficient of nozzle opening; <1 for open end injectors

disp('Open-type injector geometries:')
% Calculate the spray cone half angle for an open-type injector:
A2 = (rIn2*rV2)/(numInlet2*rInlet2^2);                   % Geometric characteristic constant
disCo2 = 0.432/(A2^0.64);                                % Discharge coefficient of injector
mDot2 = disCo2*pi*rN2^2*(2*rho2*deltaP2)^0.5;            % Mass flow rate
Q2 = mDot2/rho2;                                         % Volume flow rate (m^3/s)
Re2 = (2*Q2)/(pi*sqrt(numInlet2)*rInlet2*viscosity2);    % Reynolds number
theta2 = atand(0.033*(A2^0.338)*(Re2^0.249));            % Spray cone half angle (deg)
lengthB2 = 2*3935*rN2*(A2^-0.621)*(Re2^-0.465);          % Breakup length (m)

% Plot and output spray geometries for open-type injector:
disp(['mDot: ',num2str(mDot2),' [g/s]'])
disp(['Spray cone half angle: ',num2str(theta2),' [deg]'])
disp(['Breakup length: ',num2str(lengthB2),' [m]'])

% Here's some math for impingement of two sheets
% Stuff we need:
%       - Filling coefficient
%       - mdot1
%     y - mdot2
%       - axial and circumferential (tangential?) velocity for each cone
%     y - density for oxidizer and fuel
%
% Questions to answer:
%       - How can we achieve a recess number near 1

