%% Atividade 1 - script simFromAppScript
% Autor: Mateus Soares Marques (mateus.marques@ee.ufcg.edu.br)
% Disciplina: Conversores Estáticos e Eletromecânicos

%% Obs:
% Este script não é para ser executado diretamente. Ele é chamado dentro do
% app para operar com arquivos e realizar a simulação do circuito conforme
% solicitado pelo usuário do app. A execução desse script fora desse
% contexto implica em erro.

%% simFromAppScript

clc

[circuit_path, output_dir, params_path] = getPaths("PowerFlux");

paramsKeys = {'Vg_rms', 'Vg_ang', 'L'};
t = 1; dt = 1e-5;

output_path = output_dir + "AppSim.txt";
paramsMap = containers.Map(paramsKeys, [Vg_rms, Vg_ang, L]);

runPSIM(circuit_path, output_path, params_path, paramsMap, t, dt);

oldDir = cd("Circuits/PowerFlux/data");

A = readtable("AppSim.txt");

n = length(A.Time);
Time = A.Time((n - ceil(0.05/dt)):end);

Pg_PSIMv = A.Pg((n - ceil(0.05/dt)):end);
Qg_PSIMv = A.Qg((n - ceil(0.05/dt)):end); 


Pg_PSIM = mean(Pg_PSIMv); Qg_PSIM = mean(Qg_PSIMv);
Vg = A.Vg((n - ceil(0.05/dt)):end);
Vr = A.Vr((n - ceil(0.05/dt)):end);

cd(oldDir);

PgError = Pg - Pg_PSIM;
QgError = Qg - Qg_PSIM;

erro = (sqrt(Pg.^2 + Qg.^2) - sqrt(Pg_PSIM.^2 + Qg_PSIM.^2)) ./ ...
    sqrt(Pg_PSIM.^2 + Qg_PSIM.^2);

