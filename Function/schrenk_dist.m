function [y, Dy ,c_plan, c_ell, c_sch, L_plan, L_ell, L_sch] = schrenk_dist(b_half,TR, b , Tc, Rc, q, Cl, S)

%Schrenk Lift Distribution Calculation 

% Span - Wise Distributioon 
y = linspace(0,b_half, 100);
b = 2*b_half;
S = 2*S;
He = 4* S / ( pi * b); % Ellipse Height
Dy = (2.*y) /b; 

% Planform Chord (Linear from root to tip)
c_plan = Rc + ((Tc - Rc) .*Dy);
%c_plan = 2 * S /((1+TR)*b) * ( 1+ (2.*y/b).*(TR-1) );

% Elliptical Chord Distribution
c_ell = He * sqrt(1-Dy.^2) ;

% Schrenk Chord Distribution 
c_sch = (c_plan + c_ell)/2 ;

%% Lift per unit Span

L_plan = q * Cl * c_plan;
L_ell = q * Cl * c_ell;
L_sch = q * Cl * c_sch;

L_half_plan  = trapz(y, L_plan);
L_total_plan  = 2*L_half_plan;

L_half_ell = trapz(y, L_ell);
L_total_ell = 2*L_half_ell;

L_halfL_prime = trapz(y, L_sch);

fprintf('Total Lift over Half Span = %.3f N, \n',L_halfL_prime );

L_totalL_prime = 2*L_halfL_prime;


end
