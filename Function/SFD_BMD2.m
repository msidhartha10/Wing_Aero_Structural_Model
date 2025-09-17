function [R,Vi,M,P, root_shear, root_moment,P1,P2,W_points , W_dist]  = SFD_BMD2(g,m1,m2,pos1,pos2,y,b_half, L_sch)


%% SFD & BMD (half-wing cantilever at root) with point loads

% convert to Newtons (downward)
P1 = m1 * g; % N (downwards)
P2 = m2 * g; % N (downwards)

% --- Ensure positions lie within y range
pos1 = min(max(pos1, 0), b_half);
pos2 = min(max(pos2, 0), b_half);

% --- Total distributed lift on half-wing (upwards)
W_dist = trapz(y, L_sch);    % N (upwards, from Schrenk)

% Total point loads (downwards)
W_points = P1 + P2;          % N (downwards)

% Root shear reaction (positive upward)
R = W_dist - W_points;       % root reaction (N)

% Build cumulative distributed load integral at each y
W_cum_dist = cumtrapz(y, L_sch); % integral_0^y L_sch(s) ds

% Build cumulative point-load contribution at each y:
% for each station y(j) sum point loads located at s <= y(j)
point_cumulative = zeros(size(y));
for j = 1:length(y)
    s = y(j);
    sumP = 0;
    if pos1 <= s
        sumP = sumP + P1;
    end
    if pos2 <= s
        sumP = sumP + P2;
    end
    point_cumulative(j) = sumP;
end

% Shear V(y) = R - int_0^y L_sch ds - sum(P_i for s_i <= y)
Vi = R - W_cum_dist - point_cumulative;

% Bending moment: integrate shear from tip back to root
% We'll compute M(y) such that M(root) is maximum positive (cantilever)

M = flipud(cumtrapz(flipud(-y), flipud(Vi)));
% Optional: set reference so M(root) = value at y=0

% M(y) relative to root as we want to flip the intergration
P = M(end) - M;
%P = M;
% Numeric root values:
root_shear = Vi(1);      % should equal R
root_moment = M(end);    % moment at tip (should be ~0 if consistent)

end
