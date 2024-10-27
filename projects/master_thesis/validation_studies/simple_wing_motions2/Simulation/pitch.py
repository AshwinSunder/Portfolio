import fileWrapper as fw
import os
import math

# Fixed simulation file locations
input_file_loc     = "dust"
dust_sim_file_name = "wing"
dust_sim_file_loc  = "dust"
sim_name           = []

# Fixed output file locations
output_file_name   = "pitch"
output_file_loc    = "../Output"
Intloads_file_loc  = "Postpro/Intloads"

# Fixed model file locations
wing_file = "../Model/Wing/wing.in"

# Fixed model data
c = 1.0
b = 3.0

# Fixed fileWrapper keys
references_key        = ["@amp_pitch","@omega_pitch","@phase_pitch","@offset_pitch"]
dust_pre_key          = ["@wing_file"]
dust_key              = ["@tf","@dt","@vel","@density","@output_file"]
dustPost_IntLoads_key = ["@tf_res","@sim_name","@output_file","@comp_name"]

# Fixed simulation data
dt            = 0.0001
tf            = 0.1
density       = 1.225
vel           = 34.0
phase_pitch   = 0.0
offset_pitch  = 0.0
comp_name     = "SD7003"

####################  Simulation Set 1  ####################

# Variables for current simulation
k_range         = [3.925]
amp_range       = [3,6,12]

# Loop to create simulation data arrays
new_sim_name = []
k            = []
amp          = []
for i in range(len(k_range)):
    for j in range(len(amp_range)):

        k_sim         = round(k_range[i],4)
        amp_sim       = amp_range[j]

        curr_sim_name = "alpha"+str(amp_sim)+"_k"+str(k_sim)+"_ka0"+str(round(k_sim*amp_sim,3))
        if curr_sim_name.replace(".","_")+"_"+comp_name not in sim_name:
            new_sim_name += [curr_sim_name.replace(".","_")]
            amp          += [amp_sim]
            k            += [k_sim]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):
    os.system("clear")

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)

    # fileWrapper parameters for current simulation
    references_parameters        = [str(amp[i]*math.pi/180),str(2*k[i]*vel/c),str(phase_pitch),str(offset_pitch)]
    dust_pre_parameters          = [wing_file]
    dust_parameters              = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_parameters = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name]

    # fileWrapper used for all necessary files
    fw.wrap_file(os.path.join(input_file_loc,"References_pitch_tmpl.in") ,os.path.join(input_file_loc,"References.in")       ,references_key       ,references_parameters)
    fw.wrap_file(os.path.join(input_file_loc,"dust_pre_tmpl.in")         ,os.path.join(input_file_loc,"dust_pre.in")         ,dust_pre_key         ,dust_pre_parameters)
    fw.wrap_file(os.path.join(input_file_loc,"dust_tmpl.in")             ,os.path.join(input_file_loc,"dust.in")             ,dust_key             ,dust_parameters)
    fw.wrap_file(os.path.join(input_file_loc,"dustPost_IntLoads_tmpl.in"),os.path.join(input_file_loc,"dustPost_IntLoads.in"),dustPost_IntLoads_key,dustPost_IntLoads_parameters)
    
    os.system("rm -rf "+os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,"*")) # Clear all previous dust simulation files (safer to do so)

    # Run dust_pre, dust and dust_post
    os.system("dust_pre "  + os.path.join(input_file_loc,"dust_pre.in"))
    os.system("dust "      + os.path.join(input_file_loc,"dust.in"))
    os.system("dust_post " + os.path.join(input_file_loc,"dustPost_IntLoads.in"))

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name

sim_name += new_sim_name

####################  Simulation Set 2  ####################

# Variables for current simulation
k_range         = [1.9625,3.925,7.85]
amp_range       = [6,3,1.5]

# Loop to create simulation data arrays
new_sim_name = []
k            = []
amp          = []
for i in range(len(k_range)):

    k_sim         = round(k_range[i],4)
    amp_sim       = amp_range[i]

    curr_sim_name = "alpha"+str(amp_sim)+"_k"+str(k_sim)+"_ka0"+str(round(k_sim*amp_sim,3))
    if curr_sim_name.replace(".","_")+"_"+comp_name not in sim_name:
        new_sim_name += [curr_sim_name.replace(".","_")]
        amp          += [amp_sim]
        k            += [k_sim]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):
    os.system("clear")

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)

    # fileWrapper parameters for current simulation
    references_parameters        = [str(amp[i]*math.pi/180),str(2*k[i]*vel/c),str(phase_pitch),str(offset_pitch)]
    dust_pre_parameters          = [wing_file]
    dust_parameters              = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_parameters = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name]

    # fileWrapper used for all necessary files
    fw.wrap_file(os.path.join(input_file_loc,"References_tmpl_2.in")     ,os.path.join(input_file_loc,"References.in")       ,references_key       ,references_parameters)
    fw.wrap_file(os.path.join(input_file_loc,"dust_pre_tmpl.in")         ,os.path.join(input_file_loc,"dust_pre.in")         ,dust_pre_key         ,dust_pre_parameters)
    fw.wrap_file(os.path.join(input_file_loc,"dust_tmpl.in")             ,os.path.join(input_file_loc,"dust.in")             ,dust_key             ,dust_parameters)
    fw.wrap_file(os.path.join(input_file_loc,"dustPost_IntLoads_tmpl.in"),os.path.join(input_file_loc,"dustPost_IntLoads.in"),dustPost_IntLoads_key,dustPost_IntLoads_parameters)
    
    os.system("rm -rf "+os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,"*")) # Clear all previous dust simulation files (safer to do so)

    # Run dust_pre, dust and dust_post
    os.system("dust_pre "  + os.path.join(input_file_loc,"dust_pre.in"))
    os.system("dust "      + os.path.join(input_file_loc,"dust.in"))
    os.system("dust_post " + os.path.join(input_file_loc,"dustPost_IntLoads.in"))

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name

sim_name += new_sim_name
