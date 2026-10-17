clear; clc;
addpath('../tratamento'); 
fprintf('AVALIAÇÃO ESTATÍSTICA DO CBR\n\n');

case_library_norm = readtable('../dataset_final_3_1_normalizado.csv');
case_library_bruto = readtable('../dataset_final_3_1_BRUTO.csv');

% Separar as classes reais e apagar a coluna 15
lib_classes_norm = case_library_norm.class_cat;
lib_classes_bruto = case_library_bruto.class_cat;
case_library_norm(:, 15) = [];
case_library_bruto(:, 15) = [];

% mins/maxs globais da BRUTA para a normalização do teste
matriz_bruta = table2array(case_library_bruto(:, 1:14));
global_mins = min(matriz_bruta);
global_maxs = max(matriz_bruta);


test_data = readtable('../dataset_TP_test.csv');
[test_clean, ~] = converterTeste(test_data); 
classes_reais_teste = test_data.class_cat;

test_matriz_bruta = table2array(test_clean); 
test_matriz_norm = (test_matriz_bruta - global_mins) ./ (global_maxs - global_mins + eps);


% Configurações para o Teste
pesos_unitarios = ones(1, 14); 
pesos_especialista = [2.5, 3.0, 1.0, 2.2, 2.8, 1.2, 1.5, 1.2, 1.0, 2.0, 0.8, 0.5, 0.5, 0.5];
pesos_prejudicados = [0.001, 0.001, 0.001, 50, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 1000, 1000];

threshold = 0.0; % Queremos sempre o vizinho mais próximo
total_testes = height(test_data);

% Contadores
acertos_norm_unitarios = 0;
acertos_norm_especialista = 0;
acertos_norm_prejudicados = 0;
acertos_bruto_especialista = 0;

fprintf('A correr o Retrieve para os %d casos de teste em 4 configurações.\n', total_testes);

for i = 1:total_testes
    classe_verdadeira = char(classes_reais_teste(i));
    
    % Normalizado + Pesos a 1 
    [idx_1, ~] = CBR_retrieve(case_library_norm, test_matriz_norm(i, :), threshold, pesos_unitarios);
    if ~isempty(idx_1) && strcmp(strtrim(char(lib_classes_norm(idx_1(1)))), strtrim(classe_verdadeira))
        acertos_norm_unitarios = acertos_norm_unitarios + 1;
    end
    
    % Normalizado + Pesos Especialista
    [idx_2, ~] = CBR_retrieve(case_library_norm, test_matriz_norm(i, :), threshold, pesos_especialista);
    if ~isempty(idx_2) && strcmp(strtrim(char(lib_classes_norm(idx_2(1)))), strtrim(classe_verdadeira))
        acertos_norm_especialista = acertos_norm_especialista + 1;
    end
    
    % Normalizado + Pesos Prejudicados
    [idx_3, ~] = CBR_retrieve(case_library_norm, test_matriz_norm(i, :), threshold, pesos_prejudicados);
    if ~isempty(idx_3) && strcmp(strtrim(char(lib_classes_norm(idx_3(1)))), strtrim(classe_verdadeira))
        acertos_norm_prejudicados = acertos_norm_prejudicados + 1;
    end
    
    % Bruto + Pesos Especialista
    [idx_4, ~] = CBR_retrieve(case_library_bruto, test_matriz_bruta(i, :), threshold, pesos_especialista);
    if ~isempty(idx_4) && strcmp(strtrim(char(lib_classes_bruto(idx_4(1)))), strtrim(classe_verdadeira))
        acertos_bruto_especialista = acertos_bruto_especialista + 1;
    end
end

% resultados finais
fprintf('\nRESULTADOS FINAIS\n');
fprintf('Casos de Teste Avaliados: %d\n\n', total_testes);
fprintf('Analise de Pesos\n');
fprintf('1. Normalizado + Pesos Unitarios:    %.2f%% (%d acertos)\n', (acertos_norm_unitarios / total_testes) * 100, acertos_norm_unitarios);
fprintf('2. Normalizado + Pesos Especialista: %.2f%% (%d acertos)\n', (acertos_norm_especialista / total_testes) * 100, acertos_norm_especialista);
fprintf('3. Normalizado + Pesos Prejudicados:    %.2f%% (%d acertos)\n\n', (acertos_norm_prejudicados / total_testes) * 100, acertos_norm_prejudicados);

fprintf('Analise Normalizado vs Bruto\n');
fprintf('2. Dataset Normalizado (Especialista): %.2f%% (%d acertos)\n', (acertos_norm_especialista / total_testes) * 100, acertos_norm_especialista);
fprintf('4. Dataset Bruto (Especialista):       %.2f%% (%d acertos)\n', (acertos_bruto_especialista / total_testes) * 100, acertos_bruto_especialista);