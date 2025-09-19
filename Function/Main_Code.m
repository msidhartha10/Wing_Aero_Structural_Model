clc; 
clear vars;
close all;

%% Input

% Atmospheric Data
rho = 1.225 ; % ( atmoshpheric denisty in kg/m^3)
V = 20.41273; % (freestream velocity in m/s)
nu = 1.7894e-05; % (dynamic viscosity in kg / m-s)
g = 9.81; % gravity

% Wing Parameter
Tc = 0.300 ; %Tip Chord (in m)
Rc = 0.410 ; % Root Chord (in m)
b_half = 1.7 ; % Half -Span (in m)

AeroData = readtable('Aero_Coeff_2D.xlsx');
%desired_angles = [-4 ,-3, -2, -1 , 0 , 1, 2, 3, 4,5,6, 7,8, 9,10, 11, 12];
desired_angles = -4:0.5:6;


Working_AOA = 5; %deg AOA where to get 3D Cl values

n_sections = 10;

%% Function to Calculate Wing Parameters

% Span Area , Taper Ratio , Ascpect Ratio, eccientricity, 
% Mean Aerodynamic Chord (MAC) 
% Renolyds No., Dynamic Pressure, Kinematic Viscosity

[b,S,MAC,AR,TR,e, Re, nv,q,k] = Wing_Parameter_Calculation(b_half, Tc, Rc, rho, V, nu);

%% 3D CL and CD Calculation

results = aerodynamic_coeff(AeroData,desired_angles,b_half, Tc, Rc,e, MAC);
% Aero_Table(results) 
 %Plots_Aero_coeff(results) %  <------ figure

AeroResults = table(results.AOA_deg(:), results.CL_3D_dynamic(:), results.CD_3D(:), 'VariableNames',{'AOA_deg','CL_3D', 'CD_3D'});
%disp(AeroResults);

idx = find(AeroResults.AOA_deg == Working_AOA , 1);
% Extract 3D Cl value
Cl = AeroResults.CL_3D(idx);
Cd = AeroResults.CD_3D(idx);
% OR
%Cl = 0.50713; %(Assumed for Clark Y at AOA: 2.5, CFD)

L_D = Cl/Cd;
L_t = q*S*Cl;
D_t = q*S*Cd;
CD0 = results.Cd0_2D_at_0deg;

fprintf('Zero-lift angle (alpha_L0) = %.4f deg \n\n', rad2deg(results.alpha_L0));
fprintf('CD0 = %.4f \n\n', (CD0));
fprintf('3D CL value (Full Wing Span)= %.4f at AOA = %.2f deg \n\n', Cl, Working_AOA);
fprintf('3D CD value (Full Wing Span)= %.4f at AOA = %.2f deg \n\n', Cd, Working_AOA);
fprintf('L/D = %.4f \n\n', (L_D));
fprintf('Therotical Lift = %.4f N & Drag value  %.4f N at AOA = %.2f deg \n\n',L_t, D_t, Working_AOA);

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
wing_mass = 0.0;   % kg (set per your structure)

% positions along half-span (from root)
pos1 = 0.5 * b_half; % m
pos2 = 0.2 * b_half; % m

%[R,V,M,P, root_shear, root_moment] = SFD_BMD(y, L_sch);
%[R,Vi,M,P, root_shear, root_moment,P1,P2,W_points , W_dist] = SFD_BMD2(g,m1,m2,pos1,pos2,y,b_half, L_sch);
[R,Vi,M,P, root_shear, root_moment,P1,P2,W_points , W_dist] = SFD_BMD3(g,m1,m2,pos1,pos2,y,b_half,L_sch,c_sch,wing_mass);
fprintf('SFD/BMD results (half-wing) with point loads:\n');

fprintf('   Root reaction R = %.3f N (upwards), M_root = %.3f N*m \n \n', root_shear, root_moment);

fprintf('  Point loads: P1 = %.2f N at y=%.3f m, P2 = %.2f N at y=%.3f m \n \n', P1, pos1, P2, pos2);
fprintf('  Distributed lift (half-wing) = %.3f N (upwards)\n \n', W_dist);
fprintf('  Total point loads = %.3f N (downwards)\n \n', W_points);



% % Plots_SFD_BMD(y, L_sch,V,P);  %<------ figure
%Plots_SFD_BMD2(y, L_sch,Vi,P, pos1 ,pos2);  %<------ figure

% Deflection 
% % BMD is in P (N*m) and y is the span vector (m)
% 
% h1_root = 46.19; h2_root = 45.07; b_root = 12;
% % Tip trapezoid [mm]
% h1_tip  = 34.95; h2_tip  = 34.07; b_tip  = 12;
% 
% trap_Ix = @(b,h1,h2,h) b*(h^3/(36*(h1+h2)))*(h1^2+4*h1*h2+h2^2);
% h_root = (h1_root+h2_root)/2; 
% h_tip  = (h1_tip+h2_tip)/2;
% 
% I_root = trap_Ix(b_root,h1_root,h2_root,h_root)*1e-12;
% I_tip  = trap_Ix(b_tip ,h1_tip ,h2_tip ,h_tip )*1e-12;
% 
% % Linear taper of I along span
% I_dist = I_root + (I_tip - I_root).*(y/b_half);

%% Deflection
E = 290e+09; % Pa (carbon fiber)
I_dist = 2.243176e-08;    % second moment of area

[tip_deflection,w_def,theta,M_bend] = Deflection(y,P,E,I_dist,'M');

%fprintf('\n Tip deflection = %.3f mm \n',tip_deflection);

%max_deflection = min(w_def*1000);  % most negative (if sign is negative) in mm
%disp(max_deflection);

% %% ----- Breguet range & endurance Calculations -----
% 
% % Range (prop)  : R = (eta_p * L/D / c) * log(W_i / W_f)
% % Endurance (prop) : E = (eta_p * (Cl^(3/2)/Cd)/c) *sqrt(2*rho*S) *((W_i)^-0.5-(W_f)^-0.5)(seconds)
% %
% % Range (jet) : R = (1 / ct) * sqrt(2/rho*S)* (Cl^0.5/Cd) * (W_i^0.5 - W_f^0.5)
% % Endurance (jet) : E = (1 / ct) * (L/D) * log(W_i / W_f)
% 
% W_empty = 5; % Kg
% W_fuel = 3;            % kg of fuel onboard  
% W_payload = 5;
% 
% eta_p = 0.7;             % propulsive efficiency (typical small prop)
% 
% % Suppose SFC is  
% c_per_hr = 0.5;    % 1/hour convert to 1/s
% c_per_sec = c_per_hr / 3600;
% 
% [L_D_3_2,W_i, W_f,R_prop,E_prop] = Range_Endurance(rho, S, g, V, W_fuel,CD0, W_empty,W_payload,k,Cl, Cd, L_D,eta_p, c_per_hr, c_per_sec);
% 
% save('myData.mat')
close all;