clc
clear all
close all

%% Operação na potência nominal Pn:

NominalOp_simdata = readtable("data\nominal\sim.txt");

Vo = NominalOp_simdata.Vo_;

[wthd_, ~, ~] = wthd(Vo, 60, 1/1e-5, 30);
[f, V_mag, V_phase] = spectrum(Vo, 1/1e-5);

fig1 = ...
figure('Name', 'Espectro de Vo', 'Position', [50, 200, 600, 400]);
subplot(211);
plot(f, V_mag / sqrt(2), 'LineWidth', 1.5); grid on;
xlim([0 11*60]); ylabel('mag(V_{rms})');

title('Espectro da tensão V_{o1} de saída do filtro LCL (potência nominal)');

subplot(212);
plot(f, (180/pi) * V_phase, 'LineWidth', 1.5); grid on;
xlim([0 11*60]); ylabel('\theta(º)');

xlabel('f(Hz)');

%% Variando a carga:

files = string(ls("data/varying_load"));
files = files(startsWith(files, "sim"));
P = double(extract(files, digitsPattern));

clear Vo
Vo_mag = zeros(numel(P), 1);
Vo_phase = zeros(numel(P), 1);

for i = 1:numel(P)
    varyingP_simdata = readtable(strcat("data/varying_load/", files(i)));
    Vo = varyingP_simdata.Vo_;
    [~, hm, hp] = wthd(Vo, 60, 1/1e-5, 1);
    Vo_mag(i) = hm(1) / sqrt(2);
    Vo_phase(i) = (180/pi) * hp(1);
end

fig2 = ...
figure('Name', 'Efeito da variação de carga em Vo', ...
    'Position', [650, 200, 600, 400]);
yyaxis left
p = plot(P, Vo_mag, 'LineWidth', 1.5); grid on;
ylabel('Mag (V_{rms})');
yyaxis right
p = plot(P, Vo_phase, 'LineWidth', 1.5); grid on;
ylabel('\theta(º)');

xlabel('P(W)');
title('Efeito da variação da carga sobre V_{o1}');

%% Variando a frequência de chaveamento:

clear files

files = string(ls("data/varying_fs"));
files = files(startsWith(files, "sim"));
fs = double(extract(files, digitsPattern));

clear Vo Vo_mag Vo_phase
Vo_mag = zeros(numel(fs), 1);
Vo_phase = zeros(numel(fs), 1);

for i = 1:numel(fs)
    varyingFs_simdata = readtable(strcat("data/varying_fs/", files(i)));
    Vo = varyingFs_simdata.Vo_;
    [~, hm, hp] = wthd(Vo, 60, 1/1e-5, 1);
    Vo_mag(i) = hm(1) / sqrt(2);
    Vo_phase(i) = (180/pi) * hp(1);
end

fig3 = ...
figure('Name', 'Efeito da variação de fs em Vo', ...
    'Position', [1250, 200, 600, 400]);
yyaxis left
p = plot(fs, Vo_mag, 'LineWidth', 1.5); grid on;
ylabel('Mag (V_{rms})');

yyaxis right
plot(fs, Vo_phase, 'LineWidth', 1.5); grid on;
ylabel('\theta(º)');

xlabel('f_s(Hz)');
title('Efeito da variação da frequência de chaveamento sobre V_{o1}');

%% Salvando imagens:

saveas(fig1, "Imagens/nominal.png");
saveas(fig2, "Imagens/varying_load.png");
saveas(fig3, "Imagens/varying_fs.png");

