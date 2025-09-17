function [R,Vi,M,P, root_shear, root_moment,P1,P2,W_points , W_dist] = ...
    SFD_BMD3(g,m1,m2,pos1,pos2,y,b_half,L_sch,c_sch,wing_mass)

%% --- Point loads (downward, Newtons)
P1 = m1 * g;
P2 = m2 * g;

pos1 = min(max(pos1, 0), b_half);
pos2 = min(max(pos2, 0), b_half);

%% --- Wing mass distribution (proportional to chord)
wing_mass_half = wing_mass/2;
mprime = wing_mass_half * c_sch ./ trapz(y, c_sch);   % kg/m
mprime = mprime(:);

%% --- Net distributed load (aero - structural weight) per unit span
q_actual = L_sch(:) - mprime*g;   % N/m, upward positive

%% --- Approximate load fit: q ≈ Kq * c_sch
Kq = trapz(y, q_actual) / trapz(y, c_sch);
q_approx = Kq * c_sch;

W_dist = trapz(y, q_approx);    % total distributed (upward)
W_points = P1 + P2;             % total point loads (downward)

%% --- Root reaction
R = W_dist - W_points;

%% --- Shear force distribution
W_cum = cumtrapz(y, q_approx);   % distributed load integral
point_cumulative = zeros(size(y));
for j = 1:length(y)
    s = y(j);
    sumP = 0;
    if pos1 <= s, sumP = sumP + P1; end
    if pos2 <= s, sumP = sumP + P2; end
    point_cumulative(j) = sumP;
end
Vi = R - W_cum - point_cumulative;

%% --- Bending moment (cantilever: M(root) = max, M(tip) ≈ 0)
M = flipud(cumtrapz(flipud(-y), flipud(-Vi)));

% Relative moment (set reference at tip so M(tip)=0)
P = M - M(end);

%% --- Outputs
root_shear = Vi(1);
root_moment = M(1);

end
