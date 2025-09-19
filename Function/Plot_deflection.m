function Plot_deflection(y, M,P,theta, w_def)

% Plot results
figure('Name','Deflection','Units','normalized','Position',[0.1 0.1 0.5 0.5]);
subplot(3,1,1); plot(y, P,'LineWidth',1.4); grid on;
ylabel('M (N·m)'); title('Bending Moment');
subplot(3,1,2); plot(y, theta,'LineWidth',1.4); grid on;
ylabel('Slope (rad)'); title('Slope along span');
subplot(3,1,3); plot(y, w_def*1000,'LineWidth',1.4); grid on;
xlabel('y (m)'); ylabel('Deflection (mm)'); title('Deflection');

end