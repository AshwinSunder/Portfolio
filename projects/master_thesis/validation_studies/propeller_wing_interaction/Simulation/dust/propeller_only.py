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
r            = 0.118
bby2         = 0.64
c            = 0.24
rot_dir      = "OU"
span_1       = r
sweep_1      = 0.0
dihed_1      = 0.0
nelem_span_1 = 20

# Fixed model locations
blade_file_loc          = "../../Model/Blades/"
blade_file_dust_pre_loc = "../../Model/Blades/"

# Fixed simulation data
tf          = 0.02295
dt          = 0.00005
density     = 1.2
vel         = 50
amp         = 0.0
xp          = 0.0
yp          = 0.0
zp          = 0.0
orientation = "(/ -1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, -1.0 /)"
amp_prop    = 0.0

# Fixed output file locations
output_file_loc    = "../../Output"
dust_sim_file_name = "prop"
dust_sim_file_loc  = "dust"
Intloads_file_loc  = "Postpro/Intloads"
Secloads_file_loc  = "Postpro/Secloads"
Probes_file_loc    = "Postpro/Probes"

# Fixed fileWrapper keys
blade_file_key             = ["@chord_1","@twist_1","@span_1","@sweep_1","@dihed_1","@nelem_span_1","@chord_2","@twist_2"]
references_key             = ["@amp","@xp1","@xp2","@yp","@zp","@orientation","@rot_rate","@rot_axis","@parent_1","@parent_2","@parent_3","@parent_4","@ref_tag_1","@ref_tag_2","@ref_tag_3","@ref_tag_4"]
dust_pre_P_key             = ["@blade_file"]
dust_key                   = ["@tf","@dt","@vel","@density","@output_file"]
dustPost_IntLoads_key      = ["@tf_res","@sim_name","@output_file","@comp_name_1"]
dustPost_SecLoads_key      = ["@tf_res","@sim_name","@output_file","@comp_name_1"]
dustPost_Probes_key        = ["@tf_res","@sim_name","@output_file","@comp_name_1","@comp_name_2"]

########################## Propeller Thrust Validation Studies ##########################

# Fixed variables for current simulation(s)
density     = 1.2
rot_axis    = "(/1.0, 0.0, 0.0/)"
parent_1    = "0"
ref_tag_1   = "NoWing"
parent_2    = "NoWing"
ref_tag_2   = "PivotPoint"
parent_3    = "PivotPoint"
ref_tag_3   = "Hub01"
parent_4    = "Hub01"
ref_tag_4   = "Prop01"
comp_name   = "P"

# Model data for current simulation(s)
blade_angle  = 25
chord        = 0.053
chord_1      = chord
chord_2      = chord
twist        = 48
twist_1      = blade_angle+0.75*twist
twist_2      = blade_angle-0.25*twist
   
# Create blade file
blade_file_parameters = [chord_1,twist_1,span_1,sweep_1,dihed_1,nelem_span_1,chord_2,twist_2]
fw.wrap_file(os.path.join(blade_file_loc,"blade_tmpl.in"),os.path.join(blade_file_loc,"blade.in"),blade_file_key,blade_file_parameters)      
blade_file = os.path.join(blade_file_dust_pre_loc,"blade.in")

# Output file locations for current simulation(s)
output_file_name  = "propeller_only"

# Variables for current simulation(s)
'''vel_range     = [(1500/(0.5*density))**0.5,(245/(0.5*density))**0.5]'''
vel_range     = [(1500/(0.5*density))**0.5]

# Loop to create simulation data arrays
new_sim_name = []
rot_rate     = []
vel          = []
for i in range(len(vel_range)):

    if round(vel_range[i],3) == int(vel_range[i]):
        vel_sim = int(vel_range[i])
    else:
        vel_sim = vel_range[i]

    '''if i == 0:
        J_range = [round(0.1*x,1) for x in range(5,21)]
    else:
        J_range = [round(0.1*x,1) for x in range(2,21)]'''
    J_range = [round(0.1*x,1) for x in range(5,21)]

    for j in range(len(J_range)):

        if round(J_range[j],1) == int(J_range[j]):
            J_sim = int(J_range[j])
        else:
            J_sim = J_range[j]

        rot_rate_sim = 2*math.pi*vel_sim/(J_sim*2*r)

        curr_sim_name = "J"+str(J_sim)+"_blade_angle"+str(blade_angle)+"_blade_twist"+str(twist)+"_blade_width"+str(chord)+"_density"+str(density)+"_vel"+str(round(vel_sim,3))
        if curr_sim_name.replace(".","_")+"_"+comp_name not in sim_name:
            new_sim_name += [curr_sim_name.replace(".","_")]
            rot_rate     += [rot_rate_sim]
            vel          += [vel_sim]

