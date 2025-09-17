function [b,S,MAC,AR,TR,e, Re, nv,q,k] = Wing_Parameter_Calculation(b_half, Tc, Rc, rho, V, nu)

% Wing Parameter Calculation
%b = 2*b_half ;  % Full - Span (in m)
b = b_half ;  % Half - Span (in m)
MAC = (2/3) * ( ( Rc^2 +Tc^2+Rc*Tc) /(Rc+Tc)); % Mean Aerodynamic Chord (in m)
%S = b*(Tc+Rc)/2; % Span Area (in m^2)
S = b*MAC;
AR = b^2/S;
TR = Tc/Rc;
TR_rad = deg2rad(TR);
e = ( 1.78 * (1-0.045*AR^0.68) - 0.64) / cos(TR_rad);
k = 1 /(pi * e*AR);
% Atmospheric Data
Re = (rho* MAC*V ) / nu; 
nv = nu /rho ;
q = 0.5 * rho *V^2;

% Geometric Print
fprintf('Wing Geometry: \n');
fprintf('Span area = %.3f m, MAC = %.3f m, Aspect Ratio = %.3f, Taper Ratio = %.3f \n \n', S, MAC, AR, TR);

end