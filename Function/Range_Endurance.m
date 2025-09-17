function [L_D_3_2,W_i, W_f,R_prop,E_prop] = Range_Endurance(rho, S, g, V, W_fuel,CD0, W_empty,W_payload,k,Cl, Cd, L_D,eta_p, c_per_hr, c_per_sec)

            
W_i = (W_empty + W_fuel+ W_payload) * g;   % initial weight [N]
W_f = W_empty * g;                 % final weight (all fuel burned) [N]              
%L_D_3_2 = (Cl ^ (3/2)/ Cd);
L_D_3_2 = 0.25* (3/(k*CD0^(1/3)))^(3/4);
% Compute propeller Breguet
    if c_per_sec <= 0
        error('c_persec must be > 0');
    end  
R_prop = (eta_p * L_D / c_per_sec) * log(W_i / W_f); % meters
E_prop = (eta_p * L_D_3_2  / c_per_sec) *sqrt(2*rho*S) *((sqrt(W_i)-sqrt(W_f))^-1); % Endurance in seconds
%E_prop = R_prop / V;  % Endurance in seconds

fprintf(' \n  Initial weight Wi = %.2f N, final Wf = %.2f N \n', W_i, W_f);
fprintf('  Using L/D = %.2f, eta = %.2f, c = %.6f 1/s (%.2f 1/hr)\n', ...
        L_D, eta_p, c_per_sec, c_per_hr);
fprintf('  Range = %.1f km, Endurance = %.1f hr \n\n', R_prop/1000,  E_prop/3600);

end