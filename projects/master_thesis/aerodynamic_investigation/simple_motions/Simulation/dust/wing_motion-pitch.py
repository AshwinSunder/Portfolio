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
blade_angle  = 25
chord_1      = 0.053
chord_2      = chord_1
span_1       = r
sweep_1      = 0.0
dihed_1      = 0.0
nelem_span_1 = 16
xp           = 0.25
yp           = -0.5
zp           = 0.0
xp_hub       = -0.2018/c

# Fixed model locations
wing_file_loc           = "../../Model/Wing"
wing_file               = "wing_prowim.in"
blade_file_loc          = "../../Model/Blades/"
blade_file_dust_pre_loc = "../../Model/Blades/"

# Fixed simulation data
tf          = 0.14995
dt          = 0.00005
vel         = 50.0
density     = 1.2
J           = 0.9
offset      = 0.0
amp_prop    = 0.0
omega_prop  = 0.0
phase_prop  = 0.0
offset_prop = 0.0
parent      = "Wing"

# Fixed reference data
comp_name_1 = "W"
comp_name_2 = "P"

# Fixed output file locations
output_file_loc    = "../../Output"
dust_sim_file_loc  = "dust"
Intloads_file_loc  = "Postpro/Intloads"
Secloads_file_loc  = "Postpro/Secloads"
output_file_name   = "wing_motion-pitch"

# Fixed fileWrapper keys
blade_file_key             = ["@chord_1","@twist_1","@span_1","@sweep_1","@dihed_1","@nelem_span_1","@chord_2","@twist_2"]
references_pitch_WP_key    = ["@amp","@omega","@phase","@offset","@prop_amp","@prop_omega","@prop_phase","@prop_offset","@xp","@yp","@zp","@hubxp","@rot_rate","@rot_axis","@parent","@ref_tag"]
dust_pre_W_key             = ["@wing_file"]
dust_pre_WP_key            = ["@wing_file","@blade_file"]
dust_key                   = ["@tf","@dt","@vel","@density","@output_file"]
dustPost_IntLoads_W_key    = ["@tf_res","@sim_name","@output_file","@comp_name_1"]
dustPost_IntLoads_WP_key   = ["@tf_res","@sim_name","@output_file","@comp_name_1","@comp_name_2"]
dustPost_SecLoads_W_key    = ["@tf_res","@sim_name","@output_file","@comp_name_1"]

# Fixed propeller data
rot_dir = "IU" 
twist_1  = -blade_angle-0.75*twist
twist_2  = -blade_angle+0.25*twist
rot_axis = "(/-1.0, 0.0, 0.0/)"
        
blade_file_parameters = [chord_1,twist_1,span_1,sweep_1,dihed_1,nelem_span_1,chord_2,twist_2]
fw.wrap_file(os.path.join(blade_file_loc,"blade_tmpl.in"),os.path.join(blade_file_loc,"blade.in"),blade_file_key,blade_file_parameters)

########################## Wing Motion Variation Studies ##########################
########################----- Wing+Propeller (Motion) -----########################

# Fixed variables for current simulation(s)
phase       = 0.0
ref_tag     = "Prop01"

# Output file locations for current simulation(s)
dust_sim_file_name = "wing_prop"

# Variables for current simulation(s)
omega_range        = [x*40*math.pi/3 for x in range(1,11)]
amp_range          = [1,2,4]

