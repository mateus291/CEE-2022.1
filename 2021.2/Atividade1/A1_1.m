%% Atividade 1 - Problema do fluxo de potencia para as fontes em paralelo
% Autor: Mateus Soares Marques (mateus.marques@ee.ufcg.edu.br)
% Disciplina: Conversores Estáticos e Eletromecânicos

%%
close all
clear all
clc

%% Calculando Vg

Vr = 220;
Icc = 25;
Xl = Vr/(2*Icc);
L = Xl/(2*pi*60);

Pg_max = Vr*Icc;
Qg_max = Vr*Icc/2;

[X, Y] = meshgrid([0, Pg_max/2, -Pg_max/2], [0, Qg_max/2, -Qg_max/2]);

Pg = reshape(X, [numel(X), 1]); Pg = Pg(2:end); % Não nos interessa o par
Qg = reshape(Y, [numel(Y), 1]); Qg = Qg(2:end); % Pg = 0    e   Qg = 0

Vg_rms = real(sqrt((2*Qg*Xl + Vr^2 + sqrt((2*Qg*Xl + Vr^2).^2 - ...
                    4*(Pg.^2 + Qg.^2)*Xl^2))/2));

Vg_ang = real((180/pi)*asin((Pg*Xl)./(Vg_rms * Vr)));

%% Simulando no PSIM:

[circuit_path, output_dir, params_path] = getPaths("PowerFlux");

paramsKeys = {'Vg_rms', 'Vg_ang', 'L'};
t = 0.2; dt = 1e-5;

for i=1:numel(Pg)
    
    fprintf('Simulation %02d\n', i);
    output_path = output_dir + sprintf('sim%02d.txt', i);
    paramsMap = containers.Map(paramsKeys, [Vg_rms(i), Vg_ang(i), L]);
    
    runPSIM(circuit_path, output_path, params_path, paramsMap, t, dt);
    
end


%% Analisando os resultados:

clc
oldDir = cd("Circuits/PowerFlux/data");
f_ = ls; f_list = strip(string(f_(3:end, :)));

[m, ~] = size(f_list);

Pg_PSIM = zeros(m, 1);
Qg_PSIM = zeros(m, 1);

for i = 1:m
    
    A = readtable(f_list(i, :));
    Pg_PSIM(i) = A.Pg(end);
    Qg_PSIM(i) = A.Qg(end);
    
end

cd(oldDir);

err = (sqrt(Pg.^2 + Qg.^2)-sqrt(Pg_PSIM.^2 + Qg_PSIM.^2))./sqrt(Pg_PSIM.^2 + Qg_PSIM.^2);

Results = table(Pg, Qg, Vg_rms, Vg_ang, Pg_PSIM, Qg_PSIM, err);
Results_mse = sqrt(mean(err.^2));

%% Tabela de Resultados:

disp("Results:");
disp(Results);

disp("MSE:");
disp(Results_mse);

oldDir = cd("Circuits/PowerFlux");
writetable(Results, 'PowerFlux.csv');
cd(oldDir);

%%


