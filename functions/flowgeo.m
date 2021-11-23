% Program: Basic injector geometry calculations
% Outputs: Can calculate the spray cone half angle and breakup length for
%          both close and open-type coaxial swirl injectors. This file will
%          output graphical representations of spray patterns.

deltaP = input('Enter change in pressure [Pa]: ');
numInlet = input('Enter number of inlet holes: ');
rho = input('Enter density of fluid [kg/m^3]: ');

% Given values:
rInlet = 0.001;     % Radius of inlet holes (m)
rV = 0.005;         % Radius of vortex chamber (m)
rN = rV;            % Radius of vortex chamber at base (m)
rIn = rV-rInlet;    % Swirl arm (m)
viscosity = 10^-6;  % Kinematic viscosity of water (m^2/s)
nozCo = rIn/rN;     % Coefficient of nozzle opening; <1 for open end injectors

if nozCo<1
    disp('Open-type injector geometries:')
    % Calculate the spray cone half angle for an open-type injector:
    A = (rIn*rV)/(numInlet*rInlet^2);                  % Geometric characteristic constant
    disCo = 0.432/(A^0.64);                            % Discharge coefficient of injector
    mDot = disCo*pi*rN^2*(2*rho*deltaP)^0.5;           % Mass flow rate
    Q = mDot/rho;                                      % Volume flow rate (m^3/s)
    Re = (2*Q)/(pi*sqrt(numInlet)*rInlet*viscosity);   % Reynolds number
    theta = atand(0.033*(A^0.338)*(Re^0.249));         % Spray cone half angle (deg)
    lengthB = 2*3935*rN*(A^-0.621)*(Re^-0.465);        % Breakup length (m)

    % Plot and output spray geometries for open-type injector:
    disp(['mDot: ',num2str(mDot),' [g/s]'])
    disp(['Spray cone half angle: ',num2str(theta),' [deg]'])
    disp(['Breakup length: ',num2str(lengthB),' [m]'])
end