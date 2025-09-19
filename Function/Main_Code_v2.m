% Wing Aero-Structural Model: Sequential Analysis Script
% Author: msidhartha10
% Repository: Wing_Aero_Structural_Model (https://github.com/msidhartha10/Wing_Aero_Structural_Model)
% Description:
%   This script performs a sequential aero-structural analysis for a finite wing:
%   1) Inputs and constants
%   2) Wing parameter calculation
%   3) 3D aerodynamic coefficients from 2D data
%   4) Schrenk lift distribution
%   5) Section-wise lift and pressure
%   6) Shear force and bending moment diagrams (SFD/BMD) with point loads
%   7) Deflection under bending
%   Optional: range and endurance calculations (commented)
%
% Dependencies (functions expected in path):
%   - Wing_Parameter_Calculation
%   - aerodynamic_coeff
%   - schrenk_dist
%   - sec_lift_pressure (or sec_lift_pressure2)
%   - SFD_BMD3 (or SFD_BMD / SFD_BMD2)
%   - Deflection
%
% Data files:
%   - Aero_Coeff_2D.xlsx (2D airfoil aerodynamic data vs AoA)
%
% Notes:
%   - Ensure the working angle of attack exists in the angle sweep, otherwise the nearest AoA is used.
%   - You can override Cl/Cd with known values (e.g. from CFD) via flags.

clc;
clear vars;
clear functions;
close all;

%% 0) Configuration and Flags

SAVE_DATA = false;   % Save .mat data at end
VERBOSE   = true;    % Print detailed logs
PLOTS = false;        % Display Plots

% Override aerodynamic coefficients with known values (e.g., CFD)
USE_CLCD_OVERRIDE = false;
CL_OVERRIDE = 0.50713;  % Example: Clark Y at AOA = 2.5 deg (CFD)
CD_OVERRIDE = [];       % Leave empty to keep computed CD

%% 1) Inputs

% Atmospheric Data
rho = 1.225;         % kg/m^3 (atmospheric density)
%V   = 20.41273; 
 V = 25;            % m/s   (freestream velocity)
nu  = 1.7894e-05;    % kg/(m·s) (dynamic viscosity)
g   = 9.81;          % m/s^2 (gravity)

% Wing Parameters
Tc      = 0.300;     % Tip chord (m)
Rc      = 0.410;     % Root chord (m)
b_half  = 1.7;       % Half-span (m)

% Aerodynamic setup
aero_file      = 'Aero_Coeff_2D.xlsx';
desired_angles = -6:0.5:6;   % deg
Working_AOA    = 5;        % deg AoA to extract 3D CL/CD

% Discretization
n_sections = 10;      % Section count for lift/pressure splitting

% Read 2D aerodynamic data
try
    AeroData = readtable(aero_file);
catch ME
    error('Failed to read %s: %s', aero_file, ME.message);
end

%% 2) Wing Parameter Calculation
% Computes: span b, planform area S, MAC, AR, taper ratio TR, Oswald e,
% Reynolds number Re, kinematic viscosity nv, dynamic pressure q, induced factor k

[b,S,S_half,MAC,AR,TR,e, Re, nv,q,k, Vx,Vy] = Wing_Parameter_Calculation(b_half, Tc, Rc, rho, V, nu, Working_AOA);

if VERBOSE
    fprintf('Wing Parameters:\n');
    fprintf('  Full Span (b) = %.3f m | Half-span (b_half) = %.3f m\n', 2* b_half, b_half);
    fprintf('  Full Wing Area (S) = %.4f m^2 |  Half Wing Area (S_half) = %.4f m^2 \n',S, S_half);
    fprintf('  For Full Span : MAC = %.4f m | AR = %.3f | TR = %.3f | e = %.3f\n',  MAC, AR, TR, e);
    fprintf('  Reynolds No. = %.3e | q = %.2f Pa | k = %.5f\n\n', Re, q, k);
    fprintf('  Freestream Velocity, V is = %.3f m/s and its components at AOA = %.f deg | Vx = %.4f m/s  | Vy = %.4f m/s  \n\n', V, Working_AOA, Vx, Vy);
