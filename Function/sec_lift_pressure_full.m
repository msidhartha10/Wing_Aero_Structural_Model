function [T1, T2, b_edge, b_trap_edge, c_trap, L_trap] = sec_lift_pressure_full(y ,n_sections,b_half, c_plan,c_sch, L_sch)

% ===================================================
% 1. Discrete lift distribution at section midpoints
% ===================================================
y_sections       = linspace(0, b_half, n_sections);
c_sch_sections   = interp1(y , c_plan, y_sections);
L_sch_sections   = interp1(y , L_sch, y_sections);

% Edges and trapezoidal subdivision
b_edge      = linspace(0, b_half, n_sections+1);
b_trap_edge = diff(b_edge);

% Chord and lift at strip edges
c_trap = interp1(y , c_plan, b_edge,'pchip');
L_trap = interp1(y , L_sch, b_edge,'spline');

% Pressure per unit span at edges
P_sec = L_trap ./c_trap;
p_end_of_section = P_sec(2:end);

% Preallocate for section values
A_section_T1 = zeros(n_sections,1);
L_section_T1 = zeros(n_sections,1);

for i=1:n_sections
    % Average chord for section
    c_avg_T1 = 0.5*(c_trap(i)+c_trap(i+1));
    A_section_T1(i) = c_avg_T1 * b_trap_edge(i);

    % Average lift per unit span across strip (N/m)
    Lp_avg_T1 = 0.5*(L_trap(i)+L_trap(i+1));

    % Section lift force (N)
    L_section_T1(i) = Lp_avg_T1 * b_trap_edge(i);
end

% Table T1: simple section-wise distribution (with area + lift force)
T1 = table((1:n_sections)', y_sections', c_sch_sections', L_sch_sections', ...
           A_section_T1, L_section_T1, p_end_of_section', ...
    'VariableNames' , {'Section','y_mid(m)','Chord(m)', ...
                       'L_sch(N/m)','Area(m2)','Lift(N)','P_sec_end(Pa)'});

% ===================================================
% 2. Integrated strip forces (area, lift, avg pressure)
% ===================================================
A_section = zeros(n_sections,1);
L_section = zeros(n_sections,1);   % integrated lift per strip (N)
L_avg_mid = zeros(n_sections,1);   % distributed lift at mid (N/m)
p_section = zeros(n_sections,1);
c_avg     = zeros(n_sections,1);
y_mid     = zeros(n_sections,1);

for i=1:n_sections
    % Average chord for strip
    c_avg(i)   = 0.5*(c_trap(i)+c_trap(i+1));
    A_section(i) = c_avg(i)*b_trap_edge(i);

    % Average lift per unit span across strip (N/m)
    Lp_avg     = 0.5*(L_trap(i)+L_trap(i+1));
    y_mid(i)   = 0.5*(b_edge(i)+b_edge(i+1));

    % Save both integrated and distributed values
    L_section(i)   = Lp_avg*b_trap_edge(i);    % total lift per strip (N)
    L_avg_mid(i)   = Lp_avg;                   % distributed lift at mid (N/m)
    p_section(i)   = L_section(i)/A_section(i);% pressure (Pa)
end

Sections = (1:n_sections)';

% Table T2: integrated properties
T2 = table(Sections, b_edge(1:end-1)', y_mid, b_edge(2:end)', c_avg, A_section, ...
           L_section, L_avg_mid, p_section, ...
    'VariableNames',{'Sec','y_start(m)','y_mid(m)','y_end(m)', ...
                     'Chord(m)','Area(m2)','Lift(N)','Lift_avg(N/m)','AvgPressure(Pa)'});

% ===================================================
% 3. Plots
% ===================================================

% --- Lift plot ---
figure;
plot(y_sections, L_sch_sections, 'r-', 'LineWidth', 2); hold on;
stem(y_sections, L_sch_sections, 'g','filled'); % T1 distributed
stem(y_mid, L_avg_mid, 'b','filled');           % T2 distributed
xlabel('Spanwise position y_{mid} (m)');
ylabel('Lift per unit span (N/m)');
title('Spanwise Lift Distribution');
legend('L_{sch} curve','T1 sectional lift','T2 avg mid lift','Location','Best');
grid on;

% --- Pressure plot ---
figure;
plot(y_sections, p_end_of_section, 'r-', 'LineWidth', 2); hold on;
stem(y_sections, p_end_of_section, 'g','filled'); % T1 pressure
stem(y_mid, p_section, 'b','filled');             % T2 avg pressure
xlabel('Spanwise position y_{mid} (m)');
ylabel('Pressure (Pa)');
title('Spanwise Pressure Distribution');
legend('Pressure curve','T1 pressure','T2 avg pressure','Location','Best');
grid on;

end
