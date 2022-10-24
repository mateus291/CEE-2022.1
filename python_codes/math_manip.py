from scipy.fft import fft, fftfreq
import numpy as np
from scipy.signal import find_peaks

def spectrum(t, x):
    timestep = t[1] - t[0]
    n = len(t)
    
    X = 2/n*np.abs(fft(x)[0:n//2])
    f = fftfreq(n, timestep)[:n//2]

    return f, X

def harmonics_amplitudes(V_array):

    V_array = V_array[1:]
    V1 = max(V_array)

    peaks, _ = find_peaks(V_array, height = 0.01*V1)

    harmonics = [round((peak+1)/(peaks[0]+1)) for peak in peaks]
    harmonic_heights = _['peak_heights']

    return harmonics, harmonic_heights

def thd(V_array):
    V_array = V_array[1:]
    V1 = max(V_array)
    
    height = 0.01*V1
    peaks, _ = find_peaks(V_array, height=height)
    
    V_sq_sum = 0.0
    for i in peaks:
        V_sq_sum += V_array[i]**2

    V_sq_except_fundamental = V_sq_sum - V1**2
    thd = V_sq_except_fundamental**0.5/V1
    return thd

def w_thd(V_array):
    V_array = V_array[1:]
    V1 = max(V_array)
    
    peaks, _ = find_peaks(V_array, height=0.01*V1)
    
    V_sqh_sum = 0.0

    for i in peaks:
        harmonic = (i+1)/(peaks[0]+1)
        V_sqh_sum += (V_array[i]/harmonic)**2

    V_sqh_except_fundamental = V_sqh_sum - V1**2
    wthd = V_sqh_except_fundamental**0.5/V1
    return wthd