import os
import sys

sys.path.append('../../../adapter')

from run_dust import *
from run_precice import *
from MATLAB_Interface import *

# ===========================================================================

# Time parameter
dt      = 0.001000

name_sim         = "prop_wing"

path2dustOut   = '../../Output/dust/' + name_sim

path2matlab     = os.path.join('matlab') 
path2dust      = os.path.join('dust')
path2precice   = os.path.join('')

# ===========================================================================
class default():
    def __init__(self,path2dustOut=path2dustOut):
        # Define common files
        self.dust_pre_input = 'dust_pre.in'
        self.dust_input     = 'dust.in'
        self.dust_post      = 'dust_post.in' 
        self.dust_log       = path2dustOut+'_solver'
        
d = default(path2dustOut=path2dustOut)

# cleanup previous .log and cached files
cleanup(path2matlab,path2dust,path2precice) 

# setup socket
s = setup_socket(path2matlab)
conn = MATLABinterface.connect(s)

# run dust and precice
run_dust_pre(path2dust, d)
run_dust(path2dust, d)
run_precice(dt, path2matlab, conn) 
