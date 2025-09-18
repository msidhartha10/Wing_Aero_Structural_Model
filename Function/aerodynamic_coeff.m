function results = aerodynamic_coeff(AeroData,desired_angles,b_half, Tc, Rc,e )
% ------------------ INPUT DATA (unchanged) ------------------
%AeroData = readtable('Aero_Coeff_2D.xlsx');

AeroData.Properties.VariableNames = {'Alpha','Cl', 'Cd'};

b = 2*b_half ;  % Full - Span (in m) 
%b = b_half ;  % Half - Span (in m)
%S = b*(Tc+Rc)/2; % Span Area (in m^2)
S = b * MAC; 
AR = b^2/S;

%rows_to_use = (T.Alpha>-5) & (T.Alpha<10);
% or
rows_to_use = ismember(AeroData.Alpha, desired_angles);

AOA_deg = AeroData.Alpha(rows_to_use);
Cl_2D   = AeroData.Cl(rows_to_use);
Cd_2D   = AeroData.Cd(rows_to_use);

AOA_rad = deg2rad(AOA_deg);

% ------------------ PREALLOCATE ------------------
k = length(AOA_rad);
Cl_alpha_2D_dynamic = zeros(size(AOA_rad));
CL_alpha_dynamic = zeros(size(AOA_rad));
CL_3D_dynamic = zeros(size(AOA_rad));
CD_induced = zeros(size(AOA_rad));
CD_3D = zeros(size(AOA_rad));

smooth_param = 0.9; % smoothing spline parameter

% ------------------ Estimate zero-lift angle (alpha_L0) from 2D data ------------------
% linear interp of Cl_2D vs AOA_rad to find AOA where Cl = 0
% (assumes Cl_2D crosses zero in the sample range)

alpha_L0 = interp1(Cl_2D, AOA_rad, 0, 'spline'); 
% returns NaN if outside range

if isnan(alpha_L0)
    % fallback: use spline root-search (rough)
    ppCl = csaps(AOA_rad, Cl_2D, smooth_param);
    % find sign-change interval
    idx = find(Cl_2D(1:end-1).*Cl_2D(2:end) < 0, 1, 'first');
    if ~isempty(idx)
        aL_low = AOA_rad(idx); aL_high = AOA_rad(idx+1);
        alpha_L0 = fzero(@(a) fnval(ppCl, a), mean([aL_low,aL_high]));
    else
        alpha_L0 = 0; % if all else fails
    end
end
%fprintf('Zero-lift angle (alpha_L0) = %.4f rad (%.3f deg)\n\n', alpha_L0, rad2deg(alpha_L0));

% ------------------ DYNAMIC 2D SLOPE ESTIMATION & 3D SLOPE ------------------
for i = 2:k
    current_AOA_range = AOA_rad(1:i);
    current_Cl_range = Cl_2D(1:i);

    % Cubic smoothing spline fit for Cl vs alpha and derivative at mean of range
    pp_spline = csaps(current_AOA_range, current_Cl_range, smooth_param);
    pp_spline_derivative = fnder(pp_spline, 1);

    mean_AOA_rad = mean(current_AOA_range);
    Cl_alpha_2D_dynamic(i) = fnval(pp_spline_derivative, mean_AOA_rad); % dCl/dalpha (1/rad)

    % 3D slope from lifting-line correction
    CL_alpha_dynamic(i) = Cl_alpha_2D_dynamic(i) / (1 + (Cl_alpha_2D_dynamic(i) / (pi * e * AR)));
    
    % 3D CL at actual AOA using zero-lift shift
    CL_3D_dynamic(i) = CL_alpha_dynamic(i) * (AOA_rad(i) - alpha_L0);
end

% set first entries to zero (no data)
Cl_alpha_2D_dynamic(1) = Cl_alpha_2D_dynamic(2); % or 0 if you prefer
CL_alpha_dynamic(1) = CL_alpha_dynamic(2);
CL_3D_dynamic(1) = CL_alpha_dynamic(1) * (AOA_rad(1) - alpha_L0);

% ------------------ CD0 estimation (interpolate Cd at 0 deg from 2D data) ------------------
Cd0_2D_at_0deg = interp1(AOA_deg, Cd_2D, 0, 'pchip'); % pchip gives smooth monotonic interp
if isempty(Cd0_2D_at_0deg) || isnan(Cd0_2D_at_0deg)
    Cd0_2D_at_0deg = min(Cd_2D); % fallback
end

% ------------------ 3D Drag calculation ------------------
for i = 1:k
    CD_induced(i) = (CL_3D_dynamic(i)^2) / (pi * AR * e);
    CD_3D(i) = Cd0_2D_at_0deg + CD_induced(i);  % simple sum: profile Cd0 + induced
end

  
   % Results
  results.AOA_deg              = AOA_deg;
  results.Cl_2D                = Cl_2D ;
  results.Cd_2D                = Cd_2D ;
  
  results.alpha_L0             = alpha_L0;
  results.Cl_alpha_2D_dynamic  = Cl_alpha_2D_dynamic;
  results.CL_alpha_dynamic     = CL_alpha_dynamic;
  
  results.CL_3D_dynamic        = CL_3D_dynamic;
  
  results.Cd0_2D_at_0deg       = Cd0_2D_at_0deg ;
  results.CD_induced           = CD_induced;
  results.CD_3D                = CD_3D ;
  

end


