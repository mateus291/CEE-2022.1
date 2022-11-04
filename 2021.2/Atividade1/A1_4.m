%% Atividade 1 - Problema do inversor trifásico
% Autor: Mateus Soares Marques (mateus.marques@ee.ufcg.edu.br)
% Disciplina: Conversores Estáticos e Eletromecânicos

%%
close all
clear all
clc

%% Simulando Inversor de Ponte completa no PSIM:

[circuit_path, output_dir, params_path] = getPaths("3PhaseInverter");
t = 0.1; dt = 1e-5;

output_path = output_dir + "sim00.txt";
disp('Simulation: 3PhaseInverter');
runPSIM(circuit_path, output_path, params_path, [], t, dt);

oldDir = cd("Circuits/3PhaseInverter/data");
A = readtable("sim00.txt");
cd(oldDir);

Time = table2array(A(:, 'Time'));
V1N = table2array(A(:, 'V1N'));
V12 = table2array(A(:, 'V12'));
wthd_1N = wthd(V1N, 60, (1/dt), 21);
wthd_12 = wthd(V12, 60, (1/dt), 21);

[f1N, HV1N] = spectrum(V1N, (1/dt));
[f12, HV12] = spectrum(V12, (1/dt));

figure('Name', 'V1N');
subplot(211);
plot(Time, V1N, 'LineWidth', 1.0); grid on
xlabel('Tempo (s)'); ylabel('Tensão (V)');
title('Tensão de fase V_{1N}', 'interpreter', 'tex');
subplot(212);
plot(f1N, HV1N, 'LineWidth', 1.0); grid on
xlim([0, 21*60]); xticks(60*(1:2:21)');
xlabel('Frequência (Hz)'); ylabel('Tensão (V)');
title(sprintf('Espectro de V_{1N} (WTHD = %.2f%%)', 100*wthd_1N), 'interpreter', 'tex');

figure('Name', 'V12');
subplot(211);
plot(Time, V12, 'LineWidth', 1.0); grid on
xlabel('Tempo (s)'); ylabel('Tensão (V)');
title('Tensão de linha V_{12}', 'interpreter', 'tex');
subplot(212);
plot(f12, HV12, 'LineWidth', 1.0); grid on
xlim([0, 21*60]); xticks(60*(1:2:21)');
xlabel('Frequência (Hz)'); ylabel('Tensão (V)');
title(sprintf('Espectro de V_{12} (WTHD = %.2f%%)', 100*wthd_12), 'interpreter', 'tex');

%%

