import os
import sys

sys.path.append('../../../adapter')
sys.path.append('../pythonWrapper_Files')

from run_dust import *
from run_precice import *
import fileWrapper
from MATLAB_Interface import *

# ===========================================================================

# Time parameter
t_start = 0
t_end   = 2.000000
dt      = 0.001000
dt_out  = 0.001000

# Flow parameter
rho     = 1.225
sos     = 10000.0
vx      = 106.5
vy      = 0.0
vz      = 0.0

# Struct Parameter
kPitch = 90000
kYaw   = 90000
rpm    = 0

name_sim         = "propTractor_MS090k_V106-5_RPM2500_sos10000_V2"

path2dustOut   = './../../Output/dust/' + name_sim

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

# prop.dat Adjustment
key = ["@KPITCH","@KYAW","@RPM","@VELOCITY"]
para = [kPitch,kYaw,rpm,vx]
filePathIn  = './../Model/templ_prop.dat'
filePathOut = './../Model/ps_prop.dat'
fileWrapper.wrap_file(filePathIn,filePathOut,key,para)

# DUST.in Adjustment
key = ["@BASENAME","@TSTART","@TEND","@DELTAT","@DELTAOUT","@RHO","@SOS","@VELX","@VELY","@VELZ"]
para = [path2dustOut,t_start,t_end,dt,dt_out,rho,sos,vx,vy,vz]
filePathIn  = path2dust + "/tmpl_dust.in"
filePathOut = path2dust + "/dust.in"
fileWrapper.wrap_file(filePathIn,filePathOut,key,para)

d = default()
# cleanup previous .log and cached files
cleanup(path2matlab,path2dust,path2precice) 

# setup socket
s = setup_socket(path2matlab)
conn = MATLABinterface.connect(s)

# run dust and precice
run_dust_pre(path2dust, d)
run_dust(path2dust, d)
run_precice(dt, path2matlab, conn) 
