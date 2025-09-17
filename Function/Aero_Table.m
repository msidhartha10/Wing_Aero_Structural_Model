function Aero_Table(results)

  % Results
  AOA_deg = results.AOA_deg  ;           
  Cl_2D         = results.Cl_2D ;
  Cd_2D                =   results.Cd_2D ;
  
  alpha_L0             = results.alpha_L0;
Cl_alpha_2D_dynamic  =   results.Cl_alpha_2D_dynamic;
  CL_alpha_dynamic     = results.CL_alpha_dynamic;
  
CL_3D_dynamic        =   results.CL_3D_dynamic;
  
 Cd0_2D_at_0deg       =  results.Cd0_2D_at_0deg ;
  CD_induced           = results.CD_induced;
CD_3D                =   results.CD_3D ;
  
 k = length(AOA_deg); 
% --------------------- Tables ---------------------
fprintf('\nTable 1: Lift Curve Slopes (per rad)\n');
fprintf('%-10s %-18s %-18s\n', 'AOA(deg)', '2D dCl/dα', '3D dCL/dα');
fprintf('------------------------------------------------------\n');
for i = 1:k
    fprintf('%-10.1f %-18.4f %-18.4f\n', AOA_deg(i), Cl_alpha_2D_dynamic(i), CL_alpha_dynamic(i));
end

fprintf('\nTable 2: Lift Coefficients\n');
fprintf('%-10s %-15s %-15s\n', 'AOA(deg)', '2D Cl', '3D CL');
fprintf('---------------------------------------------\n');
for i = 1:k
    fprintf('%-10.1f %-15.4f %-15.4f\n', AOA_deg(i), Cl_2D(i), CL_3D_dynamic(i));
end

fprintf('\nTable 3: Drag Coefficients\n');
fprintf('%-10s %-15s %-18s %-15s\n', 'AOA(deg)', '2D Cd', '3D Cd_induced', '3D Cd_total');
fprintf('-----------------------------------------------------------------\n');
for i = 1:k
    fprintf('%-10.1f %-15.5f %-18.5f %-15.5f\n', AOA_deg(i), Cd_2D(i), CD_induced(i), CD_3D(i));
end

% --------------------- Plots ---------------------
figure;
plot(AOA_deg, Cl_2D, 'bo-', 'LineWidth', 1.6); hold on;
plot(AOA_deg, CL_3D_dynamic, 'r*-', 'LineWidth', 1.6);
grid on;
xlabel('Angle of Attack (deg)');
ylabel('Lift Coefficient (C_L)');
title('2D vs 3D Lift Curve (Clark Y trapezoid)');
legend('2D Cl', '3D CL', 'Location', 'NorthWest');

figure;
plot(AOA_deg, Cd_2D, 'go-', 'LineWidth', 1.6); hold on;
plot(AOA_deg, CD_3D, 'ms-', 'LineWidth', 1.6);
grid on;
xlabel('Angle of Attack (deg)');
ylabel('Drag Coefficient (C_D)');
title('2D vs 3D Drag Curve (Clark Y trapezoid)');
legend('2D Cd', '3D Cd total', 'Location', 'NorthWest');

end