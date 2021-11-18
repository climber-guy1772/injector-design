Area = 0.00001; %cross sectional area of inlet holes (m^2)
mdot = 0.5; %mass flow rate (kg/s)
Rv = 0.005  ; %radius of vortex chamber (m)
rho = 1000; %density of fluid (kg/m^3)
Cp = 3500; %chamber pressure (kPa)
pressureDrop = 500; %pressure drop over injector (kPa)
CD = 0.9; %discharge coefficient

w = mdot/(rho*Area); %tangential velocity of fluid in chamber (m/s)
dPinlet = (mdot/(CD*Area))^2/(2*rho); %pressure drop over the inlet holes (
dPfilm = dPinlet - pressureDrop*1000;
v = mdot/(rho*pi*(Rv^2-(Rv-((dPfilm*Rv)/(rho*w^2)))^2));
theta = atand(w/v); %spray cone half angle (degrees)

fprintf("theta = %f", theta);
