function Plot_Sec_lift_press(y, L_sch,y_mid,L_sch_mid, p_section)
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

