% MYOEx85 Head loss problem of Example 8.5 in Munson, Young and Okiishi
% --- Define constants for the system and its components
function [headloss,f,V] = MYOEx85(pipeLength,Q,D,k)

% Pipe length (m) input
% Pipe diameter (m) input

A = 0.25*pi*D.^2; % Cross sectional area
e=k;
rho = 999.7;
g = 9.81; % Acceleration of gravity (m^2/s)
mu = 1.307e-3; % Dynamic viscosity (kg/m/s) at 20 degrees C
nu = mu/rho; % Kinematic viscosity (m^2/s)
V = Q/A; % water velocity (m/s)
% --- Laminar solution
Re = V*D/nu;
flam = 64/Re;
dplam = flam * 0.5*(pipeLength/D)*rho*V^2;
% --- Turbulent solution
f = moody((e/D),Re);
dp = f*(pipeLength/D)*0.5*rho*V^2;
% --- Print summary of losses
% fprintf('\nMYO Example 8.5: Re = %12.3e\n\n',Re);
% fprintf('\tLaminar flow: ');
% fprintf('flam = %8.5f; Dp = %7.0f (Pa)\n',flam,dplam)
% fprintf('\tTurbulent flow: ');
% fprintf('f = %8.5f; Dp = %7.0f (Pa)\n',f,dp);
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
headloss=dp/(rho*g);
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
ed=k/D;