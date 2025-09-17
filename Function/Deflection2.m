function [tip_deflection,w_def,theta] = Deflection2(n_sections,c_sch, y, P, E, I)
c_sch_vec = c_sch(:);
EI0 = E* I * (c_sch_vec./c_sch_vec(1)).^4;

theta = zeros(n_sections,1);
w_def = zeros(n_sections,1);

% ensure column vectors
y_vec = y(:);
M_vec = P(:);

for i =1 :n_sections-1
    dye = y(i+1)-y(i);
    theta(i+1) = theta(i) + 0.5*(M_vec(i+1)./EI0(i+1)+ M_vec(i)./EI0(i))*dye;
    w_def(i+1) = w_def(i) + 0.5* (theta(i+1)+theta(i)) * dye;
end    

theta = theta(:);
w_def = w_def(:);

tip_deflection = w_def(end);                   % deflection at tip

fprintf('Using E=%.3e Pa and I=%.3e m^4 -> Tip deflection = %.2e mm\n', E, I, tip_deflection*1000);

% % plot
% figure('Name','Slope & Deflection','Units','normalized','Position',[0.1 0.1 0.5 0.5]);
% subplot(2,1,1); plot(y_vec*1000, theta,'LineWidth',1.4); grid on; ylabel('Slope (rad)'); title('Slope along span');
% subplot(2,1,2); plot(y_vec*1000, w_def*1000,'LineWidth',1.4); grid on; xlabel('y (mm)'); ylabel('Deflection (mm)'); title('Deflection w(y)');

end