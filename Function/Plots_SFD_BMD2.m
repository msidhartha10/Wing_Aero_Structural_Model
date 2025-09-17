function  Plots_SFD_BMD2(y, L_sch,V,P, pos1 ,pos2)
% plot
figure('Name','Loads & Reactions with Point Loads','Units','normalized','Position',[0.1 0.1 0.6 0.6]);
subplot(3,1,1);
plot(y, L_sch, 'b','LineWidth',1.4); grid on;
ylabel('L''(y) (N/m)'); title('Schrenk distributed lift L''''(y)');
hold on;
% mark point load positions on the lift plot
plot(pos1, interp1(y, L_sch, pos1), 'ko', 'MarkerFaceColor','k');
plot(pos2, interp1(y, L_sch, pos2), 'ko', 'MarkerFaceColor','k');
hold off;

subplot(3,1,2);
plot(y, V, 'r','LineWidth',1.4); grid on;
ylabel('V(y) (N)'); title('Shear Force Diagram (half-wing)');
hold on;
% mark jumps in shear at point loads
plot(pos1, interp1(y, V, pos1), 'ks', 'MarkerFaceColor','y');
plot(pos2, interp1(y, V, pos2), 'ks', 'MarkerFaceColor','y');
hold off;

subplot(3,1,3);
plot(y, P, 'k','LineWidth',1.4); grid on;
xlabel('y (m)'); ylabel('M(y) (N-m)'); title('Bending Moment Diagram (half-wing)');

end