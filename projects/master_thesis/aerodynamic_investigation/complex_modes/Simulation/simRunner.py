#!usr/bin/python

import os 
import shutil
import fileWrapper as fw

def cleanup(output_file_loc,output_file_name,dust_sim_file_loc):
    os.system("clear")
    os.system("rm -rf "+os.path.join(output_file_loc,output_file_name,dust_sim_file_loc,"*")) # Clear previous simulation dust files (safer to do so)

def dust_wrap(keys,parameters,tmpl_files,dust_files,input_file_loc="."):
    
    for i in range(len(keys)):
        fw.wrap_file(os.path.join(input_file_loc,tmpl_files[i]),os.path.join(input_file_loc,dust_files[i]),keys[i],parameters[i])

def run_dust(dust_pre_file="dust_pre.in",dust_uncoupled_file="dust.in",dust_coupled_file="main.py",dust_post_files=["dust_post.in"],input_file_uncoupled_loc=".",input_file_coupled_loc=".",coupled=False):

    if not coupled:
        if os.path.isfile(os.path.join(input_file_uncoupled_loc,dust_pre_file)):
            os.system("dust_pre "  + os.path.join(input_file_uncoupled_loc,dust_pre_file))

        if os.path.isfile(os.path.join(input_file_uncoupled_loc,dust_uncoupled_file)):
            os.system("dust "      + os.path.join(input_file_uncoupled_loc,dust_uncoupled_file))

        for i in range(len(dust_post_files)):
            if os.path.isfile(os.path.join(input_file_uncoupled_loc,dust_post_files[i])):
                os.system("dust_post "+ os.path.join(input_file_uncoupled_loc,dust_post_files[i]))
    else:
        if os.path.isfile(os.path.join(input_file_coupled_loc,dust_coupled_file)):
            os.system("python3 "   + os.path.join(input_file_coupled_loc,dust_coupled_file))

        for i in range(len(dust_post_files)):
            if os.path.isfile(os.path.join(input_file_uncoupled_loc,dust_post_files[i])):
                currdir = os.getcwd()
                os.chdir(os.path.join(input_file_uncoupled_loc))
                os.system("dust_post "+ dust_post_files[i])
                os.chdir(str(currdir))


def copy_dust_post_files(sciebo_file_loc,sciebo_file,output_file_loc,output_file_name,Postpro_file_loc,sim_name,comp_name,is_IntLoads=False,num_IntLoads=1,is_SecLoads=False,num_SecLoads=1):
    
    source_files    = []
    destination_dir = []

    '''if is_IntLoads is True:
        if os.path.isdir(os.path.join(sciebo_file_loc,sciebo_file,output_file_name,Postpro_file_loc[0])):
            destination_dir += [os.path.join(sciebo_file_loc,sciebo_file,output_file_name,Postpro_file_loc[0])]
        else:
            print("No such folder exists")
            return
        if os.path.isfile(os.path.join(output_file_loc,output_file_name,Postpro_file_loc[0],sim_name[0]+"_"+comp_name+".dat")):
            source_files += [os.path.join(output_file_loc,output_file_name,Postpro_file_loc[0],sim_name[0]+"_"+comp_name+".dat")]
        else:
            print("No such file exists")
            return
        
    if is_SecLoads is True:
        if is_IntLoads is True:
            ii = 1
        else:
            ii = 0

        iii = 0
        if os.path.isfile(os.path.join(output_file_loc,output_file_name,Postpro_file_loc[ii],sim_name[ii]+"_"+comp_name+"_Fx.dat")):
            source_files += [os.path.join(output_file_loc,output_file_name,Postpro_file_loc[ii],sim_name[ii]+"_"+comp_name+"_Fx.dat")]
            iii += 1
        else:
            print("No such file exists")
            return
        if os.path.isfile(os.path.join(output_file_loc,output_file_name,Postpro_file_loc[ii],sim_name[ii]+"_"+comp_name+"_Fy.dat")):
            source_files += [os.path.join(output_file_loc,output_file_name,Postpro_file_loc[ii],sim_name[ii]+"_"+comp_name+"_Fy.dat")]
            iii += 1
        else:
            print("No such file exists")
            return
        if os.path.isfile(os.path.join(output_file_loc,output_file_name,Postpro_file_loc[ii],sim_name[ii]+"_"+comp_name+"_Fz.dat")):
            source_files += [os.path.join(output_file_loc,output_file_name,Postpro_file_loc[ii],sim_name[ii]+"_"+comp_name+"_Fz.dat")]
            iii += 1
        else:
            print("No such file exists")
            return
        if os.path.isfile(os.path.join(output_file_loc,output_file_name,Postpro_file_loc[ii],sim_name[ii]+"_"+comp_name+"_Mo.dat")):
            source_files += [os.path.join(output_file_loc,output_file_name,Postpro_file_loc[ii],sim_name[ii]+"_"+comp_name+"_Mo.dat")]
            iii += 1
        else:
            print("No such file exists")
            return
        
        if os.path.isdir(os.path.join(sciebo_file_loc,sciebo_file,output_file_name,Postpro_file_loc[ii])):
            for _ in range(iii):
                destination_dir += [os.path.join(sciebo_file_loc,sciebo_file,output_file_name,Postpro_file_loc[ii])]
        else:
            print("No such folder exists")
            return'''
        
    if is_IntLoads is True:
        for i in range(num_IntLoads):
            source_files += [os.path.join(output_file_loc,output_file_name,Postpro_file_loc[0],sim_name[0]+"_"+comp_name[i]+".dat")]

            destination_dir += [os.path.join(sciebo_file_loc,sciebo_file,output_file_name,Postpro_file_loc[0])]

    if is_SecLoads is True:
        if is_IntLoads is True:
            ii = 1
        else:
            ii = 0

        for i in range(num_SecLoads):
            source_files += [os.path.join(output_file_loc,output_file_name,Postpro_file_loc[ii],sim_name[ii]+"_"+comp_name[i+num_IntLoads]+"_Fx.dat")]
            source_files += [os.path.join(output_file_loc,output_file_name,Postpro_file_loc[ii],sim_name[ii]+"_"+comp_name[i+num_IntLoads]+"_Fy.dat")]
            source_files += [os.path.join(output_file_loc,output_file_name,Postpro_file_loc[ii],sim_name[ii]+"_"+comp_name[i+num_IntLoads]+"_Fz.dat")]
            source_files += [os.path.join(output_file_loc,output_file_name,Postpro_file_loc[ii],sim_name[ii]+"_"+comp_name[i+num_IntLoads]+"_Mo.dat")]

            for _ in range(4):
                destination_dir += [os.path.join(sciebo_file_loc,sciebo_file,output_file_name,Postpro_file_loc[ii])]

    for i in range(len(source_files)):
        try:
            shutil.copy2(source_files[i],destination_dir[i])
        except:
            continue