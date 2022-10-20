%% Atividade 1 - script simFromAppScript2
% Autor: Mateus Soares Marques (mateus.marques@ee.ufcg.edu.br)
% Disciplina: Conversores Estáticos e Eletromecânicos

%% Obs:
% Este script não é para ser executado diretamente. Ele é chamado dentro do
% app para operar com arquivos e realizar a simulação do circuito conforme
% solicitado pelo usuário do app. A execução desse script fora desse
% contexto implica em erro.

%% simFromAppScript2

clc

[circuit_path, output_dir, params_path] = getPaths("FullBridge2");

paramsKeys = {'alpha'};
t = 1; dt = 1e-5;

output_path = output_dir + "AppSim.txt";
paramsMap = containers.Map(paramsKeys, [alpha]);

runPSIM(circuit_path, output_path, params_path, paramsMap, t, dt);

oldDir = cd("Circuits/FullBridge2/data");

A = readtable("AppSim.txt");

n = length(A.Time);

r = thd(A.Vo, 1/(1e-5), 20);

Time = A.Time((n - ceil(0.05/dt)):end);
Vq1 = A.Vq1((n - ceil(0.05/dt)):end);
Vq2 = A.Vq2((n - ceil(0.05/dt)):end); 
Vo = A.Vo((n - ceil(0.05/dt)):end);

cd(oldDir);

