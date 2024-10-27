
import precice
import time
from mpi4py import MPI
import numpy as np

# Create object for adapter
class MATLABadapter:

    def __init__(self, matlabInterface, conn, config_file_name = './../precice-config.xml'):
        
        # Initialize PreCICE participant and field dictionary
        self.p = {'name':'matlab', \
                  'mesh':{'name':'matlab_nodes', 'id':[], 'node_ids':[], \
                          'nodes':[], 'nnodes':[], 'dim':[] }, \
                  'fields':{} }
        
        self.field_dict = {'name':'field_name', 'id':[], 'data':[], \
                           'type':'scalar/vector', 'io':'read/write' }

        # Connect to matlab interface
        self.mlab = matlabInterface
        self.conn = conn

        # Precice-solver interface
        _comm = MPI.COMM_WORLD

        self.interface = precice.Interface('matlab', config_file_name, \
                                           _comm.Get_rank(), _comm.Get_size())

        # Get necessary data such as mesh-id, nodes, fields, etc
        # Mesh
        self.p['mesh']['id'] = self.interface.get_mesh_id(self.p['mesh']['name'])
        self.p['mesh']['nodes'] = self.mlab.refConfigNodes()
        self.p['mesh']['nnodes'] = len(self.p['mesh']['nodes'])
        self.p['mesh']['dim'] = self.interface.get_dimensions()
        self.p['mesh']['node_ids'] = self.interface.set_mesh_vertices( \
                                        self.p['mesh']['id'], self.p['mesh']['nodes'] )

        # Fields
        for fie in self.mlab.data:
            if self.interface.has_data(fie, self.p['mesh']['id']):
                field = self.field_dict.copy()
                field['name'] = fie
                field['type'] = self.mlab.data[fie]['type']
                field['io'] = self.mlab.data[fie]['io']
                field['id'] = self.interface.get_data_id(fie, self.p['mesh']['id'])
                self.p['fields'][fie] = field

        # Set initial values to matlab object
        for fie in self.mlab.data:
            self.mlab.data[fie]['data'] = \
                np.zeros((self.p['mesh']['nnodes'], self.p['mesh']['dim']))

        self.mlab.recv_data(self.mlab.data, conn, \
                                self.p['mesh']['nnodes'], self.p['mesh']['dim'])
       
        for fie in self.p['fields']:
            if self.p['fields'][fie]['io'] == 'write': # Set write data
                self.p['fields'][fie]['data'] = self.mlab.data[fie]['data']
            else: # Set read data
                self.p['fields'][fie]['data'] = \
                    np.zeros((self.p['mesh']['nnodes'], self.p['mesh']['dim']))

        # Precice interface initialize()
        self.dt_precice = self.interface.initialize()

        # Write initial data if required
        cowid = precice.action_write_initial_data()
    
        if self.interface.is_action_required(cowid):
            for fie in self.p['fields']:
                if self.p['fields'][fie]['io'] == 'write':
                    if self.p['fields'][fie]['type'] == 'scalar':
                        self.interface.write_block_scalar_data( \
                                                self.p['fields'][fie]['id'], \
                                                self.p['mesh']['node_ids'],   \
                                                self.p['fields'][fie]['data'] )
                    if self.p['fields'][fie]['type'] == 'vector':
                        self.interface.write_block_vector_data( \
                                                self.p['fields'][fie]['id'], \
                                                self.p['mesh']['node_ids'],   \
                                                self.p['fields'][fie]['data'] )
      
            self.interface.mark_action_fulfilled(cowid)

        # Initialize_data 
        self.interface.initialize_data()

    # Code to run precice in the adapter
    def runprecice(self, dt_set):
        coupling_start = time.time()

        # Initialize necessary variables
        cowic = precice.action_write_iteration_checkpoint()
        coric = precice.action_read_iteration_checkpoint()
        
        t = 0.
        niter = 0
        check_value = {}

        # Check if adapter and precice are coupled
        while self.interface.is_coupling_ongoing():
            niter = niter + 1
            if niter == 1:
                start = time.time()
            print('\033[0;33m   Iteration: ', niter, '\033[0m ')

            # Check if a data checkpoint needs to be created
            if self.interface.is_action_required(cowic):
                t_cp = t
                for fie in self.mlab.data:
                    if self.mlab.data[fie]['io'] == 'write':
                        check_value[fie] = self.mlab.data[fie]['data']
                self.interface.mark_action_fulfilled(cowic)

            # Compute adaptive time step
            dt = min(self.dt_precice, dt_set)

            # Read input data from precice
            if self.interface.is_read_data_available():
                for fie in self.p['fields']:
                    if self.p['fields'][fie]['io'] == 'read':
                        if self.p['fields'][fie]['type'] == 'scalar':
                            self.p['fields'][fie]['data']  = \
                                                self.interface.read_block_scalar_data( \
                                                        self.p['fields'][fie]['id'], \
                                                        self.p['mesh']['node_ids'] )
                        if self.p['fields'][fie]['type'] == 'vector':
                            self.p['fields'][fie]['data'] = \
                                                self.interface.read_block_vector_data( \
                                                        self.p['fields'][fie]['id'], \
                                                        self.p['mesh']['node_ids'] ) 

            # Set input data to matlab mesh nodes
            for fie in self.p['fields']:
                self.mlab.data[fie]['data'] = self.p['fields'][fie]['data']

            # Solve current time step in matlab and read computed values from matlab
            self.mlab.data_transfer(self.mlab.data, self.conn, t, \
                                    self.p['mesh']['nnodes'], self.p['mesh']['dim'])
            for fie in self.p['fields']:
                self.p['fields'][fie]['data'] = self.mlab.data[fie]['data'] 

            # Write output data to precice
            if self.interface.is_write_data_required(dt):
                for fie in self.p['fields']:
                    if self.p['fields'][fie]['io'] == 'write':
                        if self.p['fields'][fie]['type'] == 'scalar':
                            self.interface.write_block_scalar_data( \
                                                        self.p['fields'][fie]['id'], \
                                                        self.p['mesh']['node_ids'],   \
                                                        self.p['fields'][fie]['data'] )
                        if self.p['fields'][fie]['type'] == 'vector':
                            self.interface.write_block_vector_data( \
                                                        self.p['fields'][fie]['id'], \
                                                        self.p['mesh']['node_ids'],   \
                                                        self.p['fields'][fie]['data'] )   

            # Advance to next time step
            start_adv = time.time()
            self.dt_precice = self.interface.advance(dt)       
            end_adv = time.time()
            print('\033[0;31m   Advance time:', round((end_adv - start_adv), 4), 'sec\033[0m ')

            # Check convergence: iterate or finalize the time step
            if self.interface.is_action_required(coric): # not converged
                t = t_cp
                for fie in self.mlab.data:
                    if self.mlab.data[fie]['io'] == 'write':
                        self.mlab.data[fie]['data'] = check_value[fie]
                self.interface.mark_action_fulfilled(coric)

            else: # converged
                end = time.time()
                print('\033[0;32m ------------------------------- ')
                print('\033[0;32m   Iteration Time :', round((end - start),6), 'sec\033[0m ')
                print('\033[0;32m   Simulation Time : ', round(t, 6))
                print('\033[0;32m   Total Elapsed Time : ', round((end-coupling_start), 6))
                print('\033[0;32m ------------------------------- \033[0m \n')
                              
                t = t + dt
                niter = 0

        # Finalize
        print('\n\033[0;32m Simulation complete \033[0m \n\033[0;31m Finalize() \033[0m \n')
        self.interface.finalize()

        #terminate matlab connection and matlab
        self.conn.close()