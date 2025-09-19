
# Wing Aero-Structural Model (MATLAB)

A modular MATLAB pipeline for **aerodynamic and structural analysis of finite wings** using classical methods.
Starting from 2D airfoil data, the model applies finite-wing corrections, estimates spanwise loading, computes shear and bending, predicts deflection, compares with FEA results from Static Structural (ANSYS), and links results to mission performance via the Breguet range and endurance (propeller aircraft).

If you are new, begin with the **Quick Start** section.

---

## Quick Start

### Requirements

* MATLAB R2020b or newer (Base MATLAB is sufficient; no toolboxes required)
* Works on Windows, macOS, or Linux

### Setup

1. Clone the repository and open it in MATLAB.
2. Ensure the input Excel file `Function/Aero_Coeff_2D.xlsx` is available (or update the path).

   * Columns expected: `alpha_deg`, `CL_2D`, `CD_2D` (optional `CM_2D`)
   * Angles in degrees; coefficients dimensionless
3. Open `Function/Main_Code.m` and adjust the **User Input** block (atmosphere, geometry, AoA sweep, discretization, materials, etc.) to your case.

### Run

Execute `Function/Main_Code_v2.m`. The script will:

* Compute wing parameters
* Convert 2D → 3D aerodynamics
* Estimate spanwise lift with Schrenk’s method
* Integrate sectional lift and pressure
* Build shear force and bending moment diagrams (SFD/BMD) with optional point loads
* Compute deflection under bending
* *(Optional)* Estimate range and endurance

You can control behavior with script flags:

* `SAVE_DATA` → save results to `.mat`
* `VERBOSE` → print detailed logs
* `PLOTS` → show figures
* `USE_CLCD_OVERRIDE` → replace CL/CD with CFD or test values

---

## Outputs

* 3D finite wing CL, CD and L/D vs angle of attack
* Spanwise lift and sectional pressure distributions
* SFD and BMD diagrams
* Deflected shape, tip deflection, and slope
* Optional Breguet range and endurance

---

## Sample Plots

### Aerodynamic Results

<img src="img/Cl  3d 16.png" alt="Lift Curve" width="400"/>
<img src="img/cd 3d 16.png" alt="Drag Curve" width="400"/>

### Spanwise Distributions

<img src="img/schrenk lift dist.png" alt="Spanwise Lift" width="500"/>
<img src="img/schrenk lift dist sectional.png" alt="Lift Distribution Sectional" width="500"/>

### Structural Analysis

<img src="img/def.png" alt="Deflection" width="500"/>
<img src="img/SFD & BMD Diagram with point loads.jpg" alt="SFD BMD Point Loads" width="500"/>

For more details, see [Function/Function\_Explanation.md](Function/Function_Explanation.md).

---

## Repository Structure

```
Function/
│── Main_Code_v2.m                 % Main sequential driver script
│
│── Wing_Parameter_Calculation.m
│── aerodynamic_coeff.m
│── schrenk_dist.m
│── sec_lift_pressure.m
│── over_the_section.m
│── SFD_BMD3.m                  % Extended SFD/BMD with point loads
│── Deflection.m
│── Range_Endurance.m
│
│── Plots_Aero_coeff.m
│── Plots_Lift_Distribution.m
│── Plot_Sec_lift_press.m
│── Plots_SFD_BMD2.m
│── Plot_deflection.m
│
│── Aero_Coeff_2D.xlsx          % Input airfoil polar data
│── Function_Explanation.md     % Extended documentation

```

---

## Function Overview (Detailed)

**Units convention**

* Length: meters (m)
* Mass: kilograms (kg)
* Force/Weight: newtons (N)
* Velocity: m/s
* Density: kg/m³
* Angle: degrees (unless otherwise noted)

