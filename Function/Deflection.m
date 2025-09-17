function [tip_deflection,w_def,theta] = Deflection(y, P, E, I)

% ensure column vectors
y_vec = y(:);
M_vec = P(:);

% compute slope and deflection (cantilever, root at y=0 with w(0)=w'(0)=0)
theta = cumtrapz(y_vec, M_vec) / (E * I);      % slope (rad)
w_def = cumtrapz(y_vec, theta);                % deflection (m)

tip_deflection = w_def(end);                   % deflection at tip
max_deflection = min(w_def);                   % most negative (if sign is negative)

fprintf('Using E=%.3e Pa and I=%.3e m^4 -> Tip deflection = %.2f mm\n', E, I, tip_deflection*1000);

% plot
figure('Name','Slope & Deflection','Units','normalized','Position',[0.1 0.1 0.5 0.5]);
subplot(2,1,1); plot(y_vec*1000, theta,'LineWidth',1.4); grid on; ylabel('Slope (rad)'); title('Slope along span');
subplot(2,1,2); plot(y_vec*1000, w_def*1000,'LineWidth',1.4); grid on; xlabel('y (mm)'); ylabel('Deflection (mm)'); title('Deflection w(y)');

end