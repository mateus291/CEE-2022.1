%% Atividade 1 - Problema dos inversores de meia ponte e ponte completa
% Autor: Mateus Soares Marques (mateus.marques@ee.ufcg.edu.br)
% Disciplina: Conversores Estáticos e Eletromecânicos

%%
close all
clear all
clc

%% Simulando Inversor de Ponte completa no PSIM:

[circuit_path, output_dir, params_path] = getPaths("FullBridge");
t = 0.2; dt = 1e-5;

output_path = output_dir + "sim00.txt";
disp('Simulation: FullBridge');
runPSIM(circuit_path, output_path, params_path, [], t, dt);

oldDir = cd("Circuits/FullBridge/data");
A = readtable("sim00.txt");
cd(oldDir);

Time = table2array(A(:, 'Time'));
Vo = table2array(A(:, 'Vo'));
wthd_1 = wthd(Vo, 60, (1/dt), 21);

[f1, HVo1] = spectrum(Vo, (1/dt));

figure('Name', 'Results');
subplot(211);
plot(Time, Vo, 'LineWidth', 1.0, 'Color', 'r');hold on;grid on
xlabel('Tempo (s)'); ylabel('Tensão (V)');
title('Tensão de saída V_o', 'interpreter', 'tex');
subplot(212);
plot(f1, HVo1, 'LineWidth', 1.0, 'Color', 'r');hold on;grid on
xlim([0, 21*60]); xticks(60*(1:2:21)');
xlabel('Frequência (Hz)'); ylabel('Tensão (V)');
title('Espectro de Vo');


%% Simulando Inversor de Meia-Ponte no PSIM:

[circuit_path, output_dir, params_path] = getPaths("HalfBridge");

output_path = output_dir + "sim00.txt";
disp('Simulation: HalfBridge');
runPSIM(circuit_path, output_path, params_path, [], t, dt);

oldDir = cd("Circuits/HalfBridge/data");
A = readtable("sim00.txt");
cd(oldDir);

Time = table2array(A(:, 'Time'));
Vo = table2array(A(:, 'Vo'));
wthd_2 = wthd(Vo, 60, (1/dt), 21);

[f2, HVo2] = spectrum(Vo, (1/dt));

subplot(211);
plot(Time, Vo, 'LineWidth', 1.0, 'Color', 'Cyan');hold off
subplot(212);
plot(f2, HVo2, 'LineWidth', 1.0, 'Color', 'Cyan');hold off

s = @(str,wthd_) sprintf('%s\n(WTHD=%.2f%%)', str, 100*wthd_);
legend({s('ponte-completa',wthd_1), s('meia-ponte', wthd_2)});


%%

