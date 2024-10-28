#!usr/bin/python 

import os 

def mbdyn_timeSet(timeSet_dir, fileName, t_start, t_end, dt):    
    mbdyn_file_path = os.path.join(timeSet_dir, fileName)
    mbdyn_input = open(mbdyn_file_path, 'w+')
    mbdyn_input.write('set: const real t_start =%f; \n' % t_start)
    mbdyn_input.write('set: const real t_end   =%f; \n' % (t_end))
    mbdyn_input.write('set: const real dt      =%f; \n' % dt)
    mbdyn_input.close()
    print('\033[0;33m ▶ Create MBDyn TimeSet File \033[0m')
    print('  -->  path:' + mbdyn_file_path) 


def mbdyn_airPropSet(path2mbdyn,fileName,rho,sos):
    mbdyn_file_path = os.path.join(path2mbdyn, fileName)
    mbdyn_input = open(mbdyn_file_path, 'w+')
    mbdyn_input.write('set: real AirDensity   = %f; \n' % rho)
    mbdyn_input.write('set: real SpeedOfSound = %f; \n' % sos)
    mbdyn_input.close()
    print('\033[0;33m ▶ Create MBDyn AirProperty File \033[0m')
    print('  -->  path:' + path2mbdyn) 





    