# Loop to create simulation data arrays
new_sim_name = []
omega        = []
amp          = []
for i in range(len(amp_range)):
    for j in range(len(omega_range)):

        if int(amp_range[i]) == round(amp_range[i],2):
            amp_sim = int(amp_range[i])
        else:
            amp_sim = round(amp_range[i],2)

        if int(J) == round(J,3):
            J_sim = int(J)
        else:
            J_sim = round(J,3)

        if int(omega_range[j]) == round(omega_range[j],6):
            omega_sim = int(omega_range[j])
        else:
            omega_sim = omega_range[j] 

        k_sim = round(omega_sim*c*0.5/vel,3)

        kprop_sim = int(round(omega_prop*c*0.5/vel,3))

        curr_sim_name = "J"+str(J_sim)+"_alpha"+str(amp_sim)+"_k"+str(k_sim)+"_alphaprop"+str(int(amp_prop))+"_kprop"+str(kprop_sim)+"_phaseprop"+str(int(phase_prop))
        if curr_sim_name.replace(".","_")+"_"+comp_name_1+comp_name_2 not in sim_name:
            new_sim_name += [curr_sim_name.replace(".","_")]
            amp          += [amp_sim]
            omega        += [omega_sim]

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
    references_pitch_WP_parameters   = [str(amp[i]*math.pi/180),str(omega[i]),str(phase),str(offset),str(amp_prop*math.pi/180),str(omega_prop),str(phase_prop),str(offset_prop),str(round(xp*c-c/4,6)),str(round(yp*bby2,6)),str(round(zp*r,6)),str(round(xp_hub*c-c/4,6)),str(2*math.pi*vel/(J*2*r)),rot_axis,parent,ref_tag]
    dust_pre_WP_parameters           = [os.path.join(wing_file_loc,wing_file),os.path.join(blade_file_dust_pre_loc,"blade.in")]
    dust_parameters                  = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_WP_parameters  = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name_1,comp_name_2]
    dustPost_SecLoads_W_parameters   = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name_1]

    # Create inputs for dust_wrap function
    dust_keys       = [references_pitch_WP_key,dust_pre_WP_key,dust_key,dustPost_IntLoads_WP_key,dustPost_SecLoads_W_key]
    dust_parameters = [references_pitch_WP_parameters,dust_pre_WP_parameters,dust_parameters,dustPost_IntLoads_WP_parameters,dustPost_SecLoads_W_parameters]
    dust_tmpl_files = ["References_pitch_WP_tmpl.in","dust_pre_WP_tmpl.in","dust_tmpl.in","dustPost_IntLoads_WP_tmpl.in","dustPost_SecLoads_W_tmpl.in"]
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

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name_1+comp_name_2

sim_name = sim_name+new_sim_name

########################----- Standalone Wing (Motion) -----########################

# Fixed variables for current simulation(s)
phase       = 0.0
ref_tag     = "NoProp"

# Output file locations for current simulation(s)
dust_sim_file_name = "wing"

# Variables for current simulation(s)
omega_range        = [x*40*math.pi/3 for x in range(1,11)]
amp_range          = [1,2,4]

