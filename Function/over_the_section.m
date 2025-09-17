function [T2] = over_the_section(n_sections,c_trap,b_trap_edge,b_edge,L_trap)

% Preallocate
A_section = zeros(n_sections,1);
L_section = zeros(n_sections,1);
p_section = zeros(n_sections,1);
c_avg     = zeros(n_sections,1);
y_mid     = zeros(n_sections,1);

for i=1:n_sections
    % Average values across strip
    c_avg(i) = 0.5*(c_trap(i)+c_trap(i+1));
    A_section(i) = c_avg(i)*b_trap_edge(i);
    
    Lp_avg   = 0.5*(L_trap(i)+L_trap(i+1));
    y_mid(i) = 0.5*(b_edge(i)+b_edge(i+1));
    
    % Loads
    L_section(i) = Lp_avg*b_trap_edge(i);        % avg lift on strip (N)
    p_section(i) = L_section(i)/A_section(i); % average pressure (Pa)
end

Sections = (1:n_sections)';
T2 = table(Sections,b_edge(1:end-1)',y_mid,b_edge(2:end)',c_avg,A_section,L_section,p_section,...
          'VariableNames',{'Sec','y_start(m)','y_mid (m)','y_end(m)','Chord(m)','Area(m2)','Lift (N)','AvgPressure_Pa'});
      
end