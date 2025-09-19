function [T, b_edge, b_trap_edge, c_trap, L_trap, c_mid, y_mid, L_sch_mid, L_section, p_section] = sec_lift_pressure(y, n_sections, b_half, c_plan, c_sch, L_sch)

% ===================================================
% Section-wise Lift Force and Pressure (T1 Only + Plots)
% ===================================================

% Span edges and strip widths
b_edge      = linspace(0, b_half, n_sections+1);
b_trap_edge = diff(b_edge);

% Midpoints (strip centers)
y_mid = 0.5*(b_edge(1:end-1) + b_edge(2:end));

% Assume c_plan and L_sch are already defined on y (midpoints)
c_mid   = interp1(y, c_plan, y_mid, 'linear');   % chord at mids
L_sch_mid = interp1(y, L_sch, y_mid, 'linear'); % lift dist (N/m) at mids

% Chord and lift at strip edges (if available from data)
c_trap = interp1(y, c_plan, b_edge, 'linear');
L_trap = interp1(y, L_sch, b_edge, 'linear');

% Sectional properties
c_avg     = 0.5*(c_trap(1:end-1) + c_trap(2:end));      % avg chord
A_section = c_avg .* b_trap_edge;                       % strip area
%L_avg     = 0.5*(L_trap(1:end-1) + L_trap(2:end));      % avg lift dist (N/m)
%L_section = L_avg .* b_trap_edge;                       % total lift per strip (N)
L_section = L_sch_mid .* b_trap_edge;                       % total lift per strip (N)
p_section = L_section ./ A_section;                     % avg pressure (Pa)

% ===================================================
% Build Table
% ===================================================
Sections = (1:n_sections)';
T = table(Sections, b_edge(1:end-1)', y_mid', b_edge(2:end)', ...
          c_avg', A_section',L_sch_mid', L_section', p_section', ...
    'VariableNames', {'Section','y_start(m)','y_mid(m)','y_end(m)', ...
                      'Chord_avg(m)','Area(m2)','Lift_dist(N/m)', ...
                      'Lift_total(N)','Pressure(Pa)'});

end
