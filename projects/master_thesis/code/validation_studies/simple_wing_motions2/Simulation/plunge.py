import fileWrapper as fw
import os
import math

# Fixed simulation file locations
input_file_loc     = "dust"
dust_sim_file_name = "wing"
dust_sim_file_loc  = "dust"
sim_name           = []

# Fixed output file locations
output_file_name   = "plunge"
output_file_loc    = "../Output"
Intloads_file_loc  = "Postpro/Intloads"

# Fixed model file locations
wing_file = "../Model/Wing/wing.in"

# Fixed model data
c = 1.0
b = 3.0

# Fixed fileWrapper keys
references_key        = ["@amp_plunge","@omega_plunge","@phase_plunge","@offset_plunge"]
dust_pre_key          = ["@wing_file"]
dust_key              = ["@tf","@dt","@vel","@density","@output_file"]
dustPost_IntLoads_key = ["@tf_res","@sim_name","@output_file","@comp_name"]

# Fixed simulation data
dt            = 0.0001
tf            = 0.1
density       = 1.225
vel           = 34.0
phase_plunge  = math.pi
offset_plunge = 0.0
comp_name     = "SD7003"

####################  Simulation Set 1  ####################

# Variables for current simulation
k_range         = [3.925]
h_range         = [0.025,0.05,0.075,0.1]

# Loop to create simulation data arrays
new_sim_name = []
h            = []
k            = []
for i in range(len(k_range)):
    for j in range(len(h_range)):

        k_sim         = round(k_range[i],4)
        h_sim         = round(h_range[j],3)

        curr_sim_name = "h"+str(h_sim)+"_k"+str(k_sim)+"_kh"+str(round(k_sim*h_sim,5))
        if curr_sim_name.replace(".","_")+"_"+comp_name not in sim_name:
            new_sim_name += [curr_sim_name.replace(".","_")]
            h            += [h_sim]
            k            += [k_sim]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):
    os.system("clear")

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)

    # fileWrapper parameters for current simulation
    references_parameters        = [str(round(h[i]*c,3)),str(2*k[i]*vel/c),str(phase_plunge),str(offset_plunge)]
    dust_pre_parameters          = [wing_file]
    dust_parameters              = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_parameters = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name]

    # fileWrapper used for all necessary files
    fw.wrap_file(os.path.join(input_file_loc,"References_plunge_tmpl.in"),os.path.join(input_file_loc,"References.in")       ,references_key       ,references_parameters)
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
h_range         = [0.1,0.05,0.025]

# Loop to create simulation data arrays
new_sim_name = []
h            = []
k            = []
for i in range(len(k_range)):

    k_sim         = round(k_range[i],4)
    h_sim         = round(h_range[i],3)

    curr_sim_name = "h"+str(h_sim)+"_k"+str(k_sim)+"_kh"+str(round(k_sim*h_sim,5))
    if curr_sim_name.replace(".","_")+"_"+comp_name not in sim_name:
        new_sim_name += [curr_sim_name.replace(".","_")]
        h            += [h_sim]
        k            += [k_sim]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):
    os.system("clear")

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)

    # fileWrapper parameters for current simulation
    references_parameters        = [str(round(h[i]*c,3)),str(2*k[i]*vel/c),str(phase_plunge),str(offset_plunge)]
    dust_pre_parameters          = [wing_file]
    dust_parameters              = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_parameters = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name]

    # fileWrapper used for all necessary files
    fw.wrap_file(os.path.join(input_file_loc,"References_tmpl.in")       ,os.path.join(input_file_loc,"References.in")       ,references_key       ,references_parameters)
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

####################  Simulation Set 3  ####################

# Variables for current simulation
k_range         = [3.925]
h_range         = [0.03,0.035,0.038,0.04]

# Loop to create simulation data arrays
new_sim_name = []
h            = []
k            = []
for i in range(len(k_range)):
    for j in range(len(h_range)):

        k_sim         = round(k_range[i],4)
        h_sim         = round(h_range[j],3)

        curr_sim_name = "h"+str(h_sim)+"_k"+str(k_sim)+"_kh"+str(round(k_sim*h_sim,5))
        if curr_sim_name.replace(".","_")+"_"+comp_name not in sim_name:
            new_sim_name += [curr_sim_name.replace(".","_")]
            h            += [h_sim]
            k            += [k_sim]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):
    os.system("clear")

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)

    # fileWrapper parameters for current simulation
    references_parameters        = [str(round(h[i]*c,3)),str(2*k[i]*vel/c),str(phase_plunge),str(offset_plunge)]
    dust_pre_parameters          = [wing_file]
    dust_parameters              = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_parameters = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name]

    # fileWrapper used for all necessary files
    fw.wrap_file(os.path.join(input_file_loc,"References_tmpl.in")       ,os.path.join(input_file_loc,"References.in")       ,references_key       ,references_parameters)
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