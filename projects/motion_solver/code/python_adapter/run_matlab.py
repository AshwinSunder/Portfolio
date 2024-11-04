 
import subprocess as sp
import os 

def run_matlab(model, path2matlab):
    oldpwd = os.getcwd()
    try:
        os.chdir(path2matlab)  
        sp.run('matlab -nodisplay -nosplash -nodesktop -r "setup;exit;" | tail -n +11 &', shell=True)
        '''sp.run('matlab -nodisplay -nosplash -nodesktop -r  \
               "try, setup, catch me, fprintf("%s / %s\n",me.identifier,me.message), end, exit" | tail -n +11 &', shell=True)'''
        os.chdir(oldpwd)
    except:
        pass
