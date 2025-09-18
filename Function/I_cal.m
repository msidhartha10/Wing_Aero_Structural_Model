clc; clear; close all;

% -------------------------------
% Input: trapezoid dimensions [mm]
% Root section
h1_root = 46.19;   % top width (mm)
h2_root = 45.07;   % bottom width (mm)
b_root  = 12;      % thickness (mm, out-of-plane)

% Tip section
h1_tip = 34.95;    % top width (mm)
h2_tip = 34.07;    % bottom width (mm)
b_tip  = 12;       % thickness (mm)

% Beam length
L = 1.473;         % m (1473 mm)

% Material + load
E = 1.2e+08;      % Pa
P = 10;           % N tip load
% -------------------------------

% Trapezoid Ix formula (about horizontal centroid axis, bending vertical)
% b = thickness, h = distance between parallel sides
trap_Ix = @(b,h1,h2,h) b * (h^3/(36*(h1+h2))) * (h1^2 + 4*h1*h2 + h2^2);

% Root and tip inertia (mm^4)
h_root = (h1_root + h2_root)/2;   % trapezoid height = distance between bases
h_tip  = (h1_tip  + h2_tip )/2;

I_x_root_mm4 = trap_Ix(b_root, h1_root, h2_root, h_root);
I_x_tip_mm4  = trap_Ix(b_tip , h1_tip , h2_tip , h_tip );

% Convert to SI (m^4)
I_x_root = I_x_root_mm4 * 1e-12;
I_x_tip  = I_x_tip_mm4  * 1e-12;

% Linear variation of I along span
n = 2000;
x = linspace(0,L,n);
I_x_dist = I_x_root + (I_x_tip - I_x_root).*(x/L);

% Tip deflection integral (cantilever tip load, variable I)
dx = x(2)-x(1);
integrand = (L - x).^2 ./ (2*E*I_x_dist);
delta_true = sum(integrand) * dx * P;

% Equivalent constant I
I_eff = (P*L^3) / (3*E*delta_true);

% -------------------------------
% Results
fprintf('Tapered trapezoid beam, thickness = %.2f mm\n', b_root);
fprintf('Root top = %.2f mm, bottom = %.2f mm\n', h1_root, h2_root);
fprintf('Tip  top = %.2f mm, bottom = %.2f mm\n\n', h1_tip, h2_tip);

fprintf('Second Moment of Area I_x (m^4):\n');
fprintf(' Root: %.4e\n', I_x_root);
fprintf(' Tip : %.4e\n', I_x_tip);
fprintf(' Eff : %.4e (equivalent for deflection)\n\n', I_eff);

fprintf('True tip deflection under %.1f N load: %.4f mm\n', P, delta_true*1000);
