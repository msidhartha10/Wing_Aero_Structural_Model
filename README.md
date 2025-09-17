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