# Loop to create simulation data arrays
new_sim_name = []
omega        = []
amp          = []
for i in range(len(amp_range)):
    for j in range(len(omega_range)):

        if int(amp_range[i]) == round(amp_range[i],2):
            amp_sim = int(amp_range[i])
        else:
            amp_sim = round(amp_range[i],2)

        if int(omega_range[j]) == round(omega_range[j],6):
            omega_sim = int(omega_range[j])
        else:
            omega_sim = omega_range[j]    
            
        k_sim = round(omega_sim*c*0.5/vel,3)

        curr_sim_name = "alpha"+str(amp_sim)+"_k"+str(k_sim)
        if curr_sim_name.replace(".","_")+"_"+comp_name_1 not in sim_name:
            new_sim_name += [curr_sim_name.replace(".","_")]
            amp          += [amp_sim]
            omega        += [omega_sim]

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
    references_pitch_WP_parameters    = [str(amp[i]*math.pi/180),str(omega[i]),str(phase),str(offset),str(amp_prop*math.pi/180),str(omega_prop),str(phase_prop),str(offset_prop),str(round(xp*c-c/4,6)),str(round(yp*bby2,6)),str(round(zp*r,6)),str(round(xp_hub*c-c/4,6)),str(2*math.pi*vel/(J*2*r)),rot_axis,parent,ref_tag]
    dust_pre_W_parameters            = [os.path.join(wing_file_loc,wing_file)]
    dust_parameters                  = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_W_parameters   = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name_1]
    dustPost_SecLoads_W_parameters   = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name_1]

    # Create inputs for dust_wrap function
    dust_keys       = [references_pitch_WP_key,dust_pre_W_key,dust_key,dustPost_IntLoads_W_key,dustPost_SecLoads_W_key]
    dust_parameters = [references_pitch_WP_parameters,dust_pre_W_parameters,dust_parameters,dustPost_IntLoads_W_parameters,dustPost_SecLoads_W_parameters]
    dust_tmpl_files = ["references_pitch_WP_tmpl.in","dust_pre_W_tmpl.in","dust_tmpl.in","dustPost_IntLoads_W_tmpl.in","dustPost_SecLoads_W_tmpl.in"]
    dust_files      = ["References.in","dust_pre.in","dust.in","dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.dust_wrap(dust_keys,dust_parameters,dust_tmpl_files,dust_files,input_file_loc)

    # Run dust_pre, dust and dust_post
    dust_post_files = ["dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.run_dust(dust_post_files=dust_post_files,input_file_loc=input_file_loc)

    # Copy files to sciebo
    '''Postpro_file_loc   = [Intloads_file_loc,Secloads_file_loc]
    sim_name_dust_post = [sim_name_Intloads,sim_name_Secloads]
    comp_name          = [comp_name_1,comp_name_1]

    sr.copy_dust_post_files(sciebo_file_loc,sciebo_file,output_file_loc,output_file_name,Postpro_file_loc,sim_name_dust_post,comp_name,is_IntLoads=True,num_IntLoads=1,is_SecLoads=True,num_SecLoads=1)'''

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name_1

sim_name = sim_name+new_sim_name

########################----- Wing+Propeller (Stationary) -----########################

# Fixed variables for current simulation(s)
omega       = 0.0
phase       = math.pi/2
ref_tag     = "Prop01"  

# Output file locations for current simulation(s)
dust_sim_file_name = "wing_prop"

# Variables for current simulation(s)
amp_range          = [1,2,4]

# Loop to create simulation data arrays
new_sim_name = []
amp          = []
for i in range(len(amp_range)):

    if int(amp_range[i]) == round(amp_range[i],2):
        amp_sim = int(amp_range[i])
    else:
        amp_sim = round(amp_range[i],2)

    if int(J) == round(J,3):
        J_sim = int(J)
    else:
        J_sim = round(J,3)   

    if int(omega*c*0.5/vel) == round(omega*c*0.5/vel,3):
        k_sim = int(omega*c*0.5/vel)
    else:
        k_sim = round(omega*c*0.5/vel,3) 

    kprop_sim = int(round(omega_prop*c*0.5/vel,3))

    curr_sim_name = "J"+str(J_sim)+"_alpha"+str(amp_sim)+"_k"+str(k_sim)+"_alphaprop"+str(int(amp_prop))+"_kprop"+str(kprop_sim)+"_phaseprop"+str(int(phase_prop))
    if curr_sim_name.replace(".","_")+"_"+comp_name_1+comp_name_2 not in sim_name:
        new_sim_name += [curr_sim_name.replace(".","_")]
        amp          += [amp_sim]

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
    references_pitch_WP_parameters   = [str(amp[i]*math.pi/180),str(omega),str(phase),str(offset),str(amp_prop*math.pi/180),str(omega_prop),str(phase_prop),str(offset_prop),str(round(xp*c-c/4,6)),str(round(yp*bby2,6)),str(round(zp*r,6)),str(round(xp_hub*c-c/4,6)),str(2*math.pi*vel/(J*2*r)),rot_axis,parent,ref_tag]
    dust_pre_WP_parameters           = [os.path.join(wing_file_loc,wing_file),os.path.join(blade_file_dust_pre_loc,"blade.in")]
    dust_parameters                  = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_WP_parameters  = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name_1,comp_name_2]
    dustPost_SecLoads_W_parameters   = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name_1]

    # Create inputs for dust_wrap function
    dust_keys       = [references_pitch_WP_key,dust_pre_WP_key,dust_key,dustPost_IntLoads_WP_key,dustPost_SecLoads_W_key]
    dust_parameters = [references_pitch_WP_parameters,dust_pre_WP_parameters,dust_parameters,dustPost_IntLoads_WP_parameters,dustPost_SecLoads_W_parameters]
    dust_tmpl_files = ["references_pitch_WP_tmpl.in","dust_pre_WP_tmpl.in","dust_tmpl.in","dustPost_IntLoads_WP_tmpl.in","dustPost_SecLoads_W_tmpl.in"]
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

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name_1+comp_name_2

