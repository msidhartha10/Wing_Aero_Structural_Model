# 📖 Detailed Explanation

This project is built as a modular MATLAB pipeline for finite wing aerodynamic and structural analysis.  
Below is a breakdown of what each part of the workflow does.

---

### **Overview**

This MATLAB script models the aerodynamics, loads, structural response, and performance of a finite wing based on 2D airfoil data. It pulls in airfoil coefficients, applies finite-wing corrections, estimates lift distributions, calculates shear/bending diagrams, deflections, and finally predicts aircraft range/endurance using Breguet equations.

The workflow is modular — each major step calls a custom function, which keeps the code organized.

---

### **Step-by-Step Breakdown**

#### **1. Inputs**

* **Atmospheric data:** air density, freestream velocity, viscosity, gravity.
* **Wing geometry:** root chord, tip chord, half-span.
* **Aerodynamic data:** imported from an Excel file with 2D coefficients (`Aero_Coeff_2D.xlsx`).
* **Angles of attack:** user sets a sweep (`-4° to 10°`) and picks a working AOA for analysis.
* **Discretization:** number of spanwise sections for lift/pressure distribution.

---

#### **2. Wing Parameter Calculation**

Function: `Wing_Parameter_Calculation`  
Computes key geometry and flow quantities:

* Span, area, aspect ratio, taper ratio.
* Mean aerodynamic chord (MAC).
* Reynolds number.
* Dynamic pressure.
* Oswald efficiency factor (e).

These parameters are the backbone for 3D lift/drag predictions.

---

#### **3. Aerodynamic Coefficients (3D corrections)**

Function: `aerodynamic_coeff`

* Converts 2D airfoil data into **finite wing CL and CD** using lifting-line theory and induced drag correction.
* Outputs:
  * 3D lift curve slope.
  * Zero-lift angle.
  * Drag polar with induced drag.
  * Lift-to-drag ratio across AOA sweep.

Plots show the aerodynamic behavior of the wing vs. angle of attack.

---

#### **4. Schrenk’s Lift Distribution**

Function: `schrenk_dist`

* Approximates spanwise lift distribution using Schrenk’s method (average of planform and elliptical distribution).
* Computes:
  * Chord distribution (planform, elliptical, Schrenk).
  * Spanwise lift per unit length for each case.

This is useful for preliminary load analysis when CFD or wind tunnel data isn’t available.

---

#### **5. Sectional Lift & Pressure**

Function: `sec_lift_pressure`

* Divides the span into discrete sections (trapezoidal strips).
* Calculates:
  * Section lift.
  * Pressure distribution along span.

Gives a breakdown of how lift is shared across the wing.

---

#### **6. Intra-section Pressure Distribution**

Function: `over_the_section`

* Zooms into each section’s surface.
* Estimates **spanwise + chordwise lift and pressure variation**.
* Helps visualize aerodynamic loading at a finer scale.

---

#### **7. Shear Force & Bending Moment (SFD & BMD)**

Functions: `SFD_BMD` / `SFD_BMD2`

* From lift distribution, computes:
  * Shear force diagram (SFD).
  * Bending moment diagram (BMD).
* Adds point loads (masses mounted along span).
* Outputs **root shear** and **root bending moment**, plus distributed vs. concentrated loads.

This bridges aerodynamics with structural loads.

---

#### **8. Wing Deflection**

Function: `Deflection`

* Uses bending moment distribution + material stiffness (E, I).
* Solves beam deflection along span.
* Outputs:
  * Deflection shape.
  * Tip deflection.
  * Slope (theta).

Lets you test materials (carbon fiber vs. foam) and see stiffness effects.

---

#### **9. Range & Endurance (Breguet)**

Function: `Range_Endurance`

* Applies **Breguet equations** for prop aircraft.
* Inputs:
  * Efficiency, SFC, L/D ratio, weights.
* Outputs:
  * Range.
  * Endurance.

Connects the wing-level aerodynamics back to whole-aircraft mission performance.

---

### **Outputs You Get**

* Tables of 3D lift/drag at different AOAs.
* Lift/pressure distribution across sections.
* SFD/BMD values + reaction loads.
* Maximum wing deflection.
* Propeller aircraft range & endurance.

And plenty of optional plots (commented in the script).

---

### **NOTE-**

This MATLAB project models the aerodynamic and structural behavior of a finite wing using classical methods. Starting from 2D airfoil data, it applies finite-wing corrections, estimates lift distributions (Schrenk’s method), calculates shear and bending diagrams, evaluates structural deflection, and predicts aircraft performance (range and endurance) using Breguet equations. The workflow is modular, with each step implemented as a separate function, making it easy to adapt for different wing geometries, materials, or flight conditions.

