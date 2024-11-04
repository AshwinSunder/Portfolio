
import tempfile 
import os, sys
import socket
from precice import *
from MATLAB_Interface import MATLABinterface
from MATLAB_Adapter import MATLABadapter   
import subprocess as sp


def cleanup(path2matlab, path2dust, path2precice): 

    if os.path.isfile(os.path.join(path2matlab,'precice-matlab-iterations.json')):
        events = os.path.join(path2matlab,'precice-matlab-events.json')
        iteration = os.path.join(path2matlab,'precice-matlab-iterations.log') 
        sp.run('rm -fv ' + events,      shell=True)
        sp.run('rm -fv ' + iteration,   shell=True)

    if os.path.isdir(os.path.join(path2matlab,'__pycache__')):      
        pycache = os.path.join(path2matlab,'__pycache__')
        sp.run('rm -rfv ' + pycache, shell=True)

    if os.path.isfile(os.path.join(path2dust,'precice-dust-convergence.*')): 
        convergence = os.path.join(path2dust,'precice-dust-convergence.*')
        solver = os.path.join(path2dust,'dust_solver.*')
        events = os.path.join(path2dust,'precice-dust-events.*')
        iteration =  os.path.join(path2dust,'precice-dust-iterations.*')

        sp.run('rm -fv ' + convergence, shell=True)
        sp.run('rm -fv ' + solver,      shell=True)
        sp.run('rm -fv ' + events,      shell=True)
        sp.run('rm -fv ' + iteration,   shell=True)
        
    # remove dummy precice-run folder
    if os.path.isdir(os.path.join(path2precice,'precice-run')):
        sp.run('rm -rfv '+ os.path.join(path2precice,'precice-run'), shell=True)
        sp.run('rm -fv ' + os.path.join(path2precice,'nnodes.*'),  shell=True)

    # remove previous output and post-processing files
    if os.path.isdir(os.path.join(path2dust,'Postpro')):
        sp.run('rm -rf '+ os.path.join(path2dust,'Postpro/*'), shell=True)
        print('removed \'postprocessing files\'')
    if os.path.isdir(os.path.join(path2dust, 'Output')):
        sp.run('rm -rf ' + os.path.join(path2dust,'Output/*'),  shell=True)
        print('removed \'geo files\'')

    # remove previous matlab iteration files
    if os.path.isdir(os.path.join(path2matlab,'Itermatlab')):
        sp.run('rm -rf '+ os.path.join(path2matlab,'Itermatlab/*'), shell=True)
        sp.run('rm -fv '+ os.path.join(path2matlab,'precice-matlab-iterations.*'), shell=True)
        print('removed \'matlab iteration files\'')

    # remove previous port number text file
    if os.path.isdir(os.path.join(path2matlab,'port.*')):
        sp.run('rm -fv '+ os.path.join(path2matlab,'port.*'), shell=True)

def setup_socket(path2matlab):
    HOST = ''
    PORT = 0
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 65536)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 65536)
    s.bind((HOST, PORT))

    with open(os.path.join(path2matlab, 'port.txt'), 'w') as f:
        f.write(str(s.getsockname()[1]))
    f.close()
    return s

def run_precice(dt, path2matlab, conn): 

    oldpwd = os.getcwd()
    os.chdir(path2matlab)
    mlab = MATLABinterface()
    
    #> Send MATLAB exposed nodes to the other solver, if needed
    print("\n -------- Initializing MATLAB adapter -------- \n")
    try: 
        adapter = MATLABadapter(mlab, conn)
    except:
        print("\033[0;31m        Adapter initialization failed      \033[0m")
        conn.close()
        sys.exit()

    print("\033[0;32m            Adapter Initialized            \033[0m")
    #> Start coupled simulation with PreCICE
    print("\n -------------- Running preCICE -------------- \n")
    try: 
        adapter.runprecice(dt)
    except:
        print("\n \033[0;31m ------ preCICE connection fail/interrupt ------ \033[0m \n")
        conn.close()
        sys.exit()
    
    os.chdir(oldpwd)
    conn.close()
    sys.exit()
