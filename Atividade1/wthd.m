%% WTHD:
function r = wthd(v, fr, fs, n)
    L = length(v);

    V = fft(v); V = abs(V)/L; 
    V = V(1:(L/2+1)); 
    V(2:end) = 2*V(2:end);

    f = fs/L*(0:(length(V)-1))';
    
    harms = fr*(1:n)'; 
    harms_mag = zeros(n, 1);
    
    for i = 1:n
        harms_mag(i) = V(abs(f-harms(i))==min(abs(f-harms(i))));
    end
    
    r = sqrt(sum((harms_mag(2:end)./(2:n)').^2)) / harms_mag(1);
end
