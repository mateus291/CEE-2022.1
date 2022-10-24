import subprocess

def run_simulation(schematic, output, variables, t=0.1, s=1e-5):
    variables_str = [f'-v "{name}={value}" ' for name, value in variables.items()]
    subprocess.run(f'PsimCmd -i {schematic} -o {output} {variables_str} -t {t} -s {s}')