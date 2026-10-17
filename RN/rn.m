clear; clc;

caminho_script = fileparts(which(mfilename));
cd(caminho_script); 
addpath(fullfile('..', 'tratamento')); 

nome_ficheiro_bruto = '../dataset_final_3_1_BRUTO.csv';
if ~isfile(nome_ficheiro_bruto)
    error('Ficheiro bruto não encontrado. Por favor, execute o limparDataset() primeiro.');
end

case_library_bruto = readtable(nome_ficheiro_bruto);
matriz_bruta = table2array(case_library_bruto(:, 1:14));

global_mins = min(matriz_bruta);
global_maxs = max(matriz_bruta);
medianas_treino = median(matriz_bruta, 'omitnan'); % Para robustez a NaN


fprintf('Selecione a configuração da Rede Neuronal:\n');
fprintf('1. MR1 - Melhor Topologia ([10 5 3])\n');
fprintf('2. MR2 - Melhor Algoritmo de Treino (trainbr)\n');
fprintf('3. MR3 - Melhor Função de Ativação (tansig)\n');

escolha_rede = 0;
while ~ismember(escolha_rede, [1, 2, 3])
    escolha_rede = input('\nEscolha a rede (1-3): ');
end

ficheiros_redes = {'../MR1_topologia.mat', '../MR2_trainbr.mat', '../MR3_tansig.mat'};
ficheiro_mat = ficheiros_redes{escolha_rede};

if isfile(ficheiro_mat)
    data_carregada = load(ficheiro_mat);
    campos = fieldnames(data_carregada);
    net_escolhida = data_carregada.(campos{1});
    fprintf('Ficheiro %s carregado com sucesso.\n', ficheiro_mat);
else
    error('Erro: O ficheiro %s não foi encontrado na pasta RN.', ficheiro_mat);
end

nome_ficheiro_teste = '../dataset_TP_test.csv';
if ~isfile(nome_ficheiro_teste)
    error('Ficheiro de teste (dataset_TP_test.csv) não encontrado!');
end

% Ler com proteção para nomes de colunas
test_data = readtable(nome_ficheiro_teste, 'VariableNamingRule', 'preserve');
[test_clean, ~] = converterTeste(test_data); 
test_matriz = table2array(test_clean);


total_testes = height(test_data);
idx_teste = -1;
while isempty(idx_teste) || idx_teste < 1 || idx_teste > total_testes
    idx_teste = input(sprintf('\nEscolha o índice do caso de teste (1 a %d): ', total_testes));
end

% Extrair linha bruta
caso_escolhido = test_matriz(idx_teste, :);

buracos = isnan(caso_escolhido);
if any(buracos)
    fprintf('AVISO: Sensores [%s] com valores em falta!\n', num2str(find(buracos)));
    fprintf('A aplicar Mediana da base de treino para permitir o diagnóstico...\n');
    caso_escolhido(buracos) = medianas_treino(buracos); 
end

% Normalização
input_norm = (caso_escolhido - global_mins) ./ (global_maxs - global_mins + eps);
input_norm = input_norm'; % Transposta

% Target desconhecido ou nao
if ismember('class_cat', test_data.Properties.VariableNames) && ~ismissing(test_data.class_cat(idx_teste))
    classe_real = char(test_data.class_cat(idx_teste));
    tem_target = true;
else
    classe_real = 'DESCONHECIDA';
    tem_target = false;
end


% executar rede e resultados
out = sim(net_escolhida, input_norm);
[~, idx] = max(out);

% Mapeamento de classes 
categorias = {'ElectricalFailure', 'MechanicalFailure', 'Normal'}; 
classe_prevista = categorias{idx};

fprintf('             RELATÓRIO DE DIAGNÓSTICO             \n');
fprintf('--------------------------------------------------\n');
fprintf('Rede:           %s\n', ficheiro_mat);
fprintf('Índice Teste:   %d\n', idx_teste);
fprintf('--------------------------------------------------\n');
fprintf('Classe Real:    %s\n', classe_real);
fprintf('Previsão:      %s\n', classe_prevista);

if tem_target
    if strcmp(strtrim(classe_real), strtrim(classe_prevista))
        fprintf('Resultado:      CORRETO\n');
    else
        fprintf('Resultado:      INCORRETO\n');
    end
end