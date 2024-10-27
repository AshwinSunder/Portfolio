from tkinter import *
from math import *
import pandas as pd
import csv
import sys

# Boundary Conditions(can be changed by user)
n = 10000 #rotational speed(1/min)
R = float(287.0) #gas constant(J/kgK)
Kappa = float(1.31) #ratio of specific heats
Cp = float(1212.81) #heat capacity at constant pressure(J/kgK)
const = float(0.016) #loss constant
Cd = float(0.002) #turbulent flow coefficient
l = float(0.04) #blade length(l1 = l2)
visc = float(6.41*(10**-5)) #dynamic viscosity(kg/ms)
Z = float(46) #blade count
Cpb = float(0.2) #base pressure coefficient
delte = float(0.0004) #Profile thickness at trailing edge(m)
delcl = float(0.0005) #clearance gap height(m)
Cc = 0.6 #contraction coefficient(=deleff/delcl)
Dh = [0.55,0,0] #hub diameter(m)
Ds = [0.65,0,0] #shroud diamter(m)
Ptot = [25,0,0] #total pressure(bar)
Ttot = [800,0,0] #total temperature(K)

# Flow Coefficient Range(should be kept constant)
rhoh = [0, 0.1, 0.2, 0.3, 0.4, 0.5]
psih = [-1.75, -2.0, -2.25, -2.5, -2.75, -3.0, -4.0]
phi = [0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, sqrt(0.5), 0.8]

# Other variables
T = [0]*3
P = [0]*3
Rho = [0]*3
A = [0]*3
alpha = [0]*3
beta = [0]*3
c = [0]*3
cu = [0]*3
w = [0]*3
wu = [0]*3
zeta1 = [0]*4
zeta2 = [0]*4
Ma = [0]*3
effstmax = [0]*2
alphamax = [0]*2
betamax = [0]*2
rhohmax = [0]*2
psihmax = [0]*2
phimax = [0]*2

# Counter variables
count = 1
ntest = 100

#Calculation of mean diameter
Dm = float((Dh[0] + Ds[0])/2) #Dm : constant (for repeating stages)

#Check for max rotational speed
while ntest < n+100: 
    for Rhoh in rhoh:   
        for Psih in psih:   
            for Phi in phi:        
                u = float((pi*Dm*ntest)/60)               
                cm = float(Phi*u)

                alpha[1] = acos(((1-Rhoh-(Psih/4)))/sqrt(((1-Rhoh-(Psih/4))**2+Phi**2)))
                beta[1] = acos(((1-Rhoh+(Psih/4)))/sqrt(((1-Rhoh+(Psih/4))**2+Phi**2)))

                alpha[2] = acos(((0-Rhoh-(Psih/4)))/sqrt(((0-Rhoh-(Psih/4))**2+Phi**2)))
                beta[2] = acos(((0-Rhoh+(Psih/4)))/sqrt(((0-Rhoh+(Psih/4))**2+Phi**2)))

                c[1] = float(cm/sin(alpha[1]))
                c[2] = float(cm/sin(alpha[2]))
                
                T[0] = float(Ttot[0]-(c[2]**2/(2*Cp)))            
                Ttot[2] = float(Ttot[0]+(Psih*(u**2))/(2*Cp))
                T[2] = float(Ttot[2]-((c[2]**2)/(2*Cp)))           
                Ttot[1] = Ttot[0]
                T[1] = float(Ttot[1]-(c[1]**2/(2*Cp)))
            
                if T[0] <= 0 or T[1] <= 0 or T[2] <= 0 or Ttot[1] <= 0 or Ttot[2] <= 0:                
                    sys.exit("Rotational speed exceeds max allowed speed")
    
    ntest = ntest+100
            
#Calculating velocities and angles
u = float((pi*Dm*n)/60) #u = u1 = u2(m/s)
                
#Design point calculations
with open('Design Calculations.csv','w') as f:    
    f.close()

