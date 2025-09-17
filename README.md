# Wing Aerodynamic & Structural Analysis

This MATLAB project provides a complete workflow to analyze the aerodynamics, spanwise loading, structural response, and performance of a finite wing.  
It integrates **airfoil aerodynamic data**, **finite wing corrections**, **Schrenk’s lift distribution**, **structural beam analysis**, and **Breguet range/endurance equations** into one modular package.

---

## ✈️ Features

- **Wing Parameter Calculation**
  - Span, area, taper ratio, aspect ratio, mean aerodynamic chord (MAC)
  - Reynolds number, dynamic pressure, Oswald efficiency factor

- **Finite Wing Aerodynamics**
  - Converts 2D aerodynamic coefficients into 3D coefficients
  - Computes lift coefficient (CL), drag coefficient (CD), and lift-to-drag ratio (L/D) across a range of angles of attack
  - Identifies zero-lift angle (αL0) and parasite drag coefficient (CD₀)
  - Generates aerodynamic plots (`CL vs AOA`, `CD vs AOA`, `L/D vs AOA`)

- **Lift Distribution (Schrenk’s Method)**
  - Computes spanwise lift distribution based on:
    - Planform geometry
    - Elliptical distribution
    - Schrenk’s approximation (average of both)
  - Optional plots showing chord and lift distributions

- **Sectional Lift & Pressure**
  - Divides half-span into trapezoidal sections
  - Calculates per-section:
    - average chord length
    - strip area
    - sectional lift per unit span (N/m)
    - total lift per section (N)
    - average pressure (Pa)
  - Plots:
    - spanwise lift distribution
    - spanwise sectional pressure distribution

- **Shear Force & Bending Moment**
  - Generates shear force diagram (SFD) and bending moment diagram (BMD)
  - Includes both distributed lift and optional point loads
  - Reports root shear force and root bending moment
  - Can plot shear and bending diagrams along the half-span

- **Deflection Analysis**
  - Computes wing bending deflection using Euler-Bernoulli beam theory
  - Allows material property selection (e.g., carbon fiber, foam)
  - Outputs deflection curve, slope distribution, and tip deflection

- **Breguet Range & Endurance**
  - Implements propeller-driven aircraft Breguet equations
  - Inputs: propulsive efficiency, SFC, fuel weight, payload, and empty weight
  - Outputs: endurance (seconds) and range (meters)

---

## 📂 Repository Structure

```

/Wing\_Aero\_Structural\_Model
│── main.m                     % Main driver script
│── Wing\_Parameter\_Calculation.m
│── aerodynamic\_coeff.m
│── schrenk\_dist.m
│── sec\_lift\_pressure.m         % Sectional lift & pressure + plots
│── over\_the\_section.m          % (optional chordwise breakdown)
│── SFD\_BMD.m / SFD\_BMD2.m
│── Deflection.m
│── Range\_Endurance.m
│── Plots\_Aero\_coeff.m
│── Aero\_Coeff\_2D.xlsx          % Input aerodynamic data
│── README.md

````

---

## 🚀 How to Use

1. Clone the repository:
   ```bash
   git clone https://github.com/<your-username>/Wing_Aero_Structural_Model.git
   cd Wing_Aero_Structural_Model


2. Open MATLAB and ensure this folder is added to your MATLAB path.

3. Run the main script:

   ```matlab
   main
   ```

4. Review outputs:

   * Tables printed in the MATLAB console (3D CL, CD, sectional lift/pressure, shear/moment reactions, deflections)
   * Plots showing aerodynamic coefficients, spanwise lift distribution, sectional pressure, and structural responses
   * Range & endurance estimates in console

---

## 📊 Inputs & Outputs

### Inputs

* Atmospheric conditions (density, velocity, viscosity, gravity)
* Wing geometry (root chord, tip chord, half-span)
* Airfoil data (from `Aero_Coeff_2D.xlsx`)
* Discretization (number of spanwise sections)
* Material properties (E, I for deflection analysis)
* Aircraft weights (empty, payload, fuel)
* Propulsive efficiency & SFC

### Outputs

* Aerodynamic performance curves (CL, CD, L/D vs AOA)
* Section-wise lift/pressure distribution (tables + plots)
* Shear force and bending moment diagrams
* Tip deflection and deflection curve
* Estimated endurance and range (Breguet equations)

---

## 📊 Example Plots

* 3D CL vs AOA with finite wing corrections
* Spanwise Lift Distribution (planform, elliptical, Schrenk)
* Spanwise Section Pressure Distribution
* Shear Force & Bending Moment Diagrams
* Wing Deflection Curve

---

## ⚙️ Requirements

* MATLAB R2021a or later (older versions may still work)
* `Aero_Coeff_2D.xlsx` with 2D airfoil aerodynamic coefficients

---

## 📝 Notes

* This tool is designed for **preliminary wing analysis** using analytical and semi-empirical methods.
* Results are approximations and should not replace **CFD simulations or experimental validation**.
* The modular function structure makes it easy to adapt for different geometries, airfoils, or materials.

---

## 📌 License

This project is licensed under **Zmotion Autonomous System (ZAS)**.
All rights reserved. Unauthorized copying or redistribution is prohibited without prior permission from ZAS.


