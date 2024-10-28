import os
import sys

sys.path.append(os.path.abspath("../../adapter"))

from run_dust import *
from run_matlab import *
from run_precice import *
from MATLAB_Interface import MATLABinterface

# ===========================================================================

#> matlab model parameters 
dt = 0.001
path2matlab = os.path.join('matlab') 
path2dust = os.path.join('dust')
path2precice = os.path.join('')
# matlab_model = 'setup.m'

class default():
    def __init__(self):
        # Define common files
        self.dust_pre_input = 'dust_pre.in'
        self.dust_input = 'dust.in'
        self.dust_post = 'dust_post.in'
        self.dust_log  = path2dust+'_solver' 
        
d = default()
# cleanup previous .log and cached files
cleanup(path2matlab,path2dust, path2precice) 
s = setup_socket(path2matlab)
conn = MATLABinterface.connect(s) 
run_dust_pre(path2dust, d)
run_dust(path2dust, d)
#run_matlab(matlab_model, path2matlab) 
run_precice(dt, path2matlab, conn) 
