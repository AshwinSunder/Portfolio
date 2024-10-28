# Shreyas Ashwin Sunder's Portfolio

![GitHub followers](https://img.shields.io/github/followers/AshwinSunder?label=Follow&style=social)
![GitHub stars](https://img.shields.io/github/stars/AshwinSunder/Portfolio?style=social)
![License](https://img.shields.io/github/license/AshwinSunder/Portfolio)

Welcome to my GitHub portfolio! I'm Shreyas Ashwin Sunder, a recent graduate in Aerospace Engineering from FH Aachen, with a strong focus on **aerodynamic modelling, CFD analysis, and partitioned simulations**. I am proficient in **Python**, **MATLAB**, **C/C++**, and **Linux-based systems**, with experience in **Star-CCM+**, **ANSYS Fluent**, **CATIA**, **SolidWorks**. This portfolio showcases key projects from my academic and professional journey in aerospace engineering, focusing on aerodynamic simulations, CFD analysis, and structural modeling. I am actively seeking roles that allow me to leverage my technical skills to solve complex engineering challenges.

## About Me
I have a background in aerospace engineering, where I have developed expertise in simulation methods and tools, such as aerodynamic modeling, structural analysis, and Git-based workflows. This repository showcases projects that reflect my technical skills and engineering knowledge.

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![MATLAB](https://img.shields.io/badge/MATLAB-0076A8?style=for-the-badge&logo=mathworks&logoColor=white)
![C](https://img.shields.io/badge/C-A8B9CC?style=for-the-badge&logo=c&logoColor=white)
![C++](https://img.shields.io/badge/C++-00599C?style=for-the-badge&logo=cplusplus&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Star-CCM+](https://img.shields.io/badge/Star--CCM%2B-FF9900?style=for-the-badge&logo=sun&logoColor=white)
![ANSYS Fluent](https://img.shields.io/badge/ANSYS%20Fluent-FF9D00?style=for-the-badge&logo=ansys&logoColor=white)
![SolidWorks](https://img.shields.io/badge/SolidWorks-D61F06?style=for-the-badge&logo=dassaultsystemes&logoColor=white)
![CATIA](https://img.shields.io/badge/CATIA-4B92E0?style=for-the-badge&logo=dassaultsystemes&logoColor=white)
![MS Office](https://img.shields.io/badge/MS%20Office-D83B01?style=for-the-badge&logo=microsoftoffice&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-003B57?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)

---

## Table of Contents
- [About Me](#about-me)
- [Projects](#projects)
- [Additional Projects](#additional-projects)
  - [CFD Report of NASA N2A Hybrid Wing-Body](#cfd-report-of-a-subsonic-study-of-the-nasa-n2a-hybrid-wing-body-using-star-ccm)
  - [Axial Turbine Stage Meanline Calculations](#1-d-meanline-design-point-calculation-and-loss-calculation-for-an-axial-turbine-stage)
  - [Transply Effusion Cooling System](#matrix-fin-based-transply-effusion-cooling-system-bachelor-thesis)
- [Technical Skills](#technical-skills)
- [Contact](#contact)

---

## Projects

### Structural/Motion Solver in MATLAB
[View Code and Documentation](./projects/motion_solver)
_Main Files:_ `/code` for source code, `/docs` for report and documentation.
- **Description**: A custom structural/motion solver built using MATLAB to simulate and analyze complex wing motions, combined with an adapter coded in Python used to couple the solver with an external fluid solver. This project includes a parent-child frame hierarchy and simple and complex motion assignment for calculating positions and velocities efficiently.
- **Skills Used**: MATLAB, Python, structural dynamics, computational mathematics, multi-body dynamics, software development, simulation modelling.

<p align="center">
  <img src="https://github.com/user-attachments/assets/befcfc04-ad23-4300-b0ab-088ba7fea287" alt="Structural/Motion Solver in MATLAB Screenshot" width="600"/>
</p>
<p align="center"><i>Figure 1: Structural/Motion Solver in MATLAB</i></p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/250326a7-66fd-4194-a8bd-c7b47b7a9fa8" alt="Wing Mode Shapes Developed using MATLAB Solver Screenshot" width="600"/>
</p>
<p align="center"><i>Figure 2: Wing Mode Shapes Developed using MATLAB Solver</i></p>

### Aerodynamic Investigation of Propeller-Wing Interaction for Simple Motions and Complex Modes (Master Thesis)
[View Code and Documentation](./projects/master_thesis)
_Main Files:_ `/code` for source code, `/docs` for report and documentation.
- **Description**: Aerodynamic simulations performed using DUST, a potential flow-based aerodynamic solver on wing-propeller models undergoing simple wing modes such as pitch and plunge, and complex modes such as wing mode shapes. This project includes detailed analyses of lift and moment coefficient and phase calculations and interpretations of the aerodynamic forces on wing structures, FFT analysis of time-varying forces, eigenvalue/eigenvector calculations, and more.
- **Summary**: Using a custom FMI solver coupled with DUST, this study examines how motion affects aerodynamic performance, revealing factors that maximize lift and efficiency.
- **Skills Used**: Potential flow theory, aerodynamic load calculations, MATLAB, signal processing, eigenmode analysis
- **Highlights**: Includes analysis of integral loads, lift and moment forces, visualizations of wing motion, FFT analysis of force data, and complex mode interpretation.

<p align="center">
  <img src="https://github.com/user-attachments/assets/e2186d6c-5843-4981-9ec8-77d449056413" alt="Partitioned FSI/FMI Workflow Screenshot" width="600"/>
</p>
<p align="center"><i>Figure 3: Partitioned FSI/FMI Workflow</i></p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/f98ad684-b1ae-4874-93c0-1d9e2de9bef5" alt="Sample DUST Simulation Visualization Screenshot" width="600"/>
</p>
<p align="center"><i>Figure 4: Sample DUST Simulation Visualization</i></p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/8706ac68-08e1-4a8f-9486-8a9dd1db333f" alt="Sample DUST Simulation Processed Output Screenshot" width="600"/>
</p>
<p align="center"><i>Figure 5: Sample DUST Simulation Processed Output</i></p>

---

## Additional Projects
Here are some additional projects I worked on during my bachelor’s and master’s courses, each contributing to my skills in engineering, data analysis, and programming.

### CFD Report of a Subsonic Study of the NASA N2A Hybrid Wing-Body Using Star-CCM+
[View Code and Documentation](./projects/additional_projects/hwb_cfd_analysis)
_Main Files:_ `/code` for source code, `/docs` for report and documentation, `/figures` for images and visualizations.
- **Abstract**: This project involves a CFD analysis using the k-ω SST turbulence model combined with a polyhedral mesher approach to study subsonic flow (Mach 0.2) around NASA’s Hybrid Wing Body (HWB) in a simplified N2A configuration. The study focuses on analyzing flow behavior, lift and drag coefficients, and pressure coefficient distribution at various span positions, comparing these results with experimental data.
- **Skills Used**: StarCCM+, CATIA, turbulence modeling, flow simulation, data analysis
- **Highlights**: Successfully validated simulation results against experimental data, with high accuracy in lift and drag coefficients.

<p align="center">
  <img src="https://github.com/user-attachments/assets/55248542-6d7f-4044-abac-6df2eb06d85c" alt="Mesh Optimization Regions Screenshot" width="600"/>
</p>
<p align="center"><i>Figure 6: Mesh Optimization Regions</i></p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/57960224-c412-4e1c-a399-047858505061" alt="Star-CCM+ Pressure Coefficient Visualization Screenshot" width="600"/>
</p>
<p align="center"><i>Figure 7: Star-CCM+ Pressure Coefficient Visualization</i></p>

### 1-D Meanline Design Point Calculation and Loss Calculation for an Axial Turbine Stage
[View Code and Documentation](./projects/additional_projects/1d_meanline_axial_turbine_calculations)
_Main Files:_ `/code` for source code, `/docs` for report and documentation.
- **Abstract**: Developed a Python code for 1-D Meanline calculations for design and off-design behaviors in an axial turbine stage. A complementary Excel workbook was created to visualize stage efficiency across a range of geometric and flow coefficients, showing a peak efficiency pattern.
- **Skills Used**: Python, Excel, turbine design, efficiency optimization
- **Highlights**: Achieved peak efficiency across variable design parameters, aiding optimal turbine configuration.

<p align="center">
  <img src="https://github.com/user-attachments/assets/8f888b61-c3f9-4b10-bb62-dd229dd1c064" alt="1-D Meanline Axial Turbine Design Condition Output Screenshot" width="600"/>
</p>
<p align="center"><i>Figure 8: 1-D Meanline Axial Turbine Design Condition Output</i></p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/54ae7689-fb55-4e7b-9539-63bee9edbf01" alt="1-D Meanline Axial Turbine Off-Design Condition Output Screenshot" width="600"/>
</p>
<p align="center"><i>Figure 9: 1-D Meanline Axial Turbine Off-Design Condition Output</i></p>

### Matrix Fin-Based Transply Effusion Cooling System (Bachelor Thesis)
[View Code and Documentation](./projects/additional_projects/bachelor_thesis)
_Main Files:_ `/code` for source code, `/docs` for report and documentation.
- **Abstract**: Focused on enhancing cooling effectiveness in jet engines by optimizing matrix fin parameters within a transply effusion cooling system, analyzed using ANSYS Fluent. The study resulted in an optimized cooling system with better temperature distribution, showing superior effectiveness over conventional designs.
- **Skills Used**: ANSYS Fluent, thermal analysis, MATLAB optimization, system design
- **Highlights**: Demonstrated improved cooling effectiveness, providing an alternative to traditional transpiration cooling systems in jet engines.

<p align="center">
  <img src="https://github.com/user-attachments/assets/065ffb50-dc98-4c1b-8eda-5e444eb55b56" alt="Optimized Transply Effusion Cooling System Screenshot" width="600"/>
</p>
<p align="center"><i>Figure 10: Optimized Transply Effusion Cooling System</i></p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/9de0a423-d15c-483e-8b0f-ed4e38365af4" alt="ANSYS Temperature Gradient Visualization (Side View) Screenshot" width="600"/>
</p>
<p align="center"><i>Figure 11: ANSYS Temperature Gradient Visualization (Side View)</i></p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/2f5ee5a0-b221-40ab-91c0-b8c109487731" alt="ANSYS Temperature Gradient Visualization (Isometric View) Screenshot" width="600"/>
</p>
<p align="center"><i>Figure 12: ANSYS Temperature Gradient Visualization (Isometric View)</i></p>

---

## Technical Skills
- **Programming Languages**: C/C++, MATLAB/Simulink, Python
- **Simulation & Modeling Software**: Star-CCM+, ANSYS Fluent, CATIA, SolidWorks
- **Tools & Platforms**: Unix/Linux (Ubuntu), Git/GitHub, SQL, Microsoft Office (Excel, Word, PowerPoint)
- **Core Competencies**: Aerodynamic modeling, CFD, FFT, eigenvalue analysis, structural analysis

---

## Contact
Feel free to reach out if you have any questions or would like to discuss potential collaborations!
- **Email**: shreyasashwinsunder@gmail.com
- **LinkedIn**: https://www.linkedin.com/in/shreyasashwinsunder

Thank you for visiting my portfolio!
