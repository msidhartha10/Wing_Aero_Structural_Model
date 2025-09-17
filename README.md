# Wing Aero-Structural Model (MATLAB)

A modular MATLAB pipeline for aerodynamic and structural analysis of a finite wing using classical methods. Starting from 2D airfoil data, it applies finite-wing corrections, estimates spanwise loading, computes shear/bending, predicts deflection, and ties results to mission performance via Breguet range/endurance (prop aircraft).

If you are new to the repo, start with Quick Start below.

---

## Quick Start

### Requirements
- MATLAB R2020b or newer (Base MATLAB is sufficient; no toolboxes expected)
- OS: Windows/macOS/Linux

### Clone and set up
1. Clone the repository and open it in MATLAB.
2. Ensure the 2D airfoil data Excel file `Function/Aero_Coeff_2D.xlsx` is present (or update the path in your script as needed).
   - Expected columns (typical): `alpha_deg`, `CL_2D`, `CD_2D`, optionally `CM_2D`.
   - Alpha is in degrees; coefficients are dimensionless.
3. Open `Function/Main_Code.m` and review the user input section at the top (atmosphere, geometry, AOA sweep, discretization, materials, etc.). Adjust values to your case.

### Run
- Press Run on `Function/Main_Code.m`. The script will:
  - Compute wing parameters
  - Convert 2D polars to 3D (finite-wing) aerodynamics
  - Estimate spanwise lift with Schrenk's method
  - Integrate sectional lift/pressure
  - Build SFD/BMD
  - Compute deflection
  - Estimate range and endurance

### Typical outputs
- CL/CD and L/D across angle of attack (AOA)
- Spanwise lift and pressure distributions
- Shear Force Diagram (SFD) and Bending Moment Diagram (BMD)
- Deflected shape, tip deflection, slope
- Breguet range and endurance

For a deeper narrative, see [Function/Function_Explanation.md](Function/Function_Explanation.md).

---

## Repository Structure

```
/Wing_Aero_Structural_Model
│── Function/
│   │── Main_Code.m                    % Main driver script
│   │── Wing_Parameter_Calculation.m
│   │── aerodynamic_coeff.m
│   │── schrenk_dist.m
│   │── sec_lift_pressure.m
│   │── over_the_section.m
│   │── SFD_BMD.m (and/or SFD_BMD2.m)
│   │── Deflection.m
│   │── Range_Endurance.m
│   │── Plots_Aero_coeff.m
│   │── Aero_Coeff_2D.xlsx            % Input data
│   │── Function_Explanation.md       % Detailed documentation
│── LICENSE
│── README.md  ← you are here
```

---

## Function I/O (Essentials)

Units convention
- Length: meters (m)
- Mass: kilograms (kg)
- Force/weight: newtons (N)
- Velocity: m/s
- Density: kg/m³
- Angle: degrees unless noted

| Function | Purpose | Key inputs (units) | Key outputs (units) |
|---|---|---|---|
| `Wing_Parameter_Calculation` | Compute geometry and flow parameters | ρ [kg/m³], V∞ [m/s], μ [Pa·s], g [m/s²], c_root [m], c_tip [m], b_half [m] | Span b [m], Area S [m²], AR [-], taper λ [-], MAC [m], Re [-], q∞ [Pa], Oswald e [-] |
| `aerodynamic_coeff` | Convert 2D polars to finite-wing CL/CD; build drag polar | 2D CL(α), CD(α) from Excel, AR [-], e [-], α_sweep [deg] | a_3D [1/rad], α_0L [deg], CL_3D(α), CD(α) incl. induced, L/D(α) |
| `schrenk_dist` | Approximate spanwise lift using Schrenk's method | Planform (c(y)), total CL, span b | Chord distributions (planform/elliptical/Schrenk), q_lift(y) [N/m] |
| `sec_lift_pressure` | Discretize span and compute sectional lift/pressure | N_sections [-], q∞ [Pa], c(y), CL or q_lift(y) | Section lift L_i [N], pressure p_i [Pa], y stations [m] |
| `over_the_section` | Intra-section chordwise/spanwise pressure variation | Section geometry, local α, q∞ | p(x,y) distribution (normalized or absolute), sectional L/D |
| `SFD_BMD` / `SFD_BMD2` | Shear and bending from distributed + point loads | q_lift(y) [N/m], point loads (N) at y [m], supports | SFD V(y) [N], BMD M(y) [N·m], root shear, root moment |
| `Deflection` | Beam deflection under bending | M(y) [N·m], E [Pa], I(y) [m⁴], boundary conditions | Deflection w(y) [m], slope θ(y) [rad], tip deflection |
| `Range_Endurance` | Breguet range and endurance (prop) | η_p [-], SFC c [1/s or 1/hr], L/D [-], W_i/W_f [-] (initial/final weights) | Range R [m or km], Endurance E [s or hr] |
| `Plots_Aero_coeff` | Optional helper for plotting | Data structs from aerodynamics | Figures: CL–α, CD–CL, L/D–α |