for Rhoh in rhoh:   
    st2 = []    
    st0 ='Rhoh = '+str(Rhoh)
    
    for Psih in psih:       
        st2.append(Psih)

    d = {st0 : st2}   
    df = pd.DataFrame(data = d)
        
    for Phi in phi:        
        st1 = []
            
        for Psih in psih:           
            cm = float(Phi*u)           
            effst = float(Psih/(Psih-((const/Phi)*(((1-Rhoh-(Psih/4))**2)+Phi**2)**1.5)-((const/Phi)*(((0-Rhoh+(Psih/4))**2)+Phi**2)**1.5)))

            alpha[1] = acos(((1-Rhoh-(Psih/4)))/sqrt(((1-Rhoh-(Psih/4))**2+Phi**2)))
            beta[1] = acos(((1-Rhoh+(Psih/4)))/sqrt(((1-Rhoh+(Psih/4))**2+Phi**2)))

            alpha[2] = acos(((0-Rhoh-(Psih/4)))/sqrt(((0-Rhoh-(Psih/4))**2+Phi**2)))
            beta[2] = acos(((0-Rhoh+(Psih/4)))/sqrt(((0-Rhoh+(Psih/4))**2+Phi**2)))

            c[1] = float(cm/sin(alpha[1]))
            c[2] = float(cm/sin(alpha[2]))

            cu[1] = float(c[1]*cos(alpha[1]))
            cu[2] = float(c[2]*cos(alpha[2]))

            c[0] = c[2] #Repeating stage
            cu[0] = c[0]*cos(alpha[0])

            wu[1] = float(cu[1]-u)
            w[1] = sqrt(wu[1]**2+cm**2)
            wu[2] = float(cu[2]-u)
            w[2] = sqrt(fabs(wu[2]**2+cm**2))
            w[0] = sqrt(fabs(c[0]**2-u**2))
            wu[0] = cu[0]-u

            #Calculation of initial conditions, power and circumferential mach number
            T[0] = float(Ttot[0]-(c[2]**2/(2*Cp)))  #c0 = c2 (Repeating stage)
            P[0] = float(Ptot[0]*(T[0]/Ttot[0])**(Kappa/(Kappa-1)))
            Rho[0] = float(P[0]*(10**5)/(R*T[0]))
            A[0] = float(pi*(Ds[0]**2-Dh[0]**2)/4)            
            mdot = float(Rho[0]*A[0]*cm)
            Pow = float((mdot*Psih*u**2)/2) #delht = (Psih*u2**2)/2
            Ma[0] = float(u/sqrt(Kappa*R*Ttot[0]))

            #Calculation of conditions 1 and 2
            #Condition 2
            Ttot[2] = float(Ttot[0]+(Psih*(u**2))/(2*Cp)) #delht = Cp*(Ttot[2]-Ttot[0])
            T[2] = float(Ttot[2]-((c[2]**2)/(2*Cp)))
            delht = float(Cp*(Ttot[2]-Ttot[0]))
            Ptot[2] = float(Ptot[0]*(((delht/(Cp*Ttot[0]*effst))+1)**(Kappa/(Kappa-1))))
            P[2] = float(Ptot[2]*((T[2]/Ttot[2])**(Kappa/(Kappa-1))))
            Rho[2] = float((P[2]*(10**5))/(R*T[2]))

            #Condition 1
            delhs = float((1-Rhoh)*delht-(const*(c[1]**2)/(sin(alpha[1])*2)))
            P[1] = float(P[0]*(((delhs/(Cp*T[0]))+1)**(Kappa/(Kappa-1))))
            Ttot[1] = Ttot[0]
            T[1] = float(Ttot[1]-(c[1]**2/(2*Cp)))
            Ptot[1] = float(P[1]*((Ttot[1]/T[1])**(Kappa/(Kappa-1))))
            Rho[1] = float((P[1]*(10**5))/(R*T[1]))
                
            #Check for choking at rotor and stator exits
            Ma[1] = float(w[1]/sqrt(Kappa*R*T[1]))                
            Ma[2] = float(c[1]/sqrt(Kappa*R*T[2]))
                
            if Ma[1] >= float(1) or Ma[2] >= float(1):                   
                count = 1                    
            else:                    
                count = 0
                    
            #Calculation of hub and casing diameters based on meanline calculation at position 1 and 2
            A[1] = float(mdot/(Rho[1]*cm))
            A[2] = float(mdot/(Rho[2]*cm))

            h1 = float(A[1]/(pi*Dm))
            h2 = float(A[2]/(pi*Dm))

            Ds[1] = Dm+h1
            Dh[1] = Dm-h1
            Ds[2] = Dm+h2
            Dh[2] = Dm-h2

            # Calculation of isentropic total stage efficiency with loss consideration
            #Profile losses
            alpha[0] = alpha[2] #No swirl and repeating stage
            t = float((pi*Dm)/Z)

            zeta1[0] = float(Cd*((1/sin(alpha[0])+(1/sin(alpha[1])))/(1/sin(alpha[1]))**2)*(((0.5*l/t)*((1/sin(alpha[0]))+(1/sin(alpha[1])))**2)+((1.5*t/l)*((1/tan(alpha[1]))-(1/tan(alpha[0])))**2)))
            zeta2[0] = float(Cd*((1/sin(beta[1])+(1/sin(beta[2])))/(1/sin(beta[2]))**2)*(((0.5*l/t)*((1/sin(beta[1]))+(1/sin(beta[2])))**2)+((1.5*t/l)*((1/tan(beta[2]))-(1/tan(beta[1])))**2)))

            #Wake losses at trailing egde
            Re1 = float(c[0]*Rho[0]*l/visc)
            Re2 = float(c[1]*Rho[1]*l/visc)

            del1 = float(0.046*l*(Re1**(-0.2))) #Displacement Thickness
            del2 = float(0.036*l*(Re2**(-0.2))) #Momentum Thickness

            zeta1[1] = float((Cpb*(t*sin(alpha[1])*delte)+(2*t*sin(alpha[1]*del2))+(del1+delte)**2)/(((t*sin(alpha[1]))-delte-del1)**2))
            zeta2[1] = float((Cpb*(t*sin(beta[2])*delte)+(2*t*sin(beta[2]*del2))+(del1+delte)**2)/(((t*sin(beta[2]))-delte-del1)**2))
    
            #Tip leakage losses
            zeta1[2] = float((Cc*delcl*sqrt(2)/(Ds[1]-Dh[1]))*(sqrt(t/l))*(sqrt(fabs(cos(alpha[0]-2*alpha[1])+cos(alpha[1])-cos(alpha[0])-cos(2*alpha[0]-alpha[1]))))*(sin(alpha[0])+sin(alpha[1])+((t*sin(alpha[0]-alpha[1]))/l))*(sin(alpha[0]-alpha[1])/(((sin(alpha[0]))**3)*sin(alpha[1]))))
            zeta2[2] = float((Cc*delcl*sqrt(2)/(Ds[2]-Dh[2]))*(sqrt(t/l))*(sqrt(fabs(cos(beta[2]-2*beta[1])+cos(beta[1])-cos(beta[2])-cos(2*beta[2]-beta[1]))))*(sin(beta[1])+sin(beta[2])+((t*sin(beta[2]-beta[1]))/l))*(sin(beta[2]-beta[1])/(((sin(beta[1]))**3)*sin(beta[2]))))

            #Secondary flow losses
            alpham = atan(2/((1/tan(alpha[0]))+alpha[1]))
            betam = atan(2/((1/tan(beta[1]))+beta[2]))
                
            if alpham < 0:                
                alpham = alpham+pi
    
            if betam < 0:                
                betam = betam+pi
    
            zeta1[3] = float((0.75*0.1336*l*(sin(alpha[1])**3)/(2*h1*sqrt(sin(alpha[0])))*sin(alpham))*((1/tan(alpha[0])-(1/tan(alpha[1])))**2))
            zeta2[3] = float((0.75*0.1336*l*(sin(beta[2])**3)/(2*h1*sqrt(sin(beta[1]))*sin(betam)))*((1/tan(beta[1])-(1/tan(beta[2])))**2))

            #Total loss calculation
            zetastat = 0           
            zetarot = 0

            for x in range(4):   
                zetastat = zetastat+zeta1[x]    
                zetarot = zetarot+zeta2[x]
       
            #Efficiency calculation
            effstnew = float(Psih/((Psih-(zetastat*(((1-Rhoh-(Psih/4))**2)+Phi**2))-(zetarot*(((0-Rhoh+(Psih/4))**2)+Phi**2)))))
                
            if effstnew > effstmax[1]:                   
                if effstnew > effstmax[0]:                       
                    effstmax[0] = float(effstnew)                       
                    alphamax[0] = alpha[1]                        
                    betamax[0] = beta[2]                   
                    rhohmax[0] = Rhoh                    
                    psihmax[0] = Psih                   
                    phimax[0] = Phi                       
                else:                       
                    effstmax[1] = float(effstnew)                        
                    alphamax[1] = alpha[1]                        
                    betamax[1] = beta[2]                    
                    rhohmax[1] = Rhoh                    
                    psihmax[1] = Psih                    
                    phimax[1] = Phi
                    
            #Writing into the csv file                       
            if count == 0:                   
                st1.append(round(effstnew*100, 3))                   
            else:                   
                st1.append(0)
                
        df[Phi] = st1
        
    with open('Design Calculations.csv','a') as f:       
        df.to_csv(f, index = False)       
        f.write("\n\n")
        
        