end

%% 3) 3D CL and CD Calculation from 2D data

results = aerodynamic_coeff(AeroData,desired_angles,b_half, Tc, Rc,e, b,S,S_half,MAC,AR,TR );

% Build results table for quick lookup
AeroResults = table(results.AOA_deg(:), results.CL_3D_dynamic(:), results.CD_3D(:), ...
    'VariableNames', {'AOA_deg','CL_3D','CD_3D'});

% Locate index for Working_AOA; if not exact, use nearest angle
idx = find(AeroResults.AOA_deg == Working_AOA, 1);
if isempty(idx)
    [~, idx] = min(abs(AeroResults.AOA_deg - Working_AOA));
    if VERBOSE
        fprintf('Note: Working_AOA = %.2f deg not in sweep; using nearest AoA = %.2f deg\n', ...
            Working_AOA, AeroResults.AOA_deg(idx));
    end
end

% Extract computed 3D coefficients
Cl = AeroResults.CL_3D(idx);
Cd = AeroResults.CD_3D(idx);

% Optional override from CFD or known test data
if USE_CLCD_OVERRIDE
    Cl = CL_OVERRIDE;
    if ~isempty(CD_OVERRIDE)
        Cd = CD_OVERRIDE;
    end
end

% Zero-lift CD at 0 deg (from results struct)
if isfield(results, 'Cd0_2D_at_0deg')
    CD0 = results.Cd0_2D_at_0deg;
else
    CD0 = NaN;
end

% Performance metrics
L_D = Cl / max(Cd, eps);
L_t = q * S_half * Cl;   % Lift (N)
D_t = q * S_half * Cd;   % Drag (N)

if VERBOSE
    fprintf('Aerodynamic Results:\n');
    if isfield(results,'alpha_L0')
        fprintf('  Zero-lift angle alpha_L0 = %.4f deg\n', rad2deg(results.alpha_L0));
    end
    fprintf('  CD0 (2D at 0 deg) = %.4f\n', CD0);
    fprintf('  3D CL (full-wing) = %.4f at AoA = %.2f deg\n', Cl, Working_AOA);
    fprintf('  3D CD (full-wing) = %.4f at AoA = %.2f deg\n', Cd, Working_AOA);
    fprintf('  L/D = %.4f\n', L_D);
    fprintf('  Theoretical Lift = %.4f N | Drag = %.4f N at AoA = %.2f deg\n\n', L_t, D_t, Working_AOA);
end

       
 
%% 4) Schrenk Lift Distribution

% Compute chord distributions and lift distributions
[y, Dy, c_plan, c_ell, c_sch, L_plan, L_ell, L_sch] = schrenk_dist(b_half, TR, b, Tc, Rc, q, Cl, S);

% if VERBOSE
%     fprintf('Schrenk Lift Distribution computed over half-span (%d nodes)\n\n', numel(y));
% end



%% 5) Section-wise Lift Force and Pressure

[T, b_edge, b_trap_edge, c_trap, L_trap, c_mid, y_mid, L_sch_mid, L_section, p_section] = sec_lift_pressure(y, n_sections, b_half, c_plan, c_sch, L_sch);

fprintf('Schrenk Lift Distribution over %d sections:\n', n_sections);
disp(T);

%% 6) Shear Force Diagram (SFD) and Bending Moment Diagram (BMD)

% Point masses (downward forces): specify as needed
m1 = 0;           % kg at pos1
m2 = 0;           % kg at pos2
wing_mass =0.0;    % kg (distributed or lumped at nodes inside SFD)

% Positions along half-span from root:
pos1 = 0.5 * b_half;  % m
pos2 = 0.2 * b_half;  % m