Notes
- Some functions accept structs (e.g., `params`, `aero`, `loads`) depending on your implementation style.
- If using `SFD_BMD2`, it typically differs by load cases or boundary conditions; choose the one matching your setup.

---

## Key Equations

**Finite-wing lift-curve slope** (lifting-line correction)

- Convert 2D slope to 3D (for unswept, low-Mach wings):
  $$ a_{3D} = \frac{a_{2D}}{1 + \dfrac{a_{2D}}{\pi e\, AR}} $$

**Induced drag** (drag polar contribution)

- Induced drag coefficient:
  $$ C_{D,i} = \frac{C_L^2}{\pi e\, AR} $$
- Total drag (example quadratic polar):
  $$ C_D \approx C_{D0} + k C_L^2,\quad k = \frac{1}{\pi e\, AR} $$

**Schrenk's method** (spanwise lift)

- Average of planform and elliptical distributions to approximate lift per unit span q_lift(y):
  $$ q_{\text{Schrenk}}(y) \approx \tfrac{1}{2}\left[q_{\text{planform}}(y) + q_{\text{elliptic}}(y)\right] $$

**SFD/BMD** (Euler–Bernoulli beam assumptions)

- Relations:
  $$ \frac{dV}{dy} = -w(y), \quad \frac{dM}{dy} = V(y) $$

**Deflection** (small deflection, linear elastic)

- Governing equation with known bending moment distribution:
  $$ E I(y)\, \frac{d^2 w}{dy^2} = M(y) $$

**Breguet** (propeller aircraft)

- Endurance:
  $$ E = \frac{\eta_p}{c}\, \ln\!\left(\frac{W_i}{W_f}\right) $$
- Range (common form for prop):
  $$ R = \frac{\eta_p}{c}\, \left(\frac{L}{D}\right) \ln\!\left(\frac{W_i}{W_f}\right) $$

Where
- AR: aspect ratio, e: Oswald efficiency factor, η_p: propulsive efficiency, c: specific fuel consumption (1/time), W_i/W_f: initial/final weights.

---

## Assumptions and Limitations
- Incompressible or low-subsonic flow (no explicit compressibility corrections)
- Unswept, untwisted tapered wing (geometric twist and sweep not modeled unless added by user)
- Linear CL–α range (stall behavior not modeled)
- Quasi-steady aerodynamics; no unsteady or dynamic effects
- Structural model: Euler–Bernoulli beam in bending only (no torsion/aeroelastic coupling)
- Point loads modeled as concentrated forces along span where specified

---

## Validation (suggested)
- Compare 3D CL–α and CD with a reference tool (AVL, XFOIL + LLT) for a simple taper wing
- Check root bending moment vs. hand integration of q_lift(y)
- Compare tip deflection to closed-form for uniform load and constant EI as a sanity check

---

## References
- Anderson, J. D. "Fundamentals of Aerodynamics," McGraw-Hill.
- Raymer, D. P. "Aircraft Design: A Conceptual Approach," AIAA.
- Etkin, B. "Dynamics of Flight," Wiley.
- McCormick, B. W. "Aerodynamics, Aeronautics, and Flight Mechanics," Wiley.

---

## How to cite / license
This project is licensed under the [MIT License](LICENSE). 
If you use this code or results in reports, please cite this repository.