%% Variando o índice de modulação em amplitude (mf = 100)
% Autor: Mateus Soares Marques

%%
close all
clear all
clc

%%
oldDir = cd('Circuits');
dirs = ls;

circuits = strip(string(dirs(3:end, :)));
cd(oldDir);

%% Simulação - Vcc fixo e ma variando (0.5 < ma < 1.0):

paramsKeys = {'mf', 'ma', 'Vcc'};
Vcc = 350;
mf = 100;
ma = (0.5:0.01:1.0);

% Tempo total e passo de simulação:
tf = 0.1; dt = 1e-5;

%% Simulações:
diary on
for i = 1:numel(circuits)    
    for j = 1:numel(ma)
        clc
        [circuit_path, output_dir, params_path] = getPaths(circuits(i));
        fprintf("Circuit: %s\nSimulation - %02d/%02d\n\n",...
            circuits(i), j, numel(ma));
        output_path = output_dir + sprintf('sim%02d.txt', j);
        paramsMap = containers.Map(paramsKeys, [mf, ma(j), Vcc]);
        runPSIM(circuit_path, output_path, params_path, paramsMap, tf, dt);
        diary
    end
    
end

%%
diary off;
disp('diary for more details');

%% Analisando os resultados:

% Coletando os resultados das pastas (passando para simData):
simData = cell(0);
for i = 1:numel(circuits)
    dataDir = cd("Circuits/" + circuits(i) + "/data");
    var = 'Vo';
    if(circuits(i) == "3PhaseInverterPWM")
        var = 'V1N';
    end
    
    simFilesName = ls;
    simFiles = strip(string(simFilesName(3:end, :)));

    wthd_ = zeros(numel(simFiles), 1);
    for j = 1:numel(simFiles)
        A = readtable(simFiles(j));
        out = table2array(A(:, var));
        wthd_(j) = wthd(out, 60, 1/dt, mf + 4);
    end
    simData{i} = {circuits(i), wthd_, A};
    cd(dataDir);
end

%% Plotando:

mrks = ["-", "-.", "o", "-"];

figure; 
hold on
for i = 1:numel(circuits)
    plot(ma, 100*simData{i}{2}, mrks(i), 'LineWidth', 1.1);
end
hold off
legend(circuits);
xlabel('m_a'); ylabel('WTHD_{v}(%)');
title('Taxa de dist. harmônica para (0.5 < ma < 1)');
grid on

figure;
for i = 1:numel(circuits)
    if(circuits(i) == "3PhaseInverterPWM")
        v = 'V1N';
        s = 'V_{1N}';
    else
        v = 'Vo';
        s = 'V_o';
    end
    subplot(4,1,i);
    Time = table2array(simData{i}{3}(:, 'Time'));
    V = table2array(simData{i}{3}(:, v));
    plot(Time, V, 'LineWidth', 1.1);
    xlabel('Tempo (s)'); ylabel('Tensão (V)'); grid on
    xlim([0, 0.05]);
    title(sprintf('%s (%s)', s, circuits(i)));
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



