#!usr/bin/python 

import os 

def dust_outputSet(dir_dust, outputPath,):
    print('\033[0;33m ▶ Update DUST OutputPath \033[0m')
    dust_file_path = os.path.join(dir_dust,'dust.in')
    fo = open(dust_file_path,"r")
    lines = fo.readlines()

    f = open(dust_file_path,"w")

    for i in lines:
        if "basename =" in i:
            print("  --> update BASENAME")
            f.write('basename = %s\n' % outputPath)
        else:
            f.write(i)

    fo.close()
    f.close()

def dust_velSet(dir_dust, velx,vely,velz):
    print('\033[0;33m ▶ Update DUST Vel \033[0m')
    dust_file_path = os.path.join(dir_dust,'dust.in')
    fo = open(dust_file_path,"r")
    lines = fo.readlines()

    f = open(dust_file_path,"w")

    for i in lines:
        if "u_inf = " in i:
            print("  --> update Velocity")
            f.write("u_inf = (/"+str(velx)+","+str(vely)+","+str(velz)+"/)\n")
        else:
            f.write(i)

    fo.close()
    f.close()

def dust_postSet(dir_dust,data_basename,postOut):
    print('\033[0;33m ▶ Update DUST POST \033[0m')
    dust_file_path = os.path.join(dir_dust,'dust_post.in')
    fo = open(dust_file_path,"r")
    lines = fo.readlines()

    f = open(dust_file_path,"w")

    for i in lines: 
        if "data_basename =" in i:
            print("  --> update data_basename")
            f.write("data_basename = "+ data_basename +"\n")
        elif "basename =" in i:
            print("  --> update basename")
            f.write("basename = "+ postOut +"\n")
        else:
            f.write(i)

    fo.close()
    f.close()