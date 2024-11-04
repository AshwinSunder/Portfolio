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
bby2         = 6.096
c            = 1.8288

# Fixed model locations
wing_file_loc          = "../../Model/Wing/"
blade_file_loc         = "../../Model/Blades/"

# Fixed simulation data
dt          = 0.0005
density     = 1.225
vel         = 50.0
comp_name_1 = "W"
comp_name_2 = "P"

# Write dt in a text file for preCICE
with open(os.path.join("dt.txt"),'w+') as f:
    f.write(f"{str(dt)}\n")

# Fixed output file locations
output_file_name  = "wing_propeller"
output_file_loc    = "../../Output"
cleanup_file_loc   = "../Output"
dust_sim_file_name = "wing_prop"
dust_sim_file_loc  = "dust"
Intloads_file_loc  = "Postpro/Intloads"
Secloads_file_loc  = "Postpro/Secloads"

# Fixed fileWrapper keys
dust_pre_WP_key            = ["@wing_file","@blade_file1","@blade_file2","@blade_file3","@blade_file4"]
dust_key                   = ["@tf","@dt","@vel","@density","@output_file"]
dustPost_IntLoads_WP_key   = ["@tf_res","@sim_name","@output_file","@comp_name_1","@comp_name_2"]
dustPost_SecLoads_W_key    = ["@tf_res","@sim_name","@output_file","@comp_name_1"]

########################## Complex Modes Studies ##########################
########################----- Wing+Propeller ------########################

# Variables for current simulation(s)
mode_range     = [1,2]
prop_pos_range = [0.5,0.75,1]
k_range        = [0.05,0.125,0.25,0.375,0.5,0.625,0.75,0.875,1.0]

# Loop to create simulation data arrays
new_sim_name = []
tf           = []
for j in range(len(prop_pos_range)):
    for i in range(len(mode_range)):
        for k in range(len(k_range)):

            mode_sim = int(mode_range[i])
            if round(prop_pos_range[j],1) == int(prop_pos_range[j]):
                prop_pos_sim = int(prop_pos_range[j])
            else:
                prop_pos_sim = round(prop_pos_range[j],1)

            if round(k_range[k],2) == int(k_range[k]):
                k_sim = int(k_range[k])
            else:
                k_sim = round(k_range[k],2)

            T = math.pi*c/(vel*k_sim)
            tf_sim = round(round(1.5*T,3)+101*dt,4)

            curr_sim_name = "wing_propeller_mode"+str(mode_sim)+"_y"+str(prop_pos_sim)+"_k"+str(k_sim)
            if curr_sim_name.replace(".","_")+"_"+comp_name_1+comp_name_2 not in sim_name:
                new_sim_name += [curr_sim_name.replace(".","_")]
                tf           += [tf_sim]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):

    # Clean screen and old dust output files
    sr.cleanup(cleanup_file_loc,output_file_name,dust_sim_file_loc)

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    sim_name_Secloads = "Secloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    basename_Secloads = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)   

    # fileWrapper parameters for current simulation
    dust_pre_WP_parameters          = [os.path.join(wing_file_loc,"goland_wing.in"),os.path.join(blade_file_loc,"blade1.in"),os.path.join(blade_file_loc,"blade2.in"),
                                        os.path.join(blade_file_loc,"blade3.in"),os.path.join(blade_file_loc,"blade4.in")]
    dust_parameters                 = [str(tf[i]),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_WP_parameters = [str(int(round(tf[i]/dt,0))),basename_Intloads,data_basename,comp_name_1,comp_name_2]
    dustPost_SecLoads_W_parameters  = [str(int(round(tf[i]/dt,0))),basename_Secloads,data_basename,comp_name_1]

    # Create inputs for dust_wrap function
    dust_keys       = [dust_pre_WP_key,dust_key,dustPost_IntLoads_WP_key,dustPost_SecLoads_W_key]
    dust_parameters = [dust_pre_WP_parameters,dust_parameters,dustPost_IntLoads_WP_parameters,dustPost_SecLoads_W_parameters]
    dust_tmpl_files = ["dust_pre_WP_tmpl.in","dust_tmpl.in","dustPost_IntLoads_WP_tmpl.in","dustPost_SecLoads_W_tmpl.in"]
    dust_files      = ["dust_pre.in","dust.in","dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.dust_wrap(dust_keys,dust_parameters,dust_tmpl_files,dust_files,input_file_loc)

    # Run dust_pre, dust and dust_post
    dust_post_files = ["dustPost_IntLoads.in","dustPost_SecLoads.in"]

    try:
        sr.run_dust(dust_post_files=dust_post_files,input_file_uncoupled_loc=input_file_loc,input_file_coupled_loc=".",coupled=True)

        # Copy files to sciebo
        '''Postpro_file_loc   = [Intloads_file_loc,Secloads_file_loc]
        sim_name_dust_post = [sim_name_Intloads,sim_name_Secloads]
        comp_name          = [comp_name_1,comp_name_2,comp_name_1]

        sr.copy_dust_post_files(sciebo_file_loc,sciebo_file,cleanup_file_loc,output_file_name,Postpro_file_loc,sim_name_dust_post,comp_name,is_IntLoads=True,num_IntLoads=2,is_SecLoads=True,num_SecLoads=1)'''

        new_sim_name[i] = new_sim_name[i]+"_"+comp_name_1
        
        sim_name = sim_name+[new_sim_name[i]]

    except:
        continue

#sr.cleanup(cleanup_file_loc,output_file_name,dust_sim_file_loc)