from os import system
import matplotlib.pyplot as plt
import re

import data_io
import path_manip
import math_manip
 
def add_variables(command, variables = None):

    if variables is not None:
        cmd = command
        str = [f' -v "{item[0]} = {item[1]}"' for item in variables]
        str = ''.join(str)

        cmd += str
        return cmd
    else:
        return command

def add_time(command, time_config = None):

    if time_config is not None:

        cmd = command
        time_index = time_config[0].index('TotalTime') + 1
        timeStep_index = time_config[1].index('TimeStep') + 1

        str = f' -t "{time_config[0][time_index]}" -s "{time_config[1][timeStep_index]}"'
        cmd += str
        return cmd
    else:
        return command

def command(program, input, output, variables = None, time_config = None):

    # C:\"Program Files (x86)"\Powersim\PSIM9.1.4_softkey\PsimCmd.exe -i circuits\atv01_fontes_paralelas.sch -o circuits\output\data\untitled3.txt -v "theta = 0.3" -t "0.16666666666666666" -s "0.00016666666666666666"

    cmd = f'{program} -i {input} -o {output}'
    cmd = add_variables(cmd, variables)
    cmd = add_time(cmd, time_config)
    cmd += ' >nul'
    system(cmd)

def simulations():
    psim_file = r'C:\"Program Files (x86)"\Powersim\PSIM9.1.4_softkey\PsimCmd.exe'              # PSIM prompt exe
    circuit_file = 'circuits\\atv01_fontes_paralelas.sch'                                       # input schematics
    params = 'circuits\\params_atv01_fontes_paralelas.csv'                                      # params csv configuration
    time_config = [('TotalTime', 10/60), ('TimeStep', 1/60/10000)]                                 # config simulation
    
    circuit_output = 'circuits\\output\\data\\untitled.txt'
    path_manip.remove_files(path_manip.get_dir(circuit_output))

    variables = data_io.import_params_to_array(params)

    num_simulations = len(variables)
    for i in range(num_simulations):
        circuit_output = path_manip.change_output_number(circuit_output, i)
        command(psim_file, circuit_file, circuit_output, variables[i], time_config)
        percentage = i/num_simulations*100
        print(f'PORCENTAGEM = {percentage}', end='\r')


import numpy as np
import pandas as pd

def interpret():

    outputs = path_manip.find_files('circuits\\output\\data', '.txt')
    outputs.sort(key = lambda i: int(re.findall('\d+', i)[0]))           # ordena pelo primeiro numero encontrado no path do file

    thetas = np.arange(0,90.1,0.1)
    n_simulations = len(outputs)

    harmonic_height_1 = []
    harmonic_height_3 = []
    harmonic_height_5 = []
    harmonic_height_7 = []

    for i in range(n_simulations):
        file = outputs[i]

        df = data_io.import_psim_data(file)
        t = df['Time'].to_numpy()
        y = df['VP9'].to_numpy()

        f, Y = math_manip.spectrum(t, y)

        harmonics, harmonics_heights = math_manip.harmonics_amplitudes(Y)
        harmonic_height_1.append(harmonics_heights[0])
        harmonic_height_3.append(harmonics_heights[1])
        harmonic_height_5.append(harmonics_heights[2])
        harmonic_height_7.append(harmonics_heights[3])

        percentage = i/n_simulations*100
        print(f'PORCENTAGEM = {percentage}', end='\r')
        

    
    plt.title('Spectrum Output Voltage x Phase Shift Control')
    plt.plot(thetas, harmonic_height_1)
    plt.plot(thetas, harmonic_height_3)
    plt.plot(thetas, harmonic_height_5)
    plt.plot(thetas, harmonic_height_7)
    plt.legend(['1th harmonic', '3th harmonic', '5th harmonic', '7th harmonic'])
    plt.show()

    

def run():
    interpret()

run()