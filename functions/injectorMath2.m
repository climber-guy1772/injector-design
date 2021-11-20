n = 4; %number of inlet holes
Rinlet = 0.001; %radius of inlet holes (m)
Rv = 0.005  ; %radius of vortex chamber (m)
Rin = Rv-Rinlet; %yeah
mdot = 0.5; %mass flow rate (kg/s)
rho = 1000; %density of fluid (kg/m^3)
Q = mdot/rho; %volume flow rate (m^3/s)
viscosity = 10^-6; %kinematic viscosity of water (m^2/s)

A = (Rin*Rv)/(n*Rinlet^2); %geometric characteristic constant
Re = (2*Q)/(pi*sqrt(n)*Rinlet*viscosity); %Reynolds number
theta = atand(0.033*A^0.338*Re^0.249); %spray cone half angle

fprintf("theta2 = %f\n", theta2);
