%Dimensions Calculator
mdot= input('Enter mass flow rate: ');
Pressuret=input('Enter Pressure drop: ');%liquid overpressure/pressure drop
rho=input('Enter density of fluid: ');%density
v=input('Enter desired velocity: ');%formulas need velocity???
K=input('Enter K based on desired spray cone angle: ');%Injector geometry constant
numinlet= 4;%number of inlet holes     v---- Inverse function of K(filling coefficient) bayvel 261 using finverse function
fillingco=((((2^(1/2)/(2*K) - (2*2^(1/2))/(27*K^3))^2 - 8/(729*K^6))^(1/2) + 2^(1/2)/(2*K) - (2*2^(1/2))/(27*K^3))^(1/3) - 2^(1/2)/(3*K) + 2/(9*K^2*(((2^(1/2)/(2*K) - (2*2^(1/2))/(27*K^3))^2 - 8/(729*K^6))^(1/2) + 2^(1/2)/(2*K) - (2*2^(1/2))/(27*K^3))^(1/3)))^2;
dischargeco=fillingco*sqrt(fillingco/(2-fillingco));%discharge coefficient
d0=sqrt((4*mdot)/(pi*dischargeco*sqrt(2rho*pressuret)));
R=3*(d0/2);%assumption based on Bayvel 263
dp=sqrt((2*R*d0)/(K*numinlet));%diameter of orifice
d=sqrt(numinlet)*dp;%total diameter
vp=(4*mdot)/(pi*rho*numinlet*(dp^2));%velocity at inlet?
alpha=2*atand((2*sqrt(2)*(1-E))/(sqrt(E)*(1+sqrt(1-E))));%spray cone angle just to make sure
Re=(4*mdot)/(pi*rho*v*sqrt(numinlet)*dp)