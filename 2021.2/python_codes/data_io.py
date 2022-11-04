import pandas as pd

def import_psim_data(file):
    df = pd.read_csv(file, sep = '\s+', engine='c')

    return df

def import_params_to_array(file): 
    df = pd.read_csv(file, sep=';', engine='c', thousands='.', decimal=',')

    arr = []
    row_number = len(df.index)
    for i in range(row_number):
        s = df.iloc[i]
        arr.append(list(zip(s.index, s)))

    return arr

