%% Atividade 1 - função runPSIM
% Autor: Mateus Soares Marques (mateus.marques@ee.ufcg.edu.br)
% Disciplina: Conversores Estáticos e Eletromecânicos

%% Obs:
% Para que essa função funcione corretamente, é necessário adicionar a
% variável de ambiente PSIMCMD às variáveis do sistema. O valor de PSIMCMD
% deve ser correspondente ao caminho completo do arquivo executável
% PsimCmd.exe, existente na pasta de instalação do PSIM no seu computador.

%%
function runPSIM(circuit_path, output_path, params_path, paramsMap, t, dt)
    
circuit = strcat('"', circuit_path, '"');
output = strcat('"', output_path, '"');

if(~isempty(paramsMap))
    keySet = keys(paramsMap);
    params = "";

    for i = 1:numel(keySet)
        params = params + keySet{i} + "=" + sprintf('%0.4E\n', paramsMap(keySet{i}));
    end
    
    f = fopen(params_path, 'wt');
    fprintf(f, params); fclose(f);
end
                        
command = strcat('"%PSIMCMD%"', sprintf(' -i %s -o %s', circuit, output),...
    sprintf(' -t "%0.4f" -s "%0.0E"', t, dt));
system(command);

end


