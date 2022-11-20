import numpy as np
import os

def run_simulation(schematic: str, output: str, variables:dict={}, 
                   total_time=0.1, time_step=1e-5):
    variables_str = ' '.join([f'-v "{name}={value}"' \
        for name, value in variables.items()])
    os.system(f'PsimCmd -i "{schematic}" -o "{output}" {variables_str} -t "{total_time}" -s "{time_step}"')

## Parâmetros (operação nominal):
Vn = 220.0;     Pn = 4100.0;    Lf1 = 3.0e-3;   Lf2 = 2.0e-3
Cf  = 2.2e-6;   Rd  = 10.0;     ma  = 0.95;     fs  = 5000.0
Vcc = 330.0;
theta = 9.0 # Compensando o filtro LCL

table = [
    (Pn,             0),
    (Pn,           200),
    (Pn,          -200),

    (0.8 * Pn,       0),
    (0.8 * Pn,  Pn / 4),
    (0.8 * Pn, -Pn / 4),

    (1.2 * Pn,       0),
    (1.2 * Pn,  Pn / 4),
    (1.2 * Pn, -Pn / 4),
]

## Calculo de V:
def calc_V(P, Q, XL):
    V_rms = np.sqrt((2.0*Q*XL + Vn**2 + np.sqrt((2.0*Q*XL + Vn**2)**2 - \
            4*(P**2 + Q**2)*(XL**2)))/2.0)
    V_ang = (180.0 / np.pi)*np.arcsin((P*XL)/(V_rms * Vn))

    return (V_rms, V_ang)

xl = 2 * np.pi * 60 * (Lf1 + Lf2);
schematic = 'GridConnection.psimsch'

if __name__ == '__main__':
    for n, (p, q) in enumerate(table):
        v_rms, v_ang = calc_V(p, q, xl)
        print(v_rms, v_ang)
        vars = {
            "ma": (Vn * np.sqrt(2)) / Vcc,
            "theta": v_ang,
            "fs": fs, "Vcc": Vcc, "Lf1": Lf1,
            "Lf2": Lf2, "Cf": Cf, "Rd": Rd,
        }
        output = f'data/sim_{n}.txt'
        run_simulation(schematic, output, variables=vars)
