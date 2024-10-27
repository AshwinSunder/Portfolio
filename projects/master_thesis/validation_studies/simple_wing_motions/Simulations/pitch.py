import fileWrapper as fw
import simRunner as sr
import os
import math
import shutil

# Fixed simulation file locations
input_file_loc     = "dust"
dust_sim_file_name = "wing"
dust_sim_file_loc  = "dust"
#sciebo_file_loc = ".../.../..."
#sciebo_file     = ".../.../..."
sim_name           = []

# Fixed output file locations
output_file_name   = "pitch"
output_file_loc    = "../Output"
cleanup_file_loc   = "../Output"
Intloads_file_loc  = "Postpro/Intloads"
Secloads_file_loc  = "Postpro/Secloads"

# Fixed model file locations
wing_files = ["../Model/Wing/wing_0004.in","../Model/Wing/wing_prowim.in","../Model/Wing/wing_0024.in"]
comp_names = ["NACA0004","NACA64a015","NACA0024"]

# Fixed model data
c = 0.24
b = 1.28

# Fixed fileWrapper keys
references_key        = ["@amp_pitch","@omega_pitch","@phase_pitch","@offset_pitch","@amp_plunge","@omega_plunge","@phase_plunge","@offset_plunge"]
dust_pre_key          = ["@wing_file"]
dust_key              = ["@tf","@dt","@vel","@density","@output_file"]
dustPost_IntLoads_key = ["@tf_res","@sim_name","@output_file","@comp_name"]
dustPost_SecLoads_key = ["@tf_res","@sim_name","@output_file","@comp_name"]

# Fixed simulation data
tf            = 0.14995
dt            = 0.00005
density       = 1.2
vel           = 50.0
phase_pitch   = 0.0
offset_pitch  = 0.0
amp_plunge    = 0.0
phase_plunge  = 0.0
omega_plunge  = 0.0
offset_plunge = 0.0

####################  Simulation Set 1  ####################

# Variables for current simulation
omega_pitch_range  = [40*math.pi*x/3 for x in range(1,11)]
amp_pitch_range    = [1,2,4]

# Loop to create simulation data arrays
new_sim_name = []
amp_pitch    = []
omega_pitch  = []
comp_name    = []
wing_file    = []
for j in range(len(comp_names)):
    for i in range(len(amp_pitch_range)):
            for l in range(len(omega_pitch_range)):

                amp_pitch_sim    = amp_pitch_range[i]

                k_sim         = round(omega_pitch_range[l]*c/(2*vel),3)

                curr_sim_name = "alpha"+str(amp_pitch_sim)+"_k"+str(k_sim)
                if curr_sim_name.replace(".","_")+"_"+comp_names[j] not in sim_name:
                    new_sim_name += [curr_sim_name.replace(".","_")]
                    amp_pitch    += [amp_pitch_sim]
                    omega_pitch  += [omega_pitch_range[l]]
                    comp_name    += [comp_names[j]]
                    wing_file    += [wing_files[j]]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):
    sr.cleanup(cleanup_file_loc,output_file_name,dust_sim_file_loc)

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    sim_name_Secloads = "Secloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    basename_Secloads = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)

    # fileWrapper parameters for current simulation
    references_parameters        = [str(amp_pitch[i]*math.pi/180),str(omega_pitch[i]),str(phase_pitch),str(offset_pitch),str(amp_plunge),str(omega_plunge),str(phase_plunge),str(offset_plunge)]
    dust_pre_parameters          = [wing_file[i]]
    dust_parameters              = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_parameters = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name[i]]
    dustPost_SecLoads_parameters = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name[i]]

    # fileWrapper used for all necessary files
    dust_keys       = [references_key,dust_pre_key,dust_key,dustPost_IntLoads_key,dustPost_SecLoads_key]
    dust_parameters = [references_parameters,dust_pre_parameters,dust_parameters,dustPost_IntLoads_parameters,dustPost_SecLoads_parameters]
    dust_tmpl_files = ["References_tmpl.in","dust_pre_tmpl.in","dust_tmpl.in","dustPost_IntLoads_tmpl.in","dustPost_SecLoads_tmpl.in"]
    dust_files      = ["References.in","dust_pre.in","dust.in","dustPost_IntLoads.in","dustPost_SecLoads.in"]

    sr.dust_wrap(dust_keys,dust_parameters,dust_tmpl_files,dust_files,input_file_loc)

    # Run dust_pre, dust and dust_post
    dust_post_files = ["dustPost_IntLoads.in","dustPost_SecLoads.in"]

    try:
        sr.run_dust(dust_post_files=dust_post_files,input_file_uncoupled_loc=input_file_loc,input_file_coupled_loc=".",coupled=False)

        # Copy files to sciebo
        '''Postpro_file_loc   = [Intloads_file_loc,Secloads_file_loc]
        sim_name_dust_post = [sim_name_Intloads,sim_name_Secloads]
        comp_name2         = [comp_name[i],comp_name[i]]

        sr.copy_dust_post_files(sciebo_file_loc,sciebo_file,output_file_loc,output_file_name,Postpro_file_loc,sim_name_dust_post,comp_name2,is_IntLoads=True,num_IntLoads=1,is_SecLoads=True,num_SecLoads=1)'''

        new_sim_name[i] = new_sim_name[i]+"_"+comp_name[i]
        
        sim_name = sim_name+[new_sim_name[i]]

    except:
        continue

sr.cleanup(cleanup_file_loc,output_file_name,dust_sim_file_loc)
