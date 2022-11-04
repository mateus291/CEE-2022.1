import numpy as np
import os

def run_simulation(schematic: str, output: str, variables:dict={}, 
                   total_time=0.1, time_step=1e-5):
    variables_str = ' '.join([f'-v "{name}={value}"' \
        for name, value in variables.items()])
    os.system(f'PsimCmd -i "{schematic}" -o "{output}" {variables_str} -t "{total_time}" -s "{time_step}"')

ma = 0.95
Vcc = 220 * np.sqrt(2) / ma

mf_fixed = 150
mf = list(range(21, 201))

Ro_fixed = 10
Ro = list(range(1, 21))

Lf1 = 3e-3
Lf2 = 2e-3
Cf = 2.2e-6

varying_Ro = [{
    'ma': ma,
    'mf': mf_fixed,
    'Vcc': Vcc,
    'Lf1': Lf1,
    'Lf2': Lf2,
    'Cf': Cf,
    'Ro': ro,
} for ro in Ro]

varying_mf = [{
    'ma': ma,
    'mf': mf_,
    'Vcc': Vcc,
    'Lf1': Lf1,
    'Lf2': Lf2,
    'Cf': Cf,
    'Ro': Ro_fixed,
} for mf_ in mf]

directory = os.getcwd() + '\\'
schematic = directory + 'UnipolarFullBridge.psimsch'
output_path = directory + 'data\\'

if __name__ == '__main__':
    print('Fixed Ro:\n')
    run_simulation(schematic, output_path + 'fixed_Ro\\fixed_Ro.txt', 
        variables={
            'ma': ma,
            'mf': mf_fixed,
            'Vcc': Vcc,
            'Lf1': Lf1,
            'Lf2': Lf2,
            'Cf': Cf,
            'Ro': Ro_fixed,
        },
        total_time=0.1,
        time_step=1e-5,
    )

    print('\nVarying Ro:\n')
    for n, variables in enumerate(varying_Ro):
        run_simulation(schematic, output_path + f'varying_Ro\\varying_Ro_{n}.txt',
            variables=variables,
            total_time=0.1,
            time_step=1e-5,
        )
    
    print('\nVarying mf:\n')
    for n, variables in enumerate(varying_mf):
        run_simulation(schematic, output_path + f'varying_mf\\varying_mf_{n}.txt',
            variables=variables,
            total_time=0.1,
            time_step=1e-5,
        )
