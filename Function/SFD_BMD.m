function [R,V,M,P, root_shear, root_moment] = SFD_BMD(y, L_sch)

%% SFD & BMD (half-wing cantilever at root)
R = trapz(y, L_sch);              % reaction at root (half-wing lift)
V = (R - cumtrapz(y, L_sch));      % V(y) = R - integral_0^y w(s) ds

%M = zeros(size(y));
M =(flipud(cumtrapz(flipud(-y), flipud(V))));
P = M(end)- M;

% Numeric root values:
root_shear = V(1);      % should equal R
root_moment = M(end);



end
