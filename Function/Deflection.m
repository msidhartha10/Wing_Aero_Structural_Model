function [tip_deflection,w_def,theta,M] = Deflection(y, input_vec, E, I, type)
% Deflection of a cantilever beam with load along the span
%
% Inputs:
%   y         - spanwise coordinate [m] (column vector)
%   input_vec - distributed load q(y) [N/m], OR shear V(y) [N],
%               OR moment M(y) [N·m] depending on 'type'
%   E         - Young's modulus [Pa]
%   I         - second moment of area [m^4] (scalar or vector same length as y)
%   type      - 'q', 'V', or 'M'
%
% Outputs:
%   tip_deflection - deflection at tip [mm]
%   w_def          - deflection distribution [m]
%   theta          - slope distribution [rad]
%   M              - bending moment distribution [N·m]

y   = y(:);
vec = input_vec(:);

switch type
    case 'q'  % distributed load N/m
        V = cumtrapz(y, -vec);      % shear [N]
        M = cumtrapz(y, V);         % bending moment [N·m]
    case 'V'  % shear force N
        M = cumtrapz(y, vec);       % bending moment [N·m]
    case 'M'  % already bending moment
        M = vec;                    % N·m
    otherwise
        error('Type must be ''q'', ''V'', or ''M''');
end

% Expand I if scalar
if isscalar(I)
    I = I*ones(size(y));
end

% EI slope and deflection (pointwise division)
theta = cumtrapz(y, M./(E.*I));    % slope (rad)
w_def = cumtrapz(y, theta);        % deflection (m)
tip_deflection = w_def(end)*1000;  % convert to mm

fprintf('Using E=%.3e Pa -> Tip deflection = %.6f mm\n', E, tip_deflection);

% % Plot results
% figure('Name','Deflection','Units','normalized','Position',[0.1 0.1 0.5 0.5]);
% subplot(3,1,1); plot(y, M,'LineWidth',1.4); grid on;
% ylabel('M (N·m)'); title('Bending Moment');
% subplot(3,1,2); plot(y, theta,'LineWidth',1.4); grid on;
% ylabel('Slope (rad)'); title('Slope along span');
% subplot(3,1,3); plot(y, w_def*1000,'LineWidth',1.4); grid on;
% xlabel('y (m)'); ylabel('Deflection (mm)'); title('Deflection');
end
