#!usr/bin/python

import os 

def wrap_file(filePathIN,filePathOUT,key,parameter):
    print('\033[0;33m ▶ Update File:  '+filePathIN+'\033[0m')

    with open(filePathIN,'r') as f:
        lines = f.readlines()
    
    text = []
    for line in lines:
        j = 0
        for ki in key:
            if ki in line:
                line = line.replace(ki,str(parameter[j]))
                print('\033[0;32m    ▶ '+ ki +' replaced by '+ str(parameter[j]) +'\033[0m')
            j = j+1

        text.append(line)  
    f.close()

    with open(filePathOUT,'w') as f:
        f.writelines(text) 
    f.close()
    print('\033[0;33m ▶ New File written: '+filePathOUT+'\033[0m')
    print("\n")