# Looping through each simulation name+data
for i in range(len(new_sim_name)):
    
    os.system("clear")
    os.system("rm -rf "+os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,"*")) # Clear previous simulation dust files (safer to do so)

    # Simulation data file names for dust
    sim_name_Intloads = "Intloads_"+new_sim_name[i]
    sim_name_Secloads = "Secloads_"+new_sim_name[i]
    sim_name_Probes   = "Probes_"  +new_sim_name[i]
    basename_Intloads = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads)
    basename_Secloads = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads)
    basename_Probes   = os.path.join(output_file_loc,output_file_name,Probes_file_loc,sim_name_Probes)
    data_basename     = os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,dust_sim_file_name)

    # fileWrapper parameters for current simulation
    references_parameters         = [str(amp*math.pi/180),str(0.0),str(round(-xp*c-c/4,6)),str(round(yp*bby2,6)),str(round(zp*r,6)),orientation,str(rot_rate[i]),rot_axis,parent_1,parent_2,parent_3,parent_4,ref_tag_1,ref_tag_2,ref_tag_3,ref_tag_4]
    dust_pre_P_parameters         = [blade_file]
    dust_parameters               = [str(tf),str(dt),str(vel[i]),str(density),data_basename]
    dustPost_IntLoads_parameters  = [str(int(round(tf/dt,0))+1),basename_Intloads,data_basename,comp_name]
    dustPost_SecLoads_parameters  = [str(int(round(tf/dt,0))+1),basename_Secloads,data_basename,comp_name]
    dustPost_Probes_parameters    = [str(int(round(tf/dt,0))+1),basename_Probes,data_basename,comp_name+"_Vel",comp_name+"_cp"]

    # fileWrapper used for References.in, dust_pre.in and dust.in files
    fw.wrap_file(os.path.join(input_file_loc,"References_tmpl.in")         ,os.path.join(input_file_loc,"References.in")       ,references_key        ,references_parameters)
    fw.wrap_file(os.path.join(input_file_loc,"dust_pre_P_tmpl.in")         ,os.path.join(input_file_loc,"dust_pre.in")         ,dust_pre_P_key        ,dust_pre_P_parameters)
    fw.wrap_file(os.path.join(input_file_loc,"dust_tmpl.in")               ,os.path.join(input_file_loc,"dust.in")             ,dust_key              ,dust_parameters)

    # Rust dust_pre and dust
    os.system("dust_pre "  + os.path.join(input_file_loc,"dust_pre.in"))
    os.system("dust "      + os.path.join(input_file_loc,"dust.in"))

    # run fileWrapper+dust_post
    fw.wrap_file(os.path.join(input_file_loc,"dustPost_IntLoads_P_tmpl.in"),os.path.join(input_file_loc,"dustPost_IntLoads.in"),dustPost_IntLoads_key ,dustPost_IntLoads_parameters)
    os.system("dust_post " + os.path.join(input_file_loc,"dustPost_IntLoads.in"))

    fw.wrap_file(os.path.join(input_file_loc,"dustPost_SecLoads_P_tmpl.in"),os.path.join(input_file_loc,"dustPost_SecLoads.in"),dustPost_SecLoads_key ,dustPost_SecLoads_parameters)
    os.system("dust_post " + os.path.join(input_file_loc,"dustPost_SecLoads.in"))

    fw.wrap_file(os.path.join(input_file_loc,"dustPost_Probes_P_tmpl.in")  ,os.path.join(input_file_loc,"dustPost_Probes.in")  ,dustPost_Probes_key   ,dustPost_Probes_parameters)
    os.system("dust_post " + os.path.join(input_file_loc,"dustPost_Probes.in"))

    # Copy files to sciebo
    '''source_Intloads_P      = os.path.join(output_file_loc,output_file_name,Intloads_file_loc,sim_name_Intloads+"_"+comp_name+".dat")
    destination_Intloads_P = os.path.join(sciebo_file_loc,sciebo_file,output_file_name,Intloads_file_loc)

    source_Secloads_Fx_P   = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads+"_"+comp_name+"_Fx.dat")
    source_Secloads_Fy_P   = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads+"_"+comp_name+"_Fy.dat")
    source_Secloads_Fz_P   = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads+"_"+comp_name+"_Fz.dat")
    source_Secloads_Mo_P   = os.path.join(output_file_loc,output_file_name,Secloads_file_loc,sim_name_Secloads+"_"+comp_name+"_Mo.dat")
    destination_Secloads_P = os.path.join(sciebo_file_loc,sciebo_file,output_file_name,Secloads_file_loc)

    source_Probes_Vel_P    = os.path.join(output_file_loc,output_file_name,Probes_file_loc,sim_name_Probes+"_"+comp_name+"_Vel.dat")
    source_Probes_cp_P     = os.path.join(output_file_loc,output_file_name,Probes_file_loc,sim_name_Probes+"_"+comp_name+"_cp.dat")
    destination_Probes_P   = os.path.join(sciebo_file_loc,sciebo_file,output_file_name,Probes_file_loc)

    try:
        shutil.copy2(source_Intloads_P,destination_Intloads_P)
        shutil.copy2(source_Secloads_Fx_P,destination_Secloads_P)
        shutil.copy2(source_Secloads_Fy_P,destination_Secloads_P)
        shutil.copy2(source_Secloads_Fz_P,destination_Secloads_P)
        shutil.copy2(source_Secloads_Mo_P,destination_Secloads_P)
        shutil.copy2(source_Probes_Vel_P,destination_Probes_P)
        shutil.copy2(source_Probes_cp_P,destination_Probes_P)
    except:
        continue'''

    new_sim_name[i] = new_sim_name[i]+"_"+comp_name

sim_name = sim_name+new_sim_name
