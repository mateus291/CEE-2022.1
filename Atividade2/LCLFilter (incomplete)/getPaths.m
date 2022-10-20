%% Atividade 1 - Fun��o getPaths
% Autor: Mateus Soares Marques (mateus.marques@ee.ufcg.edu.br)
% Disciplina: Conversores Est�ticos e Eletromec�nicos

%%
function [circuit_path, output_dir, params_path] = getPaths(circuit_name)

circuits_dir = cd + "\Circuits\";

circuit_dir = circuits_dir + circuit_name + "\";
circuit_path = circuit_dir + circuit_name + ".psimsch";

output_dir = circuit_dir + "data\";
params_path = circuit_dir + circuit_name + "-params.txt";

end

