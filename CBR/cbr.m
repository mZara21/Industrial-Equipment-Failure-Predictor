clear; clc;

caminho_deste_script = fileparts(which(mfilename));
cd(caminho_deste_script);
addpath('../tratamento');

fprintf('SISTEMA DE RACIOCÍNIO BASEADO EM CASOS\n\n');

nome_ficheiro_norm = '../dataset_final_3_1_normalizado.csv';
nome_ficheiro_bruto = '../dataset_final_3_1_BRUTO.csv';
nome_ficheiro_teste = '../dataset_TP_test.csv';

if ~isfile(nome_ficheiro_norm) || ~isfile(nome_ficheiro_bruto)
    fprintf('Ficheiros base não encontrados. A iniciar limparDataset()...\n');
    limparDataset();
end

case_library_norm = readtable(nome_ficheiro_norm);
case_library_bruto = readtable(nome_ficheiro_bruto);

% Usamos o dataset bruto para saber as escalas reais do treino
matriz_bruta = table2array(case_library_bruto(:, 1:14));
global_mins = min(matriz_bruta);
global_maxs = max(matriz_bruta);

% preparar teste
if ~isfile(nome_ficheiro_teste)
    fprintf('\nErro: Ficheiro %s não encontrado!\n', nome_ficheiro_teste);
    return;
end

test_data = readtable(nome_ficheiro_teste);
[test_clean, ~] = converterTeste(test_data); 

% Normalizar o teste
test_matriz = table2array(test_clean);
test_norm = (test_matriz - global_mins) ./ (global_maxs - global_mins + eps);
test_clean_norm = array2table(test_norm, 'VariableNames', test_clean.Properties.VariableNames);

% selecionar o teste
total_testes = height(test_clean_norm);
fprintf('A base de testes tem %d casos disponíveis.\n', total_testes);

idx_teste = -1; 
while isempty(idx_teste) || ~isnumeric(idx_teste) || idx_teste < 1 || idx_teste > total_testes || rem(idx_teste, 1) ~= 0
    prompt = sprintf('Escolha o índice do caso que pretende diagnosticar (1 a %d): ', total_testes);
    idx_teste = input(prompt);
end

novo_caso = test_clean_norm(idx_teste, :);
fprintf('\nNovo caso (Linha %d) carregado e NORMALIZADO para diagnóstico.\n', idx_teste);

% ciclo cbr

% RETRIEVE
fprintf('\nRETRIEVE \n');
threshold = 0.90;

[indices, similarities] = CBR_retrieve(case_library_norm, novo_caso, threshold);

if isempty(indices)
    fprintf('Nenhum caso encontrado com similaridade >= %.2f%%\n', threshold*100);
    fprintf('O ciclo CBR será interrompido pois não há base de comparação.\n');
    return;
else
    fprintf('Foram encontrados %d casos semelhantes acima do threshold:\n', length(indices));
    resultados_norm = case_library_norm(indices, :);
    matriz_norm = table2array(resultados_norm(:, 1:14));
    
    % Desnormalizar
    matriz_denorm = (matriz_norm .* (global_maxs - global_mins)) + global_mins;
    resultados_reais = array2table(matriz_denorm, 'VariableNames', case_library_norm.Properties.VariableNames(1:14));
    
    % Traduzir números para texto
    resultados_reais.maintenance_level = inverseOrder(matriz_denorm(:, 11), {'Low', 'Medium', 'High'}, [0, 1, 2]);
    resultados_reais.operating_mode = inverseOrder(matriz_denorm(:, 12), {'Idle', 'Normal', 'Overload'}, [0, 1, 2]);
    resultados_reais.cooling_type = inverseOrder(matriz_denorm(:, 13), {'Air', 'Oil'}, [0, 1]);
    resultados_reais.sensor_status = inverseOrder(matriz_denorm(:, 14), {'OK', 'Warning'}, [0, 1]);
    
    resultados_reais.class_cat = resultados_norm.class_cat;
    resultados_reais.Similarity = similarities';
    resultados_reais.RowIndex = indices';
    
    disp(resultados_reais);

    classe_diagnosticada = case_library_norm.class_cat(indices(1));
    fprintf('\nDIAGNÓSTICO SUGERIDO: %s\n', char(classe_diagnosticada));
end

% Extrair limites específicos da Temperatura (Coluna 1)
min_temp = global_mins(1); 
max_temp = global_maxs(1);

% REUSE
fprintf('\nREUSE\n');
nova_temp_norm = reuse(case_library_norm, novo_caso, min_temp, max_temp);

% REVISE
fprintf('\nREVISE \n');
caso_revisto = revise(novo_caso, nova_temp_norm, min_temp, max_temp);

% RETAIN 
fprintf('\nRETAIN\n');
[case_library_norm, case_library_bruto] = retain(case_library_norm, case_library_bruto, caso_revisto, classe_diagnosticada, global_mins, global_maxs);

fprintf('\nCiclo CBR terminado.\n');

% Converte valores numéricos arredondados para as suas etiquetas de texto originais (ex: 0 -> 'Low').
function textCol = inverseOrder(numericCol, labels, values)
    textCol = repmat("", size(numericCol, 1), 1);
    numericCol = round(numericCol);
    for i = 1:length(values)
        idx = (numericCol == values(i));
        textCol(idx) = labels{i};
    end
end