%% Atividade 1 - Problema da onda quadrada modificada
% Autor: Mateus Soares Marques (mateus.marques@ee.ufcg.edu.br)
% Disciplina: Conversores Est�ticos e Eletromec�nicos

%%
close all
clear all
clc

%% Simulando Inversor de Ponte completa (onda modificada) no PSIM:

[circuit_path, output_dir, params_path] = getPaths("FullBridge2");

paramsKeys = {'alpha'};
alpha = 0:1:89;

t = 0.2; dt = 1e-5;

for i = 1:numel(alpha)
    
    fprintf('Simulation %02d\n', i);
    output_path = output_dir + sprintf('sim%02d.txt', i);
    paramsMap = containers.Map(paramsKeys, [alpha(i)]);
    runPSIM(circuit_path, output_path, params_path, paramsMap, t, dt);

end

%% Analisando os Resultados:

oldDir = cd("Circuits/FullBridge2/data");
f_list = ls; f_list = f_list(3:end, :);

[m, ~] = size(f_list);

num_harms = 30; % N�mero de harm�nicas consideradas no c�lculo;
A = cell(m, 1); r = zeros(m, 1); harms_mag = zeros(m, num_harms);
for i = 1:m
    
    A{i} = readtable(f_list(i, :));
    [r(i), harms_mag(i, :)] = ...
        wthd(table2array(A{i}(:, 'Vo')), 60, (1/dt), num_harms);
    
end

cd(oldDir);

%% Plotando (WTHD vs alpha):

clc
THD_min.THD = min(r);
THD_min.alpha = alpha(r == min(r));
disp('THD_min:');
disp(THD_min);

figure('Name', 'WTHDs');
plot(alpha, 100*r, THD_min.alpha, 100*THD_min.THD, 'o', 'LineWidth', 1.1);
grid on
xlabel('\alpha (�)'); ylabel('WTHD (%)');
legend({'WTHD', 'WTHD_{min}'}, 'Location', 'West', 'Interpreter', 'tex');
title('Distor��o harm�nica total em fun��o do �ngulo de chaveamento');


%% Espectro para diferentes valores de alpha:

figure('Name', 'Amplitude das harm�nicas em fun��o de alpha');
hold on
for i = 1:2:9
    plot(alpha, harms_mag(:, i), 'LineWidth', 1.1);
end
plot(THD_min.alpha*[1, 1], [0, 140], 'k--', 'LineWidth', 1);
hold off
xlabel('\alpha (�)'); ylabel('Tens�o (V)'); 
legend({'1�', '3�', '5�', '7�', '9�', 'WTHD_{min}'}, ...
    'Location', 'NorthEast', 'Interpreter', 'tex');
title('Amplitude das harm�nicas em fun��o do �ngulo de chaveamento');
grid on

%% Espectro para WTHD_min:

figure('Name', 'Espectro de Vo');
plot(f, V, 'LineWidth', 0.9); grid on
xlim([0, 60*21]); xticks(60*(1:2:21)');
xlabel('Frequ�ncia (Hz)');
ylabel('Tens�o (V)');
title(sprintf('Espectro de Vo para alpha = %3.2f�', THD_min.alpha));


%% Gr�fico Ilustrativo da sa�da do conversor:

Vo = table2array(A{r == min(r)}(:, 'Vo'));
Time = table2array(A{r == min(r)}(:, 'Time'));
vq1 = table2array(A{r == min(r)}(:, 'Vq1'));
vq2 = table2array(A{r == min(r)}(:, 'Vq2'));
[f, V] = spectrum(Vo, (1/dt));

figure('Name', 'Abstract');
subplot(311);
plot(Time, vq1, 'LineWidth', 1.0); xlim([0, 0.05]);
xticks(0.05/6*(0:6)'); xticklabels({'0', '180', '360', '540', '720', '900', '1080'});
xlabel('\omega t(�)'); ylabel('q_1'); yticks([]);
subplot(312);
plot(Time, vq2, 'LineWidth', 1.0); xlim([0, 0.05]);
xticks(0.05/6*(0:6)'); xticklabels({'0', '180', '360', '540', '720', '900', '1080'});
xlabel('\omega t(�)'); ylabel('q_2'); yticks([]);
subplot(313);
plot(Time, Vo, 'LineWidth', 1.0); xlim([0, 0.05]);
xticks(0.05/6*(0:6)'); xticklabels({'0', '180', '360', '540', '720', '900', '1080'});
xlabel('\omega t(�)'); ylabel('V_o');
yticks([-100, 0, 100]); yticklabels({'-V_{cc}','0', '+V_{cc}'});


%% WTHD:
function [r, harms_mag] = wthd(v, fr, fs, n)
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

