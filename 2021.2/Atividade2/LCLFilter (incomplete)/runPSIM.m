%% Atividade 1 - fun��o runPSIM
% Autor: Mateus Soares Marques (mateus.marques@ee.ufcg.edu.br)
% Disciplina: Conversores Est�ticos e Eletromec�nicos

%% Obs:
% Para que essa fun��o funcione corretamente, � necess�rio adicionar a
% vari�vel de ambiente PSIMCMD �s vari�veis do sistema. O valor de PSIMCMD
% deve ser correspondente ao caminho completo do arquivo execut�vel
% PsimCmd.exe, existente na pasta de instala��o do PSIM no seu computador.

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


