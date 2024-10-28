
from precice import *
import numpy as np
import socket
import pandas as pd

# Create an object for information transfer and connection
class MATLABinterface:

    # Constructor
    def __init__(self):
        self.initialized = False

        # Data format used by adapter
        self.data = { 'Position':{ \
                          'type': 'vector', 'io': 'write', 'data': [] }, \
                      'Rotation':{ \
                          'type': 'vector', 'io': 'write', 'data': [] }, \
                      'Velocity':{ \
                          'type': 'vector', 'io': 'write', 'data': [] }, \
                      'AngularVelocity':{ \
                          'type': 'vector', 'io': 'write', 'data': [] }, \
                      'Force':{ \
                          'type': 'vector', 'io': 'read', 'data': [] }, \
                      'Moment':{ \
                          'type': 'vector', 'io': 'read', 'data': [] } }

    # Connection
    def connect(s):
        s.listen(1)
        conn, addr = s.accept()
        print(f"Connected to: {addr}")
        return conn

    # Data Transfer
    def data_transfer(self, mlab_data, conn, t, n, nd):

        # Send data to matlab
        self.send_data(mlab_data, conn, t, n, nd)

        # Retrieve data and convert to matlab object type
        self.recv_data(mlab_data, conn, n, nd)

    # Data send function
    def send_data(self, mlab_data, conn, t, n, nd):

        # Call data conversion function
        send_data = self.data_conv(mlab_data, t, n, nd)

        # Send new dictionary to matlab
        try :
            conn.sendall(f"{send_data}".encode())
        except:
            print('\033[0;33m Error: Could not send data to matlab server \033[0m ')

    # Data recieve function
    def recv_data(self, mlab_data, conn, n, nd):
        try:
            matlab_read = conn.recv(65536).decode()
        except:
            print('\033[0;33m Error: Could not recieve data from matlab server \033[0m ')

        # Convert received data into required format
        matlab_dat = pd.to_numeric(matlab_read[0:-1].split(';'))
        matlab_output = (np.ndarray.reshape(matlab_dat, (n*4, nd)))

        # Save received data into interface object
        for i in range(n):
            mlab_data['Position']['data'][i, :]        = matlab_output[i*2,       :]
            mlab_data['Rotation']['data'][i, :]        = matlab_output[i*2+1,     :]
            mlab_data['Velocity']['data'][i, :]        = matlab_output[i*2+n*2,   :]
            mlab_data['AngularVelocity']['data'][i, :] = matlab_output[i*2+n*2+1, :]

    # Create nodes for configuration
    def refConfigNodes(self, filen='./refConfigNodes.in', dim = 3):
        rr = np.loadtxt(fname = filen)

        if ( len(rr.shape) == 1 ):
            rr = rr.reshape(1, dim) 
        return rr

    # Convert data to be sent into string
    def data_conv(self, mlab_data, t, n, nd):
        
        # Reshape the data into a linear vector
        send_data = [0.]*(n*nd*2+1)

        ii = 0
        for fie in mlab_data:
            if mlab_data[fie]['io'] == 'read':
                for i in range(n):
                    send_data[(i*nd*2+ii*nd):((i*2+1)*nd+ii*nd)] = mlab_data[fie]['data'][i, :]
                ii = ii + 1
         
        # Add time step to the end
        send_data[-1] = t

        return send_data
