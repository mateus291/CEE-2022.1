%% WTHD:
function [r, harms_mag, harms_phase] = wthd(v, fr, fs, n)
    L = length(v);

    V = fft(v); V = V/L; 
    V = V(1:(L/2+1)); 
    V(2:end) = 2*V(2:end);

    f = fs/L*(0:(length(V)-1))';
    
    harms = fr*(1:n)'; 
    harms_mag = zeros(n, 1);
    harms_phase = zeros(n, 1);
    
    for i = 1:n
        harms_mag(i) = abs(V(abs(f-harms(i))==min(abs(f-harms(i)))));
        harms_phase(i) = angle(V(abs(f-harms(i))==min(abs(f-harms(i)))));
    end
    
    r = sqrt(sum((harms_mag(2:end)./(2:n)').^2)) / harms_mag(1);
end
