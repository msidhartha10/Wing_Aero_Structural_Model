clc; 
clear vars;
close all;

%% Input

% Atmospheric Data
rho = 1.225 ; % ( atmoshpheric denisty in kg/m^3)
V = 25; % (freestream velocity in m/s)
nu = 1.7894e-05; % (dynamic viscosity in kg / m-s)
g = 9.81; % gravity

% Wing Parameter
Tc = 0.300 ; %Tip Chord (in m)
Rc = 0.410 ; % Root Chord (in m)
b_half = 1.7 ; % Half -Span (in m)

AeroData = readtable('Aero_Coeff_2D.xlsx');
%desired_angles = [-4 ,-3, -2, -1 , 0 , 1, 2, 3, 4,5,6, 7,8, 9,10, 11, 12];
desired_angles = -4:0.5:10;

% Cl = 0.7; %(Assumed for Clark Y at AOA: 5)
% OR
Working_AOA = 5; %deg AOA where to get 3D Cl values

n_sections = 10;

%% Function to Calculate Wing Parameters

% Span Area , Taper Ratio , Ascpect Ratio, eccientricity, 
% Mean Aerodynamic Chord (MAC) 
% Renolyds No., Dynamic Pressure, Kinematic Viscosity

[b,S,MAC,AR,TR,e, Re, nv,q,k] = Wing_Parameter_Calculation(b_half, Tc, Rc, rho, V, nu);

%% 3D CL and CD Calculation

results = aerodynamic_coeff(AeroData,desired_angles,b_half, Tc, Rc,e );
% Aero_Table(results) 
 Plots_Aero_coeff(results) %  <------ figure

AeroResults = table(results.AOA_deg(:), results.CL_3D_dynamic(:), results.CD_3D(:), 'VariableNames',{'AOA_deg','CL_3D', 'CD_3D'});
disp(AeroResults);

idx = find(AeroResults.AOA_deg == Working_AOA , 1);
% Extract 3D Cl value
Cl = AeroResults.CL_3D(idx);
Cd = AeroResults.CD_3D(idx);
L_D = Cl/Cd;
CD0 = results.Cd0_2D_at_0deg;
fprintf('3D CL value (Full Wing Span)= %.4f at AOA = %d deg \n\n', Cl, Working_AOA);
fprintf('Zero-lift angle (alpha_L0) = %.4f deg \n\n', rad2deg(results.alpha_L0));
fprintf('CD0 = %.4f \n\n', (CD0));
fprintf('3D CD value (Full Wing Span)= %.4f at AOA = %d deg \n\n', Cd, Working_AOA);
fprintf('L/D = %.4f \n\n', (L_D));
%% Function to Calculate Shrenk Lift Ditribution %%%

% Calculte Lift Distribution on Planform , Elliptical, Schrenk and Plot
[y , Dy ,c_plan, c_ell, c_sch, L_plan, L_ell, L_sch] = schrenk_dist(b_half,TR, b , Tc, Rc, q, Cl, S);

%Plots_Lift_Distribution(y, L_plan,L_ell, L_sch)   %<------ figure

%% Function to Calculate Section wise Lift force and Pressure
[T, b_edge, b_trap_edge, c_trap, L_trap] = sec_lift_pressure(y, n_sections, b_half, c_plan, c_sch, L_sch);
%[T,T2, b_edge, b_trap_edge, c_trap, L_trap] = sec_lift_pressure2(y ,n_sections,b_half, c_plan,c_sch, L_sch);
fprintf('Schrenk Lift Distribution over 10 sections \n');
disp(T);

%% Lift and Pressure over the surface of a section:

%[T2] = over_the_section(n_sections,c_trap,b_trap_edge,b_edge,L_trap);
%disp('Lift and Pressure over the surface of a section:');
%disp(T2);

%% Function to calculate SFD & BMD

% masses in kg (downward forces)
m1 = 0;      % at y1 of half-span
m2 = 0;      % at y2 of half-span

% positions along half-span (from root)
pos1 = 0.5 * b_half; % m
pos2 = 0.2 * b_half; % m

%[R,V,M,P, root_shear, root_moment] = SFD_BMD(y, L_sch);
[R,Vi,M,P, root_shear, root_moment,P1,P2,W_points , W_dist] = SFD_BMD2(g,m1,m2,pos1,pos2,y,b_half, L_sch);

fprintf('SFD/BMD results (half-wing) with point loads:\n');

fprintf('   Root reaction R = %.3f N (upwards), M_root = %.3f N*m \n', root_shear, root_moment);

fprintf('  Point loads: P1 = %.2f N at y=%.3f m, P2 = %.2f N at y=%.3f m\n', P1, pos1, P2, pos2);
fprintf('  Distributed lift (half-wing) = %.3f N (upwards)\n', W_dist);
fprintf('  Total point loads = %.3f N (downwards)\n', W_points);


% Plots_SFD_BMD(y, L_sch,V,P);  %<------ figure
%Plots_SFD_BMD2(y, L_sch,Vi,P, pos1 ,pos2);  %<------ figure

%% Deflection 
% Assumes your BMD is in P (N*m) and y is the span vector (m)

% breath = 1.7; % in m
% height = 30/1000;  % in m
% thickness = 14/1000 ; % in m 
% I = (breath *height^3)/12;

% using E = 290 GPa (carbon fiber)
E = 290.0e+09;     % Pa (290 GPa carbon fiber)
I = 1.0e-8;    % moment of inetria 

% % using (PVC FOAM 80KG/M3)
% E = 1.02e+08;     % Pa 
% I = 1.27e-5;    % moment of inetria

[tip_deflection,w_def,theta] = Deflection(y, P, E, I);
%[tip_deflection,w_def,theta] = Deflection2(n_sections,c_sch, y, P, E, I);
max_deflection = min(w_def*1000);  % most negative (if sign is negative) in mm
% disp(max_deflection);

%% ----- Breguet range & endurance Calculations -----

% Range (prop)  : R = (eta_p * L/D / c) * log(W_i / W_f)
% Endurance (prop) : E = (eta_p * (Cl^(3/2)/Cd)/c) *sqrt(2*rho*S) *((W_i)^-0.5-(W_f)^-0.5)(seconds)
%
% Range (jet) : R = (1 / ct) * sqrt(2/rho*S)* (Cl^0.5/Cd) * (W_i^0.5 - W_f^0.5)
% Endurance (jet) : E = (1 / ct) * (L/D) * log(W_i / W_f)

W_empty = 5; % Kg
W_fuel = 3;            % kg of fuel onboard  
W_payload = 5;

eta_p = 0.7;             % propulsive efficiency (typical small prop)

% Suppose SFC is  
c_per_hr = 0.5;    % 1/hour convert to 1/s
c_per_sec = c_per_hr / 3600;

[L_D_3_2,W_i, W_f,R_prop,E_prop] = Range_Endurance(rho, S, g, V, W_fuel,CD0, W_empty,W_payload,k,Cl, Cd, L_D,eta_p, c_per_hr, c_per_sec);