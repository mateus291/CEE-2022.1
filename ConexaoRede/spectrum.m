%% Spectrum:
function [f, V_mag] = spectrum(v, fs)
    L = length(v);

    V = fft(v); V = V/L; 
    V = V(1:(L/2+1)); 
    V(2:end) = 2*V(2:end);

    V_mag = abs(V);

    f = fs/L*(0:(length(V)-1))';
end