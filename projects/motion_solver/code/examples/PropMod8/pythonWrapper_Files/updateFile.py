#!usr/bin/python 

import os 

def update_propDat(dir_TPLfile,dir_OUTfile,vel,kpitch,kyaw):
    print('\033[0;33m ▶ Update File \033[0m')

    with open(dir_TPLfile,'r') as f:
        lines = f.readlines()

    text = []
    for line in lines: 
        if '@VELOCITY' in line: 
            line = line.replace('@VELOCITY',str(vel))
        elif '@KPITCH' in line:
            line = line.replace('@KPITCH',str(kpitch))
        elif '@KYAW' in line:
            line = line.replace('@KYAW',str(kyaw))
            

        text.append(line)  
    f.close()

    with open(dir_OUTfile,'w') as f:
        f.writelines(text) 
    f.close()