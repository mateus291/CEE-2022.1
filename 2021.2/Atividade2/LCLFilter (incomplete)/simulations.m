%% Simulações dos circuitos
% Autor: Mateus Soares Marques

%%
close all
clear all
clc

%% Simlulando os inversores com filtro LC:

oldDir = cd('Circuits');
dirs = ls;

circuits = strip(string(dirs(3:end, :)));
cd(oldDir);

%%

paramsKeys = {'mf', 'ma', 'Vcc', 'Ro', 'Lf1', 'Lf2', 'Cf'};
mf = 150; ma = 0.95;
Ro = 10;

Vo1 = 220*sqrt(2); % Tensão de fase;

Vcc = [2*Vo1/ma; Vo1/ma; 2*Vo1/ma; Vo1/ma];

%% Filtro LC (monofásico e trifásico com capacitores em Y):

z = 0.85;% <= coeficiente de amortecimento;

fr = 60; fq = mf*fr;
fo = 10*fr + (fq/10 - 10*fr)/2;

Cf = 1/(4*pi*z*fo*Ro);
Lf = 1/(Cf*(2*pi*fo)^2);


%% Simulações

% Tempo total e passo de simulação:
t = 0.1; dt = 1e-5;

diary on

for i = 1:numel(circuits)
    [circuit_path, output_dir, params_path] = getPaths(circuits(i));
    fprintf("Circuit: %s\n\n", circuits(i));
    output_path = output_dir + "sim.txt";
    paramsMap = containers.Map(paramsKeys, [mf, ma, Vcc(i), Ro, Lf, Cf]);
    runPSIM(circuit_path, output_path, params_path, paramsMap, t, dt);
    diary
end

%%
diary off;
disp('log.txt for more details');

%% Analisando os resultados:

% Coletando os resultados das pastas (passando para simData):
simData = cell(0);
for i = 1:numel(circuits)
    dataDir = cd("Circuits/" + circuits(i) + "/data");
    var = 'Vo_';
    if(circuits(i) == "3PhaseInverterPWM")
        var = 'V1N';
    end
    A = readtable('sim.txt');
    out = table2array(A(:, var));
    time = table2array(A(:, 'Time'));
    wthd_ = wthd(out, 60, (1/dt), 3);
    [f, S] = spectrum(out, (1/dt));

    simData{i} = {circuits(i), {time, out}, {f, S}, wthd_};
    cd(dataDir);
end

%% Plotando:
for i = 1:numel(circuits)
    var = 'Vo_';
    if(circuits(i) == "3PhaseInverterPWM")
        var = 'V1N';
    end
    figure('Name', circuits(i));
    
    subplot(211);
    plot(simData{i}{2}{1}, simData{i}{2}{2}, 'LineWidth', 1.0);
    xlabel('Tempo (s)'); ylabel('Tensão (V)');
    title(sprintf('Tensão na carga (Ro = %d, Vcc = %.2f)', Ro, Vcc(i)));
    
    subplot(212);
    plot(simData{i}{3}{1}, simData{i}{3}{2}/sqrt(2), ...
        'LineWidth', 1.0);
    xlim([0, 300])
    xlabel('Frequência (Hz)'); ylabel('Tensão (Vrms)');
    title(sprintf('Espectro (WTHD(%%) = %0.2f)',...
        100*simData{i}{4}));
end



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

%% Spectrum:
function [f, V] = spectrum(v, fs)
    L = length(v);

    V = fft(v); V = abs(V)/L; 
    V = V(1:(L/2+1)); 
    V(2:end) = 2*V(2:end);

    f = fs/L*(0:(length(V)-1))';
end


