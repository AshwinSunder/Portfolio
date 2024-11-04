
from cmath import exp
import subprocess as sp 
import os 

def run_dust_pre(path2dust, default):
    print('\033[0;33m ▶ DUST Pre \033[0m')
    dust_pre_input = default.dust_pre_input
    try:
        oldpwd = os.getcwd()
        os.chdir(path2dust)
        sp.run('dust_pre ' + os.path.join(dust_pre_input) + '> ' + default.dust_log + '.log', shell=True) 
        os.chdir(oldpwd)
    except:
        pass

def run_dust(path2dust, default): 
    print('\033[0;33m ▶ DUST \033[0m')
    dust_input = default.dust_input
    try:
        oldpwd = os.getcwd()
        os.chdir(path2dust)
        sp.run('dust ' + os.path.join(dust_input) + '>> ' + default.dust_log + '.log' + ' &', shell=True) 
        os.chdir(oldpwd)
    except:
        pass

def run_dust_post(): 
    try:
        sp.run('dust_post' , shell=True)     
    except:
        pass