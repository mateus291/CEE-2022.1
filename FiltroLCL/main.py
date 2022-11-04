import numpy as np
import os

def run_simulation(schematic: str, output: str, variables:dict={}, 
                   total_time=0.1, time_step=1e-5):
    variables_str = ' '.join([f'-v "{name}={value}"' \
        for name, value in variables.items()])
    os.system(f'PsimCmd -i "{schematic}" -o "{output}" {variables_str} -t "{total_time}" -s "{time_step}"')

## Parâmetros (operação nominal):
Vn = 220.0; Pn = 4100.0; Lf1 = 3.0e-3; Lf2 = 2.0e-3
Cf  = 2.2e-6; Rd  = 10.0; ma  = 0.95; fs  = 5000.0
Vcc = 1.01 * (Vn * np.sqrt(2) / ma); Ro = (Vn ** 2) / Pn

## Operação na Potência nominal:
nominal_op = {
    "ma": ma, "fs": fs, "Vcc": Vcc, "Lf1": Lf1,
    "Lf2": Lf2, "Cf": Cf, "Rd": Rd, "Ro": Ro,
}
output_nom = "data/nominal/sim.txt"

# Variando a carga (+/- 20% da Potência nominal):
P = [ (1 + 0.01 * r) * Pn for r in range(-20, 22, 2)]
varying_P = [
    {
        "variables": {
            "ma": ma, "fs": fs, "Vcc": Vcc, "Lf1": Lf1,
            "Lf2": Lf2, "Cf": Cf, "Rd": Rd, "Ro": (Vn ** 2) / p_i,
        },
        "output": f"data/varying_load/sim_{int(p_i)}.txt",
    } for p_i in P
]

## Variando a frequência de chaveamento (+/- 50% de fs):
fs_ = [(1 + 0.01 * r) * fs for r in range(-50, 51, 1)]
varying_fs = [
    {
        "variables": {
            "ma": ma, "fs": fs_i, "Vcc": Vcc, "Lf1": Lf1,
            "Lf2": Lf2, "Cf": Cf, "Rd": Rd, "Ro": Ro,
        },
        "output": f"data/varying_fs/sim_{int(fs_i)}.txt",
    } for fs_i in fs_
]

## Simulações:
schematic = "UnipolarFullBridge.psimsch"

if __name__ == "__main__":
    run_simulation(schematic, output_nom, variables=nominal_op)

    for vars in varying_P:
        run_simulation(schematic, vars["output"], variables=vars["variables"])
    
    for vars in varying_fs:
        run_simulation(schematic, vars["output"], variables=vars["variables"])