#Off design calculations
with open('Off-design Calculations.csv','w') as f:   
    f.close()

with open('Off-design Calculations.csv', 'a', newline='') as file:   
    writer = csv.writer(file)
                
    for j in range(len(effstmax)):       
        app_row3 = ["Rhoh = "+str(rhohmax[j]), "Psih = "+str(psihmax[j]), "Phi = "+str(phimax[j])]           
        app_row4 = ["Phi", "Psihoff", "Psiy", "effpt"]
            
        writer.writerow(app_row3)           
        writer.writerow(app_row4)
         
        for Phi in phi:           
            #Calculating velocities and angles           
            alpha[1] = alphamax[j]            
            beta[2] = betamax[j]
                        
            K = float(2*((1/tan(beta[2]))-(1/tan(alpha[1]))))  
            Psihoff = float(2+(K*Phi))   
            cm = float(Phi*u)

            c[1] = float(cm/sin(alpha[1]))
            c[2] = float(cm/sin(alpha[2]))
            
            cu[1] = float(c[1]*cos(alpha[1]))            
            cu[2] = float((Psihoff*u/2)+cu[1])
            
            Rhoh2 = float(1-((cu[2]+cu[1])/(2*u)))           
            effst = float(Psihoff/(Psihoff-((const/Phi)*(((1-Rhoh2-(Psihoff/4))**2)+Phi**2)**1.5)-((const/Phi)*(((0-Rhoh2+(Psihoff/4))**2)+Phi**2)**1.5)))
            beta[1] = acos(((1-Rhoh2+(Psihoff/4)))/sqrt(((1-Rhoh2+(Psihoff/4))**2+Phi**2)))
            alpha[2] = acos(((0-Rhoh2-(Psihoff/4)))/sqrt(((0-Rhoh2-(Psihoff/4))**2+Phi**2)))

            c[0] = c[2]
            cu[0] = c[0]*cos(alpha[0])
            
            wu[1] = float(cu[1]-u)
            w[1] = sqrt(wu[1]**2+cm**2)
            wu[2] = float(cu[2]-u)
            w[2] = sqrt(fabs(wu[2]**2+cm**2))
            w[0] = sqrt(fabs(c[0]**2-u**2))
            wu[0] = cu[0]-u
            
            #Calculation of conditions 1 and 2
            #Condition 2
            Ttot[2] = float(Ttot[0]+(Psihoff*(u**2))/(2*Cp)) #delht = Cp*(Ttot[2]-Ttot[0])
            T[2] = float(Ttot[2]-((c[2]**2)/(2*Cp)))
            delht = float(Cp*(Ttot[2]-Ttot[0]))
            Ptot[2] = float(Ptot[0]*(((delht/(Cp*Ttot[0]*effst))+1)**(Kappa/(Kappa-1))))
            P[2] = float(Ptot[2]*((T[2]/Ttot[2])**(Kappa/(Kappa-1))))
            Rho[2] = float((P[2]*(10**5))/(R*T[2]))
            
            #Condition 1
            delhs = float((1-Rhoh)*delht-(const*(c[1]**2)/(sin(alpha[1])*2)))
            P[1] = float(P[0]*(((delhs/(Cp*T[0]))+1)**(Kappa/(Kappa-1))))
            Ttot[1] = Ttot[0]
            T[1] = float(Ttot[1]-(c[1]**2/(2*Cp)))
            Ptot[1] = float(P[1]*((Ttot[1]/T[1])**(Kappa/(Kappa-1))))
            Rho[1] = float((P[1]*(10**5))/(R*T[1]))
            alpha[0] = alpha[2]
            t = float((pi*Dm)/Z)
                        
            #Check for choking at rotor and stator exits
            Ma[1] = float(w[1]/sqrt(Kappa*R*T[1]))                
            Ma[2] = float(c[1]/sqrt(Kappa*R*T[2]))
                
            if Ma[1] >= float(1) or Ma[2] >= float(1):                    
                count = 1                
            else:                
                count = 0
                    
            # Calculation of isentropic total stage efficiency with loss consideration
            #Profile losses
            alpha[0] = alpha[2] #No swirl and repeating stage
            t = float((pi*Dm)/Z)

            zeta1[0] = float(Cd*((1/sin(alpha[0])+(1/sin(alpha[1])))/(1/sin(alpha[1]))**2)*(((0.5*l/t)*((1/sin(alpha[0]))+(1/sin(alpha[1])))**2)+((1.5*t/l)*((1/tan(alpha[1]))-(1/tan(alpha[0])))**2)))
            zeta2[0] = float(Cd*((1/sin(beta[1])+(1/sin(beta[2])))/(1/sin(beta[2]))**2)*(((0.5*l/t)*((1/sin(beta[1]))+(1/sin(beta[2])))**2)+((1.5*t/l)*((1/tan(beta[2]))-(1/tan(beta[1])))**2)))

            #Wake losses at trailing egde
            Re1 = float(c[0]*Rho[0]*l/visc)
            Re2 = float(c[1]*Rho[1]*l/visc)

            del1 = float(0.046*l*(Re1**(-0.2))) #Displacement Thickness
            del2 = float(0.036*l*(Re2**(-0.2))) #Momentum Thickness

            zeta1[1] = float((Cpb*(t*sin(alpha[1])*delte)+(2*t*sin(alpha[1]*del2))+(del1+delte)**2)/(((t*sin(alpha[1]))-delte-del1)**2))
            zeta2[1] = float((Cpb*(t*sin(beta[2])*delte)+(2*t*sin(beta[2]*del2))+(del1+delte)**2)/(((t*sin(beta[2]))-delte-del1)**2))
    
            #Tip leakage losses
            zeta1[2] = float((Cc*delcl*sqrt(2)/(Ds[1]-Dh[1]))*(sqrt(t/l))*(sqrt(fabs(cos(alpha[0]-2*alpha[1])+cos(alpha[1])-cos(alpha[0])-cos(2*alpha[0]-alpha[1]))))*(sin(alpha[0])+sin(alpha[1])+((t*sin(alpha[0]-alpha[1]))/l))*(sin(alpha[0]-alpha[1])/(((sin(alpha[0]))**3)*sin(alpha[1]))))
            zeta2[2] = float((Cc*delcl*sqrt(2)/(Ds[2]-Dh[2]))*(sqrt(t/l))*(sqrt(fabs(cos(beta[2]-2*beta[1])+cos(beta[1])-cos(beta[2])-cos(2*beta[2]-beta[1]))))*(sin(beta[1])+sin(beta[2])+((t*sin(beta[2]-beta[1]))/l))*(sin(beta[2]-beta[1])/(((sin(beta[1]))**3)*sin(beta[2]))))

            #Secondary flow losses
            alpham = atan(2/((1/tan(alpha[0]))+alpha[1]))
            betam = atan(2/((1/tan(beta[1]))+beta[2]))
                
            if alpham < 0:                
                alpham = alpham+pi
    
            if betam < 0:                
                betam = betam+pi
    
            zeta1[3] = float((0.75*0.1336*l*(sin(alpha[1])**3)/(2*h1*sqrt(sin(alpha[0])))*sin(alpham))*((1/tan(alpha[0])-(1/tan(alpha[1])))**2))
            zeta2[3] = float((0.75*0.1336*l*(sin(beta[2])**3)/(2*h1*sqrt(sin(beta[1]))*sin(betam)))*((1/tan(beta[1])-(1/tan(beta[2])))**2))

            #Total loss calculation
            zetastat = 0           
            zetarot = 0

            for x in range(4):    
                zetastat = zetastat+zeta1[x]   
                zetarot = zetarot+zeta2[x]
                
            #Efficiency and Psiy calculations    
            effpt = float(Psihoff/((Psihoff-(zetastat*(((1-Rhoh2-(Psihoff/4))**2)+Phi**2))-(zetarot*(((0-Rhoh2+(Psihoff/4))**2)+Phi**2)))))        
            Psiy = float(Psihoff/effpt)
            
            #Writing into the csv file            
            if count == 0:    
                app_row5 = [round(Phi, 3), round(Psihoff, 3), round(Psiy, 3), round(effpt*100, 3), "*"]                
            else:                
                app_row5 = [round(Phi, 3), round(Psihoff, 3), round(Psiy, 3), round(effpt*100, 3), "**"]
                
            writer.writerow(app_row5)        
        writer.writerow("\n")