% Use SFD_BMD3 which can include distributions and mass effects
[R, Vi, M, P, root_shear, root_moment, P1, P2, W_points, W_dist] = ...
    SFD_BMD3(g, m1, m2, pos1, pos2, y, b_half, L_sch, c_sch, wing_mass);

fprintf('SFD/BMD results (half-wing) with point loads:\n');
fprintf('  Root reaction R = %.3f N (upwards), M_root = %.3f N·m\n', root_shear, root_moment);
fprintf('  Point loads: P1 = %.2f N at y = %.3f m, P2 = %.2f N at y = %.3f m\n', P1, pos1, P2, pos2);
fprintf('  Distributed lift (half-wing) = %.3f N (upwards)\n', W_dist);
fprintf('  Total point loads = %.3f N (downwards)\n\n', W_points);

%% 7) Deflection under Bending

% Material and section properties
E = 290e9;               % Pa (e.g., carbon fiber)
I_dist = 2.243176e-08;   % m^4 (constant second moment of area)

% Optionally, define spanwise-varying I_dist via geometry (example commented)
% h1_root = 46.19; h2_root = 45.07; b_root = 14;  % mm
% h1_tip  = 34.95; h2_tip  = 34.07; b_tip  = 14;  % mm
% trap_Ix = @(b,h1,h2,h) b*(h^3/(36*(h1+h2)))*(h1^2 + 4*h1*h2 + h2^2);
% h_root = (h1_root + h2_root)/2;
% h_tip  = (h1_tip  + h2_tip)/2;
% I_root = trap_Ix(b_root,h1_root,h2_root,h_root) * 1e-12; % mm^4 -> m^4
% I_tip  = trap_Ix(b_tip ,h1_tip ,h2_tip ,h_tip ) * 1e-12;
% I_dist = I_root + (I_tip - I_root) * (y / b_half);  % linear taper

[tip_deflection, w_def, theta, M_bend] = Deflection(y, P, E, I_dist, 'M');

fprintf('Using E=%.3e Pa -> Tip deflection = %.6f mm\n', E, tip_deflection);

%% 8) Optional: Breguet Range and Endurance (commented example)
%{
% Range/Endurance calculations for propeller-driven aircraft
W_empty  = 5;       % kg
W_fuel   = 3;       % kg
W_payload= 5;       % kg
eta_p    = 0.7;     % Propulsive efficiency
c_per_hr = 0.5;     % SFC [1/hour]
c_per_sec= c_per_hr / 3600;

[L_D_3_2, W_i, W_f, R_prop, E_prop] = Range_Endurance( ...
    rho, S, g, V, W_fuel, CD0, W_empty, W_payload, k, Cl, Cd, L_D, eta_p, c_per_hr, c_per_sec);
%}

%% 9) Save Data (optional)

if SAVE_DATA
    save('wing_aero_structural_results.mat', ...
        'rho','V','nu','g','Tc','Rc','b_half','desired_angles','Working_AOA', ...
        'b','S','MAC','AR','TR','e','Re','nv','q','k', ...
        'results','AeroResults','Cl','Cd','L_D','L_t','D_t','CD0', ...
        'y','Dy','c_plan','c_ell','c_sch','L_plan','L_ell','L_sch', ...
        'T','b_edge','b_trap_edge','c_trap','L_trap', ...
        'R','Vi','M','P','root_shear','root_moment','P1','P2','W_points','W_dist', ...
        'E','I_dist','tip_deflection','w_def','theta','M_bend');
end

%% 10) Plots

if PLOTS 
    
 Plots_Aero_coeff(results);
 Plots_Lift_Distribution(y, L_plan, L_ell, L_sch);
 Plot_Sec_lift_press(y, L_sch,y_mid,L_sch_mid, p_section);
 Plots_SFD_BMD2(y, L_sch, Vi, P, pos1, pos2);
 Plot_deflection(y, M,P,theta, w_def);

end

% End of script