| Function                            | Purpose / Description                                    | Key Inputs (units)                                                                     | Key Outputs (units)                                                                                                                             |
| ----------------------------------- | -------------------------------------------------------- | -------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `Wing_Parameter_Calculation`        | Compute geometry and flow parameters                     | ρ \[kg/m³], V∞ \[m/s], μ \[Pa·s], g \[m/s²], c\_root \[m], c\_tip \[m], b\_half \[m]   | Span b \[m], Wing area S \[m²], Aspect ratio AR \[-], Taper λ \[-], MAC \[m], Reynolds Re \[-], Dynamic pressure q∞ \[Pa], Oswald factor e \[-] |
| `aerodynamic_coeff`                 | Convert 2D polars → finite-wing aerodynamics, drag polar | CL₂D(α), CD₂D(α) (from Excel), AR \[-], e \[-], α\_sweep \[deg]                        | 3D lift slope a₃ᴰ \[1/rad], Zero-lift α₀L \[deg], CL₃ᴰ(α), CD(α), L/D(α)                                                                        |
| `schrenk_dist`                      | Approximate spanwise lift using Schrenk’s method         | Planform chord c(y), total CL, span b \[m]                                             | Chord distributions (planform, elliptical, Schrenk), q\_lift(y) \[N/m]                                                                          |
| `sec_lift_pressure`                 | Discretize span and compute sectional lift/pressure      | N\_sections \[-], q∞ \[Pa], c(y) \[m], CL(y) or q\_lift(y) \[N/m]                      | Section lift Lᵢ \[N], sectional pressure pᵢ \[Pa], y-stations \[m]                                                                              |
| `over_the_section`                  | Pressure distribution along chord/section                | Section geometry, local α \[deg], q∞ \[Pa]                                             | p(x,y) distribution, sectional L/D                                                                                                              |
| `SFD_BMD` / `SFD_BMD2` / `SFD_BMD3` | Shear force and bending moment analysis                  | Distributed lift q\_lift(y) \[N/m], point loads (N) at y \[m], support locations       | Shear force V(y) \[N], Bending moment M(y) \[N·m], root shear \[N], root moment \[N·m]                                                          |
| `Deflection`                        | Beam deflection under bending (Euler–Bernoulli)          | M(y) \[N·m], Elastic modulus E \[Pa], Moment of inertia I(y) \[m⁴]                     | Deflection w(y) \[m], slope θ(y) \[rad], tip deflection \[m]                                                                                    |
| `Range_Endurance`                   | Breguet endurance and range (prop aircraft)              | ηₚ \[-], Specific fuel consumption c \[1/s or 1/hr], L/D \[-], Weight ratio Wᵢ/Wf \[-] | Endurance E \[s or hr], Range R \[m or km]                                                                                                      |
| `Plots_Aero_coeff`                  | Helper for visualizing aerodynamic performance           | Data structures from `aerodynamic_coeff`                                               | Figures: CL–α, CD–CL, L/D–α curves                                                                                                              |

---

The function [`sec_lift_pressure.m`](Function/sec_lift_pressure.m) generates spanwise sectional lift and pressure distributions, producing both numerical tables and plots. These can be used directly in Static Structural to compare analytical deflection with beam theory or FEA results.

---

## Key Equations

**Finite-wing lift slope**
\$a\_{3D} = \dfrac{a\_{2D}}{1 + \tfrac{a\_{2D}}{\pi e, AR}}\$

**Induced drag**
\$C\_{D,i} = \dfrac{C\_L^2}{\pi e, AR}\$

**Total drag polar**
\$C\_D \approx C\_{D0} + \dfrac{1}{\pi e AR} C\_L^2\$

**Schrenk’s method**
\$q\_{\text{Schrenk}}(y) \approx \tfrac{1}{2}\[q\_{\text{planform}}(y) + q\_{\text{elliptic}}(y)]\$

**Shear and bending (Euler–Bernoulli)**
\$\dfrac{dV}{dy} = -w(y), \quad \dfrac{dM}{dy} = V(y)\$

**Deflection**
\$E I(y), \dfrac{d^2 w}{dy^2} = M(y)\$

**Breguet (prop aircraft)**

* Endurance:
  \$E = \dfrac{\eta\_p}{c}, \ln!\left(\dfrac{W\_i}{W\_f}\right)\$
* Range:
  \$R = \dfrac{\eta\_p}{c}, \dfrac{L}{D}, \ln!\left(\dfrac{W\_i}{W\_f}\right)\$

---

## Assumptions & Limitations

* Incompressible, low-subsonic flow (no compressibility effects)
* Unswept, untwisted, tapered wings
* Linear CL–α region (no stall modeling)
* Quasi-steady aerodynamics only
* Structures: Euler–Bernoulli beam (bending only; no torsion or aeroelasticity)
* Point loads treated as concentrated forces

---

## Validation

* Compare CL–α and CD with AVL/XFOIL + lifting-line theory or [Airfoil Tools](http://airfoiltools.com/search/index)
* Cross-check root bending moment with spanwise integration of q(y)
* Verify tip deflection with closed-form beam theory or compare with FEA (ANSYS Static Structural)

---

## References

* Anderson, J. D. *Fundamentals of Aerodynamics*, McGraw-Hill
* Raymer, D. P. *Aircraft Design: A Conceptual Approach*, AIAA
* Etkin, B. *Dynamics of Flight*, Wiley
* McCormick, B. W. *Aerodynamics, Aeronautics, and Flight Mechanics*, Wiley

---

## Notes

* This tool is designed for **preliminary wing analysis** using analytical and semi-empirical methods.
* Results are approximations and should not replace **CFD simulations or experimental validation**.
* The modular function structure makes it easy to adapt for different geometries, airfoils, or materials.

---

## License & Citation

*This project is licensed under **Zmotion Autonomous System (ZAS)**.*
All rights reserved. Unauthorized copying or redistribution is prohibited without prior permission from ZAS.

---

