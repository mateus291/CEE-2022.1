import glob
import re
import os

def remove_files(root_dir):
    files = glob.glob(root_dir + '/*')
    for f in files:
        os.remove(f)

def find_files(root_dir, extension):
    list_files = glob.glob(f'{root_dir}/**/*{extension}', recursive=True)
    
    return list_files

def find_dirs(root_dir):
    list_dirs = glob.glob(f'{root_dir}/**/', recursive = False)

    return list_dirs

def get_file(input):
    output = os.path.basename(input)
    return output

def get_dir(input):
    output = os.path.dirname(input)
    return output

def change_output_number(input, number):
    pattern = '\d*.txt'
    repl = str(number) + '.txt'

    output = re.sub(pattern, repl, input)
    return output