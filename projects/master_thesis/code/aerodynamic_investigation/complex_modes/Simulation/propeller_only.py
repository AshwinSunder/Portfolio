# Required header files
import fileWrapper as fw
import simRunner as sr
import os
import math
import shutil

# Fixed file locations
input_file_loc  = "dust"
#sciebo_file_loc = ".../.../..."
#sciebo_file     = ".../.../..."
sim_name        = []

# Fixed model data
r            = 0.762
bby2         = 6.096
c            = 1.8288
rot_dir      = "OU"

# Fixed model locations
blade_file_loc          = "../Model/Blades/"

# Fixed simulation data
tf          = 0.1000
dt          = 0.0002
density     = 1.225
vel         = 50.0
xp          = 0.0
yp          = 0.0
zp          = 0.0
hubxp       = 1.0
rot_axis    = "(/1.0, 0.0, 0.0/)"
ref_tag_1   = "NoWing"
ref_tag_2   = "Prop01"
comp_name_1 = "P"

# Fixed output file locations
output_file_name  = "prop_only"
output_file_loc    = "../Output"
dust_sim_file_name = "prop"
dust_sim_file_loc  = "dust"
Intloads_file_loc  = "Postpro/Intloads"
Secloads_file_loc  = "Postpro/Secloads"

# Fixed fileWrapper keys
references_key             = ["@xp","@yp","@zp","@hubxp","@rot_rate","@rot_axis","@ref_tag_1","@ref_tag_2"]
dust_pre_P_key             = ["@blade_file"]
dust_key                   = ["@tf","@dt","@vel","@density","@output_file"]
dustPost_IntLoads_P_key    = ["@tf_res","@sim_name","@output_file","@comp_name_1"]
dustPost_SecLoads_P_key    = ["@tf_res","@sim_name","@output_file","@comp_name_1"]

########################## Complex Modes Studies ##########################
########################----- Propeller Only ------########################

# Variables for current simulation(s)
J_range     = [0.1*x for x in range(5,18)]

# Loop to create simulation data arrays
new_sim_name = []
rot_rate     = []
for i in range(len(J_range)):

    if round(J_range[i],1) == int(J_range[i]):
        J_sim = int(J_range[i])
    else:
        J_sim = round(J_range[i],1)

        rot_rate_sim = 2*math.pi*vel/(J_sim*2*r)

        curr_sim_name = "J"+str(J_sim)
        if curr_sim_name.replace(".","_")+"_"+comp_name_1 not in sim_name:
            new_sim_name += [curr_sim_name.replace(".","_")]
            rot_rate     += [rot_rate_sim]

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
    references_parameters           = [xp,yp,zp,hubxp,rot_rate[i],rot_axis,ref_tag_1,ref_tag_2]
    dust_pre_P_parameters           = [os.path.join(blade_file_loc,"blade.in")]
    dust_parameters                 = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_P_parameters  = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name_1]
    dustPost_SecLoads_P_parameters  = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name_1]

    # Create inputs for dust_wrap function
    dust_keys       = [references_key,dust_pre_P_key,dust_key,dustPost_IntLoads_P_key,dustPost_SecLoads_P_key]
    dust_parameters = [references_parameters,dust_pre_P_parameters,dust_parameters,dustPost_IntLoads_P_parameters,dustPost_SecLoads_P_parameters]
    dust_tmpl_files = ["References_tmpl.in","dust_pre_P_tmpl.in","dust_tmpl.in","dustPost_IntLoads_P_tmpl.in","dustPost_SecLoads_P_tmpl.in"]
    dust_files      = ["References.in","dust_pre.in","dust.in","dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.dust_wrap(dust_keys,dust_parameters,dust_tmpl_files,dust_files,input_file_loc)

    # Run dust_pre, dust and dust_post
    dust_post_files = ["dustPost_IntLoads.in","dustPost_SecLoads.in"]

    try:
        sr.run_dust(dust_post_files=dust_post_files,input_file_loc=input_file_loc)

        # Copy files to sciebo
        '''Postpro_file_loc   = [Intloads_file_loc,Secloads_file_loc]
        sim_name_dust_post = [sim_name_Intloads,sim_name_Secloads]
        comp_name          = [comp_name_1,comp_name_1]

        sr.copy_dust_post_files(sciebo_file_loc,sciebo_file,output_file_loc,output_file_name,Postpro_file_loc,sim_name_dust_post,comp_name,is_IntLoads=True,num_IntLoads=1,is_SecLoads=True,num_SecLoads=1)'''

        new_sim_name[i] = new_sim_name[i]+"_"+comp_name_1

    except:
        sim_name = sim_name+new_sim_name[i]
        continue

#sr.cleanup(output_file_loc,output_file_name,dust_sim_file_loc)