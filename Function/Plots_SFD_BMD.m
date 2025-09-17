function  Plots_SFD_BMD(y, L_sch,V,P)
% Plots
figure('Name','Loads & Reactions','Units','normalized','Position',[0.1 0.1 0.6 0.6]);
subplot(3,1,1);
plot(y, L_sch, 'b','LineWidth',1.4); grid on;
ylabel('L''(y) (N/m)'); title('Schrenk distributed lift L''''(y)');

subplot(3,1,2);
plot(y, V, 'r','LineWidth',1.4); grid on;
ylabel('V(y) (N)'); title('Shear Force Diagram (half-wing)');

subplot(3,1,3);
plot(y, P, 'k','LineWidth',1.4); grid on;
xlabel('y (m)'); ylabel('M(y) (N-m)'); title('Bending Moment Diagram (half-wing)');
%ylim([1.1*min(M),0]);

end