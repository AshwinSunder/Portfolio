# Required header files
import fileWrapper as fw
import os
import math
import simRunner as sr
import shutil
from scipy.spatial.transform import Rotation as R
import numpy as np

# Fixed file locations
input_file_loc    = "."
#sciebo_file_loc   = ".../.../..."
#sciebo_file       = ".../.../..."
sim_name = []

# Fixed model data
r            = 0.118
bby2         = 0.64
c            = 0.24
twist        = 48
chord_1      = 0.053
chord_2      = chord_1
span_1       = r
sweep_1      = 0.0
dihed_1      = 0.0
nelem_span_1 = 16

# Fixed model locations
wing_file_loc           = "../../Model/Wing"
wing_file               = "wing_prowim.in"
blade_file_loc          = "../../Model/Blades/"
blade_file_dust_pre_loc = "../../Model/Blades/"

# Fixed simulation data
tf          = 0.03995
dt          = 0.00005
density     = 1.2

# Fixed reference data
parent_1    = "0"
ref_tag_1   = "Wing"
ref_tag_2   = "PivotPoint"
parent_3    = "PivotPoint"
ref_tag_3   = "Hub01"
parent_4    = "Hub01"
ref_tag_4   = "Prop01"
comp_name_1 = "W"
comp_name_2 = "P"

# Fixed output file locations
output_file_loc    = "../../Output"
dust_sim_file_name = "wing_prop"
dust_sim_file_loc  = "dust"
Intloads_file_loc  = "Postpro/Intloads"
Secloads_file_loc  = "Postpro/Secloads"

# Fixed fileWrapper keys
blade_file_key             = ["@chord_1","@twist_1","@span_1","@sweep_1","@dihed_1","@nelem_span_1","@chord_2","@twist_2"]
references_key             = ["@amp","@xp1","@xp2","@yp","@zp","@orientation","@rot_rate","@rot_axis","@parent_1","@parent_2","@parent_3","@parent_4","@ref_tag_1","@ref_tag_2","@ref_tag_3","@ref_tag_4"]
dust_pre_WP_key            = ["@wing_file","@blade_file"]
dust_key                   = ["@tf","@dt","@vel","@density","@output_file"]
dustPost_IntLoads_WP_key   = ["@tf_res","@sim_name","@output_file","@comp_name_1","@comp_name_2"]
dustPost_SecLoads_W_key    = ["@tf_res","@sim_name","@output_file","@comp_name_1"]

########################## Blade Pitch Angle Validation Studies ##########################

# Fixed variables for current simulation(s)
amp_prop    = 0.0
vel         = (1500/(0.5*density))**0.5
amp         = 0.0
xp          = -0.2018/c
yp          = -0.3/bby2
zp          = 0.0
J           = 0.85
rot_axis    = "(/-1.0, 0.0, 0.0/)"
rot_dir     = "IU"
thrust      = "LT"
orientation = "(/ -1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, -1.0 /)"
parent_2    = "0"

# Output file locations for current simulation(s)
output_file_name   = "wing_propeller"

# Variables for current simulation(s)
amp_range         = [2*x for x in range(6)]
blade_angle_range = [20,25,30]

# Loop to create simulation data arrays
new_sim_name = []
amp          = []
twist_1      = []
twist_2      = []
for i in range(len(amp_range)):
    for j in range(len(blade_angle_range)):

            if int(amp_range[i]) == round(amp_range[i],1):
                amp_sim = int(amp_range[i])
            else:
                amp_sim = round(amp_range[i],1)

            if int(J) == round(J,3):
                J_sim = int(J)
            else:
                J_sim = round(J,3)

            if int(xp) == round(xp,3):
                xp_sim = int(xp)
            else:
                xp_sim = round(xp,3)

            if int(yp) == round(yp,3):
                yp_sim = int(yp)
            else:
                yp_sim = round(yp,3)

            if int(zp) == round(zp,4):
                zp_sim = int(zp)
            else:
                zp_sim = round(zp,4)      

            if rot_dir == "IU":
                twist_1_sim = -blade_angle_range[j]-0.75*twist
                twist_2_sim = -blade_angle_range[j]+0.25*twist
            elif rot_dir == "OU":
                twist_1_sim = blade_angle_range[j]+0.75*twist
                twist_2_sim = blade_angle_range[j]-0.25*twist

            curr_sim_name = "J"+str(J_sim)+"_alpha"+str(amp_sim)+"_xp"+str(-xp_sim)+"_yp"+str(-yp_sim)+"_zp"+str(zp_sim)+"_alpha_prop"+str(int(amp_prop))+"_blade_angle"+str(int(blade_angle_range[j]))+"_"+rot_dir+"_"+thrust
            if curr_sim_name.replace(".","_")+"_"+comp_name_1 not in sim_name:
                new_sim_name += [curr_sim_name.replace(".","_")]
                amp          += [amp_sim]
                twist_1      += [twist_1_sim]
                twist_2      += [twist_2_sim]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):
    
    # Clean screen and old dust output files
    sr.cleanup(output_file_loc,output_file_name,dust_sim_file_loc)

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    sim_name_Secloads = "Secloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    basename_Secloads = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)
        
    # Create blade file
    blade_file_parameters = [chord_1,twist_1[i],span_1,sweep_1,dihed_1,nelem_span_1,chord_2,twist_2[i]]
    fw.wrap_file(os.path.join(blade_file_loc,"blade_tmpl.in"),os.path.join(blade_file_loc,"blade.in"),blade_file_key,blade_file_parameters)      

    # fileWrapper parameters for current simulation
    references_parameters            = [str(amp[i]*math.pi/180),str(0.0),str(round(xp*c-c/4,6)),str(round(yp*bby2,6)),str(round(zp*r,6)),orientation,str(2*math.pi*vel/(J*2*r)),rot_axis,parent_1,parent_2,parent_3,parent_4,ref_tag_1,ref_tag_2,ref_tag_3,ref_tag_4]
    dust_pre_WP_parameters           = [os.path.join(wing_file_loc,wing_file),os.path.join(blade_file_dust_pre_loc,"blade.in")]
    dust_parameters                  = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_WP_parameters  = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name_1,comp_name_2]
    dustPost_SecLoads_W_parameters   = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name_1]

    # Create inputs for dust_wrap function
    dust_keys       = [references_key,dust_pre_WP_key,dust_key,dustPost_IntLoads_WP_key,dustPost_SecLoads_W_key]
    dust_parameters = [references_parameters,dust_pre_WP_parameters,dust_parameters,dustPost_IntLoads_WP_parameters,dustPost_SecLoads_W_parameters]
    dust_tmpl_files = ["References_tmpl.in","dust_pre_WP_tmpl.in","dust_tmpl.in","dustPost_IntLoads_WP_tmpl.in","dustPost_SecLoads_W_tmpl.in"]
    dust_files      = ["References.in","dust_pre.in","dust.in","dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.dust_wrap(dust_keys,dust_parameters,dust_tmpl_files,dust_files,input_file_loc)

    # Run dust_pre, dust and dust_post
    dust_post_files = ["dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.run_dust(dust_post_files=dust_post_files,input_file_loc=input_file_loc)

    # Copy files to sciebo
    '''Postpro_file_loc   = [Intloads_file_loc,Secloads_file_loc]
    sim_name_dust_post = [sim_name_Intloads,sim_name_Secloads]
    comp_name          = [comp_name_1,comp_name_2,comp_name_1]

    sr.copy_dust_post_files(sciebo_file_loc,sciebo_file,output_file_loc,output_file_name,Postpro_file_loc,sim_name_dust_post,comp_name,is_IntLoads=True,num_IntLoads=2,is_SecLoads=True,num_SecLoads=1)'''

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name_1

sim_name = sim_name+new_sim_name

########################## Advance Ratio Validation Studies ##########################

# Fixed variables for current simulation(s)
vel         = (1500/(0.5*density))**0.5
amp_prop    = 0.0
amp         = 0.0
xp          = -0.2018/c
yp          = -0.3/bby2
zp          = 0.0
blade_angle = 25
rot_axis    = "(/-1.0, 0.0, 0.0/)"
rot_dir     = "IU"
thrust      = "LT"
orientation = "(/ -1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, -1.0 /)"
parent_2    = "0"

# Create blade file  
if rot_dir == "IU":
    twist_1  = -blade_angle-0.75*twist
    twist_2  = -blade_angle+0.25*twist
    rot_axis = "(/-1.0, 0.0, 0.0/)"
elif rot_dir == "OU":
    twist_1  = blade_angle+0.75*twist
    twist_2  = blade_angle-0.25*twist
    rot_axis = "(/1.0, 0.0, 0.0/)"
        
blade_file_parameters = [chord_1,twist_1,span_1,sweep_1,dihed_1,nelem_span_1,chord_2,twist_2]
fw.wrap_file(os.path.join(blade_file_loc,"blade_tmpl.in"),os.path.join(blade_file_loc,"blade.in"),blade_file_key,blade_file_parameters)      

# Output file locations for current simulation(s)
output_file_name   = "wing_propeller"

# Variables for current simulation(s)
amp_range         = [2*x for x in range(6)]
J_range           = [0.81,0.95,1.11]

# Loop to create simulation data arrays
new_sim_name = []
amp          = []
J            = []
for i in range(len(amp_range)):
    for j in range(len(J_range)):

            if int(amp_range[i]) == round(amp_range[i],1):
                amp_sim = int(amp_range[i])
            else:
                amp_sim = round(amp_range[i],1)

            if int(J_range[j]) == round(J_range[j],3):
                J_sim = int(J_range[j])
            else:
                J_sim = round(J_range[j],3)

            if int(xp) == round(xp,3):
                xp_sim = int(xp)
            else:
                xp_sim = round(xp,3)

            if int(yp) == round(yp,3):
                yp_sim = int(yp)
            else:
                yp_sim = round(yp,3)

            if int(zp) == round(zp,4):
                zp_sim = int(zp)
            else:
                zp_sim = round(zp,4)

            curr_sim_name = "J"+str(J_sim)+"_alpha"+str(amp_sim)+"_xp"+str(-xp_sim)+"_yp"+str(-yp_sim)+"_zp"+str(zp_sim)+"_alpha_prop"+str(int(amp_prop))+"_blade_angle"+str(int(blade_angle))+"_"+rot_dir+"_"+thrust
            if curr_sim_name.replace(".","_")+"_"+comp_name_1 not in sim_name:
                new_sim_name += [curr_sim_name.replace(".","_")]
                amp          += [amp_sim]
                J            += [J_sim]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):
    
    # Clean screen and old dust output files
    sr.cleanup(output_file_loc,output_file_name,dust_sim_file_loc)

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    sim_name_Secloads = "Secloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    basename_Secloads = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)

    # fileWrapper parameters for current simulation
    references_parameters            = [str(amp[i]*math.pi/180),str(0.0),str(round(xp*c-c/4,6)),str(round(yp*bby2,6)),str(round(zp*r,6)),orientation,str(2*math.pi*vel/(J[i]*2*r)),rot_axis,parent_1,parent_2,parent_3,parent_4,ref_tag_1,ref_tag_2,ref_tag_3,ref_tag_4]
    dust_pre_WP_parameters           = [os.path.join(wing_file_loc,wing_file),os.path.join(blade_file_dust_pre_loc,"blade.in")]
    dust_parameters                  = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_WP_parameters  = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name_1,comp_name_2]
    dustPost_SecLoads_W_parameters   = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name_1]

    # Create inputs for dust_wrap function
    dust_keys       = [references_key,dust_pre_WP_key,dust_key,dustPost_IntLoads_WP_key,dustPost_SecLoads_W_key]
    dust_parameters = [references_parameters,dust_pre_WP_parameters,dust_parameters,dustPost_IntLoads_WP_parameters,dustPost_SecLoads_W_parameters]
    dust_tmpl_files = ["References_tmpl.in","dust_pre_WP_tmpl.in","dust_tmpl.in","dustPost_IntLoads_WP_tmpl.in","dustPost_SecLoads_W_tmpl.in"]
    dust_files      = ["References.in","dust_pre.in","dust.in","dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.dust_wrap(dust_keys,dust_parameters,dust_tmpl_files,dust_files,input_file_loc)

    # Run dust_pre, dust and dust_post
    dust_post_files = ["dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.run_dust(dust_post_files=dust_post_files,input_file_loc=input_file_loc)

    # Copy files to sciebo
    '''Postpro_file_loc   = [Intloads_file_loc,Secloads_file_loc]
    sim_name_dust_post = [sim_name_Intloads,sim_name_Secloads]
    comp_name          = [comp_name_1,comp_name_2,comp_name_1]

    sr.copy_dust_post_files(sciebo_file_loc,sciebo_file,output_file_loc,output_file_name,Postpro_file_loc,sim_name_dust_post,comp_name,is_IntLoads=True,num_IntLoads=2,is_SecLoads=True,num_SecLoads=1)'''

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name_1

sim_name = sim_name+new_sim_name

########################## Rotation Direction Validation Studies ##########################

# Fixed variables for current simulation(s)
vel         = (1500/(0.5*density))**0.5
amp_prop    = 0.0
amp         = 0.0
xp          = -0.2018/c
yp          = -0.3/bby2
zp          = 0.0
J           = 0.85
blade_angle = 25
rot_axis    = "(/-1.0, 0.0, 0.0/)"
thrust      = "LT"
orientation = "(/ -1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, -1.0 /)"
parent_2    = "0"

# Output file locations for current simulation(s)
output_file_name   = "wing_propeller"

# Variables for current simulation(s)
amp_range         = [2*x for x in range(6)]
rot_dir_range     = ["IU","OU"]

# Loop to create simulation data arrays
new_sim_name = []
amp          = []
twist_1      = []
twist_2      = []
rot_axis     = []
for i in range(len(amp_range)):
    for j in range(len(rot_dir_range)):

            if int(amp_range[i]) == round(amp_range[i],1):
                amp_sim = int(amp_range[i])
            else:
                amp_sim = round(amp_range[i],1)

            if int(J) == round(J,3):
                J_sim = int(J)
            else:
                J_sim = round(J,3)

            if int(xp) == round(xp,3):
                xp_sim = int(xp)
            else:
                xp_sim = round(xp,3)

            if int(yp) == round(yp,3):
                yp_sim = int(yp)
            else:
                yp_sim = round(yp,3)

            if int(zp) == round(zp,4):
                zp_sim = int(zp)
            else:
                zp_sim = round(zp,4)      

            if rot_dir_range[j] is "IU":
                twist_1_sim  = -blade_angle-0.75*twist
                twist_2_sim  = -blade_angle+0.25*twist
                rot_axis_sim = "(/-1.0, 0.0, 0.0/)"
            elif rot_dir_range[j] is "OU":
                twist_1_sim  = blade_angle+0.75*twist
                twist_2_sim  = blade_angle-0.25*twist
                rot_axis_sim = "(/1.0, 0.0, 0.0/)"

            curr_sim_name = "J"+str(J_sim)+"_alpha"+str(amp_sim)+"_xp"+str(-xp_sim)+"_yp"+str(-yp_sim)+"_zp"+str(zp_sim)+"_alpha_prop"+str(int(amp_prop))+"_blade_angle"+str(int(blade_angle))+"_"+rot_dir_range[j]+"_"+thrust
            if curr_sim_name.replace(".","_")+"_"+comp_name_1 not in sim_name:
                new_sim_name += [curr_sim_name.replace(".","_")]
                amp          += [amp_sim]
                twist_1      += [twist_1_sim]
                twist_2      += [twist_2_sim]
                rot_axis     += [rot_axis_sim]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):
    
    # Clean screen and old dust output files
    sr.cleanup(output_file_loc,output_file_name,dust_sim_file_loc)

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    sim_name_Secloads = "Secloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    basename_Secloads = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)
        
    # Create blade file
    blade_file_parameters = [chord_1,twist_1[i],span_1,sweep_1,dihed_1,nelem_span_1,chord_2,twist_2[i]]
    fw.wrap_file(os.path.join(blade_file_loc,"blade_tmpl.in"),os.path.join(blade_file_loc,"blade.in"),blade_file_key,blade_file_parameters)      

    # fileWrapper parameters for current simulation
    references_parameters            = [str(amp[i]*math.pi/180),str(0.0),str(round(xp*c-c/4,6)),str(round(yp*bby2,6)),str(round(zp*r,6)),orientation,str(2*math.pi*vel/(J*2*r)),rot_axis[i],parent_1,parent_2,parent_3,parent_4,ref_tag_1,ref_tag_2,ref_tag_3,ref_tag_4]
    dust_pre_WP_parameters           = [os.path.join(wing_file_loc,wing_file),os.path.join(blade_file_dust_pre_loc,"blade.in")]
    dust_parameters                  = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_WP_parameters  = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name_1,comp_name_2]
    dustPost_SecLoads_W_parameters   = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name_1]

    # Create inputs for dust_wrap function
    dust_keys       = [references_key,dust_pre_WP_key,dust_key,dustPost_IntLoads_WP_key,dustPost_SecLoads_W_key]
    dust_parameters = [references_parameters,dust_pre_WP_parameters,dust_parameters,dustPost_IntLoads_WP_parameters,dustPost_SecLoads_W_parameters]
    dust_tmpl_files = ["References_tmpl.in","dust_pre_WP_tmpl.in","dust_tmpl.in","dustPost_IntLoads_WP_tmpl.in","dustPost_SecLoads_W_tmpl.in"]
    dust_files      = ["References.in","dust_pre.in","dust.in","dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.dust_wrap(dust_keys,dust_parameters,dust_tmpl_files,dust_files,input_file_loc)

    # Run dust_pre, dust and dust_post
    dust_post_files = ["dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.run_dust(dust_post_files=dust_post_files,input_file_loc=input_file_loc)

    # Copy files to sciebo
    '''Postpro_file_loc   = [Intloads_file_loc,Secloads_file_loc]
    sim_name_dust_post = [sim_name_Intloads,sim_name_Secloads]
    comp_name          = [comp_name_1,comp_name_2,comp_name_1]

    sr.copy_dust_post_files(sciebo_file_loc,sciebo_file,output_file_loc,output_file_name,Postpro_file_loc,sim_name_dust_post,comp_name,is_IntLoads=True,num_IntLoads=2,is_SecLoads=True,num_SecLoads=1)'''

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name_1

sim_name = sim_name+new_sim_name

########################## Propeller Inclination Validation Studies ##########################

# Fixed variables for current simulation(s)
vel         = (1500/(0.5*density))**0.5
xp          = -0.2018/c
yp          = -0.3/bby2
zp          = 0.0
J           = 0.92
blade_angle = 25
thrust      = "LT"
rot_dir     = "IU"
parent_2    = "0"

# Create blade file  
if rot_dir == "IU":
    twist_1  = -blade_angle-0.75*twist
    twist_2  = -blade_angle+0.25*twist
    rot_axis = "(/-1.0, 0.0, 0.0/)"
elif rot_dir == "OU":
    twist_1  = blade_angle+0.75*twist
    twist_2  = blade_angle-0.25*twist
    rot_axis = "(/1.0, 0.0, 0.0/)"
        
blade_file_parameters = [chord_1,twist_1,span_1,sweep_1,dihed_1,nelem_span_1,chord_2,twist_2]
fw.wrap_file(os.path.join(blade_file_loc,"blade_tmpl.in"),os.path.join(blade_file_loc,"blade.in"),blade_file_key,blade_file_parameters)      

# Output file locations for current simulation(s)
output_file_name   = "wing_propeller"

# Variables for current simulation(s)
amp_range      = [4.2*x for x in range(1,3)]
amp_prop_range = [2*x for x in range(-12,8)]

# Loop to create simulation data arrays
new_sim_name = []
amp          = []
orientation  = []
for i in range(len(amp_range)):
    for j in range(len(amp_prop_range)):

        amp_prop_sim = int(amp_prop_range[j])

        r_mat = R.from_euler('y',round(180-amp_prop_sim,0),degrees=True)
        mat   = np.reshape(r_mat.as_matrix(),[1,9])
        mat   = mat[0]

        orientation_sim = "(/"
        for l in range(len(mat)):
            if int(mat[l]) == mat[l]:
                orientation_sim += " "+str(int(mat[l]))+".0"
            else:
                orientation_sim += " "+str(mat[l])
            
            if l < len(mat)-1:
                orientation_sim += ","

        orientation_sim += " /)"

        if int(amp_range[i]) == round(amp_range[i],1):
            amp_sim = int(amp_range[i])
        else:
            amp_sim = round(amp_range[i],1)

        if int(J) == round(J,3):
            J_sim = int(J)
        else:
            J_sim = round(J,3)

        if int(xp) == round(xp,3):
            xp_sim = int(xp)
        else:
            xp_sim = round(xp,3)

        if int(yp) == round(yp,3):
            yp_sim = int(yp)
        else:
            yp_sim = round(yp,3)

        if int(zp) == round(zp,4):
            zp_sim = int(zp)
        else:
            zp_sim = round(zp,4)

        curr_sim_name = "J"+str(J_sim)+"_alpha"+str(amp_sim)+"_xp"+str(-xp_sim)+"_yp"+str(-yp_sim)+"_zp"+str(zp_sim)+"_alpha_prop"+str(int(amp_prop_sim))+"_blade_angle"+str(int(blade_angle))+"_"+rot_dir+"_"+thrust
        if curr_sim_name.replace(".","_")+"_"+comp_name_1 not in sim_name:
            new_sim_name += [curr_sim_name.replace(".","_")]
            amp          += [amp_sim]
            orientation  += [orientation_sim]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):
    
    # Clean screen and old dust output files
    sr.cleanup(output_file_loc,output_file_name,dust_sim_file_loc)

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    sim_name_Secloads = "Secloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    basename_Secloads = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)

    # fileWrapper parameters for current simulation
    references_parameters            = [str(amp[i]*math.pi/180),str(0.0),str(round(xp*c-c/4,6)),str(round(yp*bby2,6)),str(round(zp*r,6)),orientation[i],str(2*math.pi*vel/(J*2*r)),rot_axis,parent_1,parent_2,parent_3,parent_4,ref_tag_1,ref_tag_2,ref_tag_3,ref_tag_4]
    dust_pre_WP_parameters           = [os.path.join(wing_file_loc,wing_file),os.path.join(blade_file_dust_pre_loc,"blade.in")]
    dust_parameters                  = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_WP_parameters  = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name_1,comp_name_2]
    dustPost_SecLoads_W_parameters   = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name_1]

    # Create inputs for dust_wrap function
    dust_keys       = [references_key,dust_pre_WP_key,dust_key,dustPost_IntLoads_WP_key,dustPost_SecLoads_W_key]
    dust_parameters = [references_parameters,dust_pre_WP_parameters,dust_parameters,dustPost_IntLoads_WP_parameters,dustPost_SecLoads_W_parameters]
    dust_tmpl_files = ["References_tmpl.in","dust_pre_WP_tmpl.in","dust_tmpl.in","dustPost_IntLoads_WP_tmpl.in","dustPost_SecLoads_W_tmpl.in"]
    dust_files      = ["References.in","dust_pre.in","dust.in","dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.dust_wrap(dust_keys,dust_parameters,dust_tmpl_files,dust_files,input_file_loc)

    # Run dust_pre, dust and dust_post
    dust_post_files = ["dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.run_dust(dust_post_files=dust_post_files,input_file_loc=input_file_loc)

    # Copy files to sciebo
    '''Postpro_file_loc   = [Intloads_file_loc,Secloads_file_loc]
    sim_name_dust_post = [sim_name_Intloads,sim_name_Secloads]
    comp_name          = [comp_name_1,comp_name_2,comp_name_1]

    sr.copy_dust_post_files(sciebo_file_loc,sciebo_file,output_file_loc,output_file_name,Postpro_file_loc,sim_name_dust_post,comp_name,is_IntLoads=True,num_IntLoads=2,is_SecLoads=True,num_SecLoads=1)'''

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name_1

sim_name = sim_name+new_sim_name

########################## Spanwise Position Validation Studies ##########################

# Fixed variables for current simulation(s)
J           = 1.07
vel         = (1500/(0.5*density))**0.5
xp          = -0.2018/c
amp_prop    = 0.0
blade_angle = 25
orientation = "(/ -1.0,0.0,0.0, 0.0,1.0,0.0, 0.0,0.0,-1.0 /)"
parent_2    = "0"
thrust      = "LT"
rot_dir     = "IU"

# Create blade file  
if rot_dir == "IU":
    twist_1  = -blade_angle-0.75*twist
    twist_2  = -blade_angle+0.25*twist
    rot_axis = "(/-1.0, 0.0, 0.0/)"
elif rot_dir == "OU":
    twist_1  = blade_angle+0.75*twist
    twist_2  = blade_angle-0.25*twist
    rot_axis = "(/1.0, 0.0, 0.0/)"
        
blade_file_parameters = [chord_1,twist_1,span_1,sweep_1,dihed_1,nelem_span_1,chord_2,twist_2]
fw.wrap_file(os.path.join(blade_file_loc,"blade_tmpl.in"),os.path.join(blade_file_loc,"blade.in"),blade_file_key,blade_file_parameters)      

# Output file locations for current simulation(s)
output_file_name   = "wing_propeller"

# Variables for current simulation(s)
amp_range = [1.05,4.2]
#zp_range  = [-0.5085*x for x in range(-2,3)]
zp_range  = [0]
yp_range  = [-0.23-0.07*x for x in range(12)]

# Loop to create simulation data arrays
new_sim_name = []
amp          = []
yp           = []
zp           = []
for i in range(len(amp_range)):
    for j in range(len(zp_range)):
        for k in range(len(yp_range)):

            if int(amp_range[i]) == round(amp_range[i],2):
                amp_sim = int(amp_range[i])
            else:
                amp_sim = round(amp_range[i],2)

            if int(J) == round(J,3):
                J_sim = int(J)
            else:
                J_sim = round(J,3)

            if int(xp) == round(xp,3):
                xp_sim = int(xp)
            else:
                xp_sim = round(xp,3)

            if int(yp_range[k]) == round(yp_range[k],3):
                yp_sim = int(yp_range[k])
            else:
                yp_sim = round(yp_range[k],3)

            if int(zp_range[j]) == round(zp_range[j],4):
                zp_sim = int(zp_range[j])
            else:
                zp_sim = round(zp_range[j],4)

            curr_sim_name = "J"+str(J_sim)+"_alpha"+str(amp_sim)+"_xp"+str(-xp_sim)+"_yp"+str(-yp_sim)+"_zp"+str(zp_sim)+"_alpha_prop"+str(int(amp_prop))+"_blade_angle"+str(int(blade_angle))+"_"+rot_dir+"_"+thrust
            if curr_sim_name.replace(".","_")+"_"+comp_name_1 not in sim_name:
                new_sim_name += [curr_sim_name.replace(".","_")]
                amp          += [amp_sim]
                yp           += [yp_sim]
                zp           += [zp_sim]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):
    
    # Clean screen and old dust output files
    sr.cleanup(output_file_loc,output_file_name,dust_sim_file_loc)

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    sim_name_Secloads = "Secloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    basename_Secloads = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)

    # fileWrapper parameters for current simulation
    references_parameters            = [str(amp[i]*math.pi/180),str(0.0),str(round(xp*c-c/4,6)),str(round(yp[i]*bby2,6)),str(round(zp[i]*r,6)),orientation,str(2*math.pi*vel/(J*2*r)),rot_axis,parent_1,parent_2,parent_3,parent_4,ref_tag_1,ref_tag_2,ref_tag_3,ref_tag_4]
    dust_pre_WP_parameters           = [os.path.join(wing_file_loc,wing_file),os.path.join(blade_file_dust_pre_loc,"blade.in")]
    dust_parameters                  = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_WP_parameters  = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name_1,comp_name_2]
    dustPost_SecLoads_W_parameters   = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name_1]

    # Create inputs for dust_wrap function
    dust_keys       = [references_key,dust_pre_WP_key,dust_key,dustPost_IntLoads_WP_key,dustPost_SecLoads_W_key]
    dust_parameters = [references_parameters,dust_pre_WP_parameters,dust_parameters,dustPost_IntLoads_WP_parameters,dustPost_SecLoads_W_parameters]
    dust_tmpl_files = ["References_tmpl.in","dust_pre_WP_tmpl.in","dust_tmpl.in","dustPost_IntLoads_WP_tmpl.in","dustPost_SecLoads_W_tmpl.in"]
    dust_files      = ["References.in","dust_pre.in","dust.in","dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.dust_wrap(dust_keys,dust_parameters,dust_tmpl_files,dust_files,input_file_loc)

    # Run dust_pre, dust and dust_post
    dust_post_files = ["dustPost_IntLoads.in","dustPost_SecLoads.in"]
    dust_post_files = []

    sr.run_dust(dust_post_files=dust_post_files,input_file_loc=input_file_loc)

    # Copy files to sciebo
    '''Postpro_file_loc   = [Intloads_file_loc,Secloads_file_loc]
    sim_name_dust_post = [sim_name_Intloads,sim_name_Secloads]
    comp_name          = [comp_name_1,comp_name_2,comp_name_1]

    sr.copy_dust_post_files(sciebo_file_loc,sciebo_file,output_file_loc,output_file_name,Postpro_file_loc,sim_name_dust_post,comp_name,is_IntLoads=True,num_IntLoads=2,is_SecLoads=True,num_SecLoads=1)'''

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name_1

sim_name = sim_name+new_sim_name

'''########################## Chordwise Position Validation Studies ##########################

# Fixed variables for current simulation(s)
yp          = -0.3/bby2
zp          = (r+0.175*c)/r
amp         = 4.2
amp_prop    = 0.0
blade_angle = 25
rot_dir     = "IU"
orientation = "(/ -1.0,0.0,0.0, 0.0,1.0,0.0, 0.0,0.0,-1.0 /)"
parent_2    = "Wing"

# Create blade file  
if rot_dir == "IU":
    twist_1  = -blade_angle-0.75*twist
    twist_2  = -blade_angle+0.25*twist
    rot_axis = "(/-1.0, 0.0, 0.0/)"
elif rot_dir == "OU":
    twist_1  = blade_angle+0.75*twist
    twist_2  = blade_angle-0.25*twist
    rot_axis = "(/1.0, 0.0, 0.0/)"
        
blade_file_parameters = [chord_1,twist_1,span_1,sweep_1,dihed_1,nelem_span_1,chord_2,twist_2]
fw.wrap_file(os.path.join(blade_file_loc,"blade_tmpl.in"),os.path.join(blade_file_loc,"blade.in"),blade_file_key,blade_file_parameters)      

# Output file locations for current simulation(s)
output_file_name   = "wing_propeller"

# Variables for current simulation(s)
xp_range      = [0.1*x for x in range(-5,15)]
J_range       = [0.9,0.433]
vel_range     = [(1500/(0.5*density))**0.5,(245/(0.5*density))**0.5]
thrust_range  = ["LT","HT"]

# Loop to create simulation data arrays
new_sim_name = []
xp           = []
J            = []
vel          = []
for i in range(len(thrust_range)):
    for j in range(len(xp_range)):

        if int(amp) == round(amp,1):
            amp_sim = int(amp)
        else:
            amp_sim = round(amp,1)

        if int(J_range[i]) == round(J_range[i],3):
            J_sim = int(J_range[i])
        else:
            J_sim = round(J_range[i],3)

        if int(xp_range[j]) == round(xp_range[j],3):
            xp_sim = int(xp_range[j])
        else:
            xp_sim = round(xp_range[j],3)

        if int(yp) == round(yp,3):
            yp_sim = int(yp)
        else:
            yp_sim = round(yp,3)

        if int(zp) == round(zp,4):
            zp_sim = int(zp)
        else:
            zp_sim = round(zp,4)

        curr_sim_name = "J"+str(J_sim)+"_alpha"+str(amp_sim)+"_xp"+str(-xp_sim)+"_yp"+str(-yp_sim)+"_zp"+str(zp_sim)+"_alpha_prop"+str(int(amp_prop))+"_blade_angle"+str(int(blade_angle))+"_"+rot_dir+"_"+thrust_range[i]
        if curr_sim_name.replace(".","_")+"_"+comp_name_1 not in sim_name:
            new_sim_name += [curr_sim_name.replace(".","_")]
            vel          += [vel_range[i]]
            J            += [J_sim]
            xp           += [xp_sim]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):
    
    # Clean screen and old dust output files
    sr.cleanup(output_file_loc,output_file_name,dust_sim_file_loc)

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    sim_name_Secloads = "Secloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    basename_Secloads = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)

    # fileWrapper parameters for current simulation
    references_parameters            = [str(amp*math.pi/180),str(0.0),str(round(xp[i]*c-c/4,6)),str(round(yp*bby2,6)),str(round(zp*r,6)),orientation,str(2*math.pi*vel[i]/(J[i]*2*r)),rot_axis,parent_1,parent_2,parent_3,parent_4,ref_tag_1,ref_tag_2,ref_tag_3,ref_tag_4]
    dust_pre_WP_parameters           = [os.path.join(wing_file_loc,wing_file),os.path.join(blade_file_dust_pre_loc,"blade.in")]
    dust_parameters                  = [str(tf),str(dt),str(vel[i]),str(density),data_basename]
    dustPost_IntLoads_WP_parameters  = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name_1,comp_name_2]
    dustPost_SecLoads_W_parameters   = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name_1]

    # Create inputs for dust_wrap function
    dust_keys       = [references_key,dust_pre_WP_key,dust_key,dustPost_IntLoads_WP_key,dustPost_SecLoads_W_key]
    dust_parameters = [references_parameters,dust_pre_WP_parameters,dust_parameters,dustPost_IntLoads_WP_parameters,dustPost_SecLoads_W_parameters]
    dust_tmpl_files = ["References_tmpl.in","dust_pre_WP_tmpl.in","dust_tmpl.in","dustPost_IntLoads_WP_tmpl.in","dustPost_SecLoads_W_tmpl.in"]
    dust_files      = ["References.in","dust_pre.in","dust.in","dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.dust_wrap(dust_keys,dust_parameters,dust_tmpl_files,dust_files,input_file_loc)

    # Run dust_pre, dust and dust_post
    dust_post_files = ["dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.run_dust(dust_post_files=dust_post_files,input_file_loc=input_file_loc)

    # Copy files to sciebo
    #Postpro_file_loc   = [Intloads_file_loc,Secloads_file_loc]
    #sim_name_dust_post = [sim_name_Intloads,sim_name_Secloads]
    #comp_name          = [comp_name_1,comp_name_2,comp_name_1]

    #sr.copy_dust_post_files(sciebo_file_loc,sciebo_file,output_file_loc,output_file_name,Postpro_file_loc,sim_name_dust_post,comp_name,is_IntLoads=True,num_IntLoads=2,is_SecLoads=True,num_SecLoads=1)

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name_1

sim_name = sim_name+new_sim_name'''

'''########################## Vertical Position Validation Studies ##########################

# Fixed variables for current simulation(s)
xp          = -1.44*r/c
yp          = -0.281
amp_prop    = 0.0
blade_angle = 25
orientation = "(/ -1.0,0.0,0.0, 0.0,1.0,0.0, 0.0,0.0,-1.0 /)"
parent_2    = "0"
rot_dir     = "IU"

# Create blade file  
if rot_dir == "IU":
    twist_1  = -blade_angle-0.75*twist
    twist_2  = -blade_angle+0.25*twist
    rot_axis = "(/-1.0, 0.0, 0.0/)"
elif rot_dir == "OU":
    twist_1  = blade_angle+0.75*twist
    twist_2  = blade_angle-0.25*twist
    rot_axis = "(/1.0, 0.0, 0.0/)"
        
blade_file_parameters = [chord_1,twist_1,span_1,sweep_1,dihed_1,nelem_span_1,chord_2,twist_2]
fw.wrap_file(os.path.join(blade_file_loc,"blade_tmpl.in"),os.path.join(blade_file_loc,"blade.in"),blade_file_key,blade_file_parameters)      

# Output file locations for current simulation(s)
output_file_name   = "wing_propeller"

# Variables for current simulation(s)
amp_range     = [4*x for x in range(4)]
zp_range      = [0.1*x for x in range(-10,11)]
J_range       = [0.9,0.433]
vel_range     = [(1500/(0.5*density))**0.5,(245/(0.5*density))**0.5]
thrust_range  = ["LT","HT"]

# Loop to create simulation data arrays
new_sim_name = []
amp          = []
zp           = []
J            = []
vel          = []
for i in range(len(thrust_range)):
    for j in range(len(amp_range)):
        for k in range(len(zp_range)):

            if int(amp_range[j]) == round(amp_range[j],2):
                amp_sim = int(amp_range[j])
            else:
                amp_sim = round(amp_range[j],2)

            if int(J_range[i]) == round(J_range[i],3):
                J_sim = int(J_range[i])
            else:
                J_sim = round(J_range[i],3)

            if int(xp) == round(xp,3):
                xp_sim = int(xp)
            else:
                xp_sim = round(xp,3)

            if int(yp) == round(yp,3):
                yp_sim = int(yp)
            else:
                yp_sim = round(yp,3)

            if int(zp_range[k]) == round(zp_range[k],4):
                zp_sim = int(zp_range[k])
            else:
                zp_sim = round(zp_range[k],4)

            curr_sim_name = "J"+str(J_sim)+"_alpha"+str(amp_sim)+"_xp"+str(-xp_sim)+"_yp"+str(-yp_sim)+"_zp"+str(zp_sim)+"_alpha_prop"+str(int(amp_prop))+"_blade_angle"+str(int(blade_angle))+"_"+rot_dir+"_"+thrust_range[i]
            if curr_sim_name.replace(".","_")+"_"+comp_name_1 not in sim_name:
                new_sim_name += [curr_sim_name.replace(".","_")]
                amp          += [amp_sim]
                zp           += [zp_sim]
                J            += [J_sim]
                vel          += [vel_range[i]]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):
    
    # Clean screen and old dust output files
    sr.cleanup(output_file_loc,output_file_name,dust_sim_file_loc)

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    sim_name_Secloads = "Secloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    basename_Secloads = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)

    # fileWrapper parameters for current simulation
    references_parameters            = [str(amp[i]*math.pi/180),str(0.0),str(round(xp*c-c/4,6)),str(round(yp*bby2,6)),str(round(zp[i]*r,6)),orientation,str(2*math.pi*vel[i]/(J[i]*2*r)),rot_axis,parent_1,parent_2,parent_3,parent_4,ref_tag_1,ref_tag_2,ref_tag_3,ref_tag_4]
    dust_pre_WP_parameters           = [os.path.join(wing_file_loc,wing_file),os.path.join(blade_file_dust_pre_loc,"blade.in")]
    dust_parameters                  = [str(tf),str(dt),str(vel[i]),str(density),data_basename]
    dustPost_IntLoads_WP_parameters  = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name_1,comp_name_2]
    dustPost_SecLoads_W_parameters   = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name_1]

    # Create inputs for dust_wrap function
    dust_keys       = [references_key,dust_pre_WP_key,dust_key,dustPost_IntLoads_WP_key,dustPost_SecLoads_W_key]
    dust_parameters = [references_parameters,dust_pre_WP_parameters,dust_parameters,dustPost_IntLoads_WP_parameters,dustPost_SecLoads_W_parameters]
    dust_tmpl_files = ["References_tmpl.in","dust_pre_WP_tmpl.in","dust_tmpl.in","dustPost_IntLoads_WP_tmpl.in","dustPost_SecLoads_W_tmpl.in"]
    dust_files      = ["References.in","dust_pre.in","dust.in","dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.dust_wrap(dust_keys,dust_parameters,dust_tmpl_files,dust_files,input_file_loc)

    # Run dust_pre, dust and dust_post
    dust_post_files = ["dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.run_dust(dust_post_files=dust_post_files,input_file_loc=input_file_loc)

    ## Copy files to sciebo
    #Postpro_file_loc   = [Intloads_file_loc,Secloads_file_loc]
    #sim_name_dust_post = [sim_name_Intloads,sim_name_Secloads]
    #comp_name          = [comp_name_1,comp_name_2,comp_name_1]

    #sr.copy_dust_post_files(sciebo_file_loc,sciebo_file,output_file_loc,output_file_name,Postpro_file_loc,sim_name_dust_post,comp_name,is_IntLoads=True,num_IntLoads=2,is_SecLoads=True,num_SecLoads=1)

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name_1

sim_name = sim_name+new_sim_name'''
