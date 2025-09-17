function Plots_Lift_Distribution(y, L_plan,L_ell, L_sch)
% Plot 
figure ;
plot(y, L_plan, 'g', 'LineWidth', 1); 
hold on;
plot(y, L_ell, 'r', 'LineWidth', 1);
plot(y, L_sch, 'b-', 'LineWidth',1.5);
xlabel('Spanwise Position y (m)');
ylabel('Lift per unit Span (N/m)');
legend('Planform', 'Elliptical', 'Schrenk' , 'Location' , 'northeast');
title('Spanwise Lift Distribution per unit span (m)');
grid on;
end