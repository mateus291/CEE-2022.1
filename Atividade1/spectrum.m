%% Spectrum:
function [f, V] = spectrum(v, fs)
    L = length(v);

    V = fft(v); V = abs(V)/L; 
    V = V(1:(L/2+1)); 
    V(2:end) = 2*V(2:end);

    f = fs/L*(0:(length(V)-1))';
end