    function Plots_Aero_coeff(results) 
% --------------------- Plots ---------------------
figure;
plot(results.AOA_deg, results.Cl_2D, 'bo-', 'LineWidth', 1.6); hold on;
plot(results.AOA_deg, results.CL_3D_dynamic, 'g*-', 'LineWidth', 1.6);
grid on;
xlabel('Angle of Attack (deg)');
ylabel('Lift Coefficient (C_L)');
title('2D vs 3D Lift Curve (Clark Y trapezoid)');
legend('2D Cl', '3D CL', 'Location', 'NorthWest');

figure;
plot(results.AOA_deg, results.Cd_2D, 'bo-', 'LineWidth', 1.6); hold on;
plot(results.AOA_deg, results.CD_3D, 'go-', 'LineWidth', 1.6);
grid on;
xlabel('Angle of Attack (deg)');
ylabel('Drag Coefficient (C_D)');
title('2D vs 3D Drag Curve (Clark Y trapezoid)');
legend('2D Cd', '3D Cd total', 'Location', 'NorthWest');
    end