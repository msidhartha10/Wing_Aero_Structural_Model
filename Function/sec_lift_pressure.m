function [T, b_edge, b_trap_edge, c_trap, L_trap] = sec_lift_pressure(y, n_sections, b_half, c_plan, c_sch, L_sch)

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

% ===================================================
% Plots
% ===================================================

% --- Lift distribution ---
figure;
plot(y, L_sch, 'r-', 'LineWidth', 5); hold on;
stem(y_mid, L_sch_mid, 'b','filled', 'LineWidth', 3); 
xlabel('Spanwise position y (m)');
ylabel('Lift per unit span (N/m)');
title('Spanwise Lift Distribution (T1)');
legend('L_{sch} input','Sectional lift','Location','Best');
grid on;

% Add value labels for lift stems
for i = 1:length(y_mid)
    text(y_mid(i), L_sch_mid(i), ...
        sprintf('%.2f', L_sch_mid(i)), ...
        'VerticalAlignment','bottom','HorizontalAlignment','center', ...
        'FontSize',8,'FontWeight','bold','Color','b');
end

% --- Pressure distribution ---
figure;
plot(y_mid, p_section, 'r-', 'LineWidth', 5); hold on;
%plot(b_edge(2:end), p_end_of_section, 'r-', 'LineWidth', 2); hold on;
stem(y_mid, p_section, 'g','filled', 'LineWidth', 3);  
xlabel('Spanwise position y (m)');
ylabel('Pressure (Pa)');
title('Spanwise Pressure Distribution (T1)');
legend('Section pressure','Location','Best');
grid on;

% Add value labels for pressure stems
for i = 1:length(y_mid)
    text(y_mid(i), p_section(i), ...
        sprintf('%.2f', p_section(i)), ...
        'VerticalAlignment','bottom','HorizontalAlignment','center', ...
        'FontSize',8,'FontWeight','bold','Color','g');
end


end
