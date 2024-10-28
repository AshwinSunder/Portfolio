# Required header files
import fileWrapper as fw
import os
import math
import shutil

# Fixed file locations
input_file_loc  = "."
#sciebo_file_loc = ".../.../..."
#sciebo_file     = ".../.../..."
sim_name        = []

# Fixed model data
r    = 0.118
bby2 = 0.64
c    = 0.24

# Fixed simulation data
tf          = 0.0598
dt          = 0.0002
vel         = 50.0
density     = round(1500/(0.5*vel**2),3) # Sea level
xp          = -0.2018/c
yp          = -0.3/bby2
zp          = 0.0
orientation = "(/ -1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, -1.0 /)"
amp_prop    = 0.0

# Fixed output file locations
output_file_loc    = "../../Output"
dust_sim_file_name = "wing"
dust_sim_file_loc  = "dust"
Intloads_file_loc  = "Postpro/Intloads"
Secloads_file_loc  = "Postpro/Secloads"

# Fixed model file locations
wing_file      = "../../Model/Wing/wing_prowim.in"

# Fixed fileWrapper keys
references_key             = ["@amp","@xp1","@xp2","@yp","@zp","@orientation","@rot_rate","@rot_axis","@parent_1","@parent_2","@parent_3","@parent_4","@ref_tag_1","@ref_tag_2","@ref_tag_3","@ref_tag_4"]
dust_pre_W_key             = ["@wing_file"]
dust_key                   = ["@tf","@dt","@vel","@density","@output_file"]
dustPost_IntLoads_key      = ["@tf_res","@sim_name","@output_file","@comp_name"]
dustPost_SecLoads_key      = ["@tf_res","@sim_name","@output_file","@comp_name"]

########################## Simulation set 1 ##########################

# Fixed variables for current simulation(s)
J           = 0.0
rot_axis    = "(/-1.0, 0.0, 0.0/)"
parent_1    = "0"
ref_tag_1   = "Wing"
parent_2    = "Wing"
ref_tag_2   = "PivotPoint"
parent_3    = "PivotPoint"
ref_tag_3   = "Hub01"
parent_4    = "Hub01"
ref_tag_4   = "NoProp"
comp_name   = "W"

# Output file locations for current simulation(s)
output_file_name   = "wing_only"

# Variables for current simulation(s)
amp_range  = [int(x) for x in range(-15,16)]

# Loop to create simulation data arrays
new_sim_name = []
amp          = []
for i in range(len(amp_range)):
                
    amp_sim         = amp_range[i]

    curr_sim_name = "alpha"+str(amp_sim)
    if curr_sim_name.replace(".","_")+"_"+comp_name not in sim_name:
        new_sim_name += [curr_sim_name.replace(".","_")]
        amp          += [amp_sim]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):

    os.system("clear")
    os.system("rm -rf "+os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,"*")) # Clear previous simulation dust files (safer to do so)
    
    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    sim_name_Secloads = "Secloads_"+new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    basename_Secloads = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)
  
    # fileWrapper parameters for current simulation
    references_parameters         = [str(amp[i]*math.pi/180),str(0.0),str(round(-xp*c-c/4,6)),str(round(yp*bby2,6)),str(round(zp*r,6)),orientation,str(0.0),rot_axis,parent_1,parent_2,parent_3,parent_4,ref_tag_1,ref_tag_2,ref_tag_3,ref_tag_4]
    dust_pre_W_parameters         = [wing_file]
    dust_parameters               = [str(tf),str(dt),str(vel),str(density),data_basename]
    dustPost_IntLoads_parameters  = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name]
    dustPost_SecLoads_parameters  = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name]

    # fileWrapper used for References.in, dust_pre.in and dust.in files
    fw.wrap_file(os.path.join(input_file_loc,"References_tmpl.in")         ,os.path.join(input_file_loc,"References.in")       ,references_key        ,references_parameters)
    fw.wrap_file(os.path.join(input_file_loc,"dust_pre_W_tmpl.in")         ,os.path.join(input_file_loc,"dust_pre.in")         ,dust_pre_W_key        ,dust_pre_W_parameters)
    fw.wrap_file(os.path.join(input_file_loc,"dust_tmpl.in")               ,os.path.join(input_file_loc,"dust.in")             ,dust_key              ,dust_parameters)

    # Rust dust_pre and dust
    os.system("dust_pre "  + os.path.join(input_file_loc,"dust_pre.in"))
    os.system("dust "      + os.path.join(input_file_loc,"dust.in"))

    # run fileWrapper+dust_post
    fw.wrap_file(os.path.join(input_file_loc,"dustPost_IntLoads_W_tmpl.in"),os.path.join(input_file_loc,"dustPost_IntLoads.in"),dustPost_IntLoads_key ,dustPost_IntLoads_parameters)
    os.system("dust_post " + os.path.join(input_file_loc,"dustPost_IntLoads.in"))

    fw.wrap_file(os.path.join(input_file_loc,"dustPost_SecLoads_W_tmpl.in"),os.path.join(input_file_loc,"dustPost_SecLoads.in"),dustPost_SecLoads_key ,dustPost_SecLoads_parameters)
    os.system("dust_post " + os.path.join(input_file_loc,"dustPost_SecLoads.in"))

    # Copy files to sciebo
    '''source_Intloads_W      = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads+"_"+comp_name+".dat")
    destination_Intloads_W = os.path.join(sciebo_file_loc,sciebo_file,output_file_name,Intloads_file_loc)

    source_Secloads_Fx_W   = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads+"_"+comp_name+"_Fx.dat")
    source_Secloads_Fy_W   = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads+"_"+comp_name+"_Fy.dat")
    source_Secloads_Fz_W   = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads+"_"+comp_name+"_Fz.dat")
    source_Secloads_Mo_W   = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads+"_"+comp_name+"_Mo.dat")
    destination_Secloads_W = os.path.join(sciebo_file_loc,sciebo_file,output_file_name,Secloads_file_loc)

    try:
        shutil.copy2(source_Intloads_W,destination_Intloads_W)
        shutil.copy2(source_Secloads_Fx_W,destination_Secloads_W)
        shutil.copy2(source_Secloads_Fy_W,destination_Secloads_W)
        shutil.copy2(source_Secloads_Fz_W,destination_Secloads_W)
        shutil.copy2(source_Secloads_Mo_W,destination_Secloads_W)
    except:
        continue'''

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name

sim_name = sim_name+new_sim_name