sim_name = sim_name+new_sim_name

########################----- Standalone Wing (Stationary) -----########################

# Fixed variables for current simulation(s)
omega       = 0.0
phase       = math.pi/2
ref_tag     = "NoProp" 

# Output file locations for current simulation(s)
dust_sim_file_name = "wing"

# Variables for current simulation(s)
amp_range          = [1,2,4]

# Loop to create simulation data arrays
new_sim_name = []
amp          = []
for i in range(len(amp_range)):

        if int(amp_range[i]) == round(amp_range[i],2):
            amp_sim = int(amp_range[i])
        else:
            amp_sim = round(amp_range[i],2)

        if int(omega) == round(omega,6):
            omega_sim = int(omega)
        else:
            omega_sim = omega   
            
        k_sim = round(omega_sim*c*0.5/vel,3)

        curr_sim_name = "alpha"+str(amp_sim)+"_k"+str(k_sim)
        if curr_sim_name.replace(".","_")+"_"+comp_name_1 not in sim_name:
            new_sim_name += [curr_sim_name.replace(".","_")]
            amp          += [amp_sim]

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
    references_pitch_WP_parameters   = [str(amp[i]*math.pi/180),str(omega),str(phase),str(offset),str(amp_prop*math.pi/180),str(omega_prop),str(phase_prop),str(offset_prop),str(round(xp*c-c/4,6)),str(round(yp*bby2,6)),str(round(zp*r,6)),str(round(xp_hub*c-c/4,6)),str(2*math.pi*vel/(J*2*r)),rot_axis,parent,ref_tag]
    dust_pre_W_parameters            = [os.path.join(wing_file_loc,wing_file)]
    dust_parameters                  = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_W_parameters   = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name_1]
    dustPost_SecLoads_W_parameters   = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name_1]

    # Create inputs for dust_wrap function
    dust_keys       = [references_pitch_WP_key,dust_pre_W_key,dust_key,dustPost_IntLoads_W_key,dustPost_SecLoads_W_key]
    dust_parameters = [references_pitch_WP_parameters,dust_pre_W_parameters,dust_parameters,dustPost_IntLoads_W_parameters,dustPost_SecLoads_W_parameters]
    dust_tmpl_files = ["references_pitch_WP_tmpl.in","dust_pre_W_tmpl.in","dust_tmpl.in","dustPost_IntLoads_W_tmpl.in","dustPost_SecLoads_W_tmpl.in"]
    dust_files      = ["References.in","dust_pre.in","dust.in","dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.dust_wrap(dust_keys,dust_parameters,dust_tmpl_files,dust_files,input_file_loc)

    # Run dust_pre, dust and dust_post
    dust_post_files = ["dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.run_dust(dust_post_files=dust_post_files,input_file_loc=input_file_loc)

    # Copy files to sciebo
    '''Postpro_file_loc   = [Intloads_file_loc,Secloads_file_loc]
    sim_name_dust_post = [sim_name_Intloads,sim_name_Secloads]
    comp_name          = [comp_name_1,comp_name_1]

    sr.copy_dust_post_files(sciebo_file_loc,sciebo_file,output_file_loc,output_file_name,Postpro_file_loc,sim_name_dust_post,comp_name,is_IntLoads=True,num_IntLoads=1,is_SecLoads=True,num_SecLoads=1)'''

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name_1

sim_name = sim_name+new_sim_name

