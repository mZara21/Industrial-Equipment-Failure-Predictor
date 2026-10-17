function [m_glob,m_test] = treina_rede_nn(ficheiro,topologia_str, epochs, f_treino, f_saida, r_train, r_val, r_test)
    % Parâmetros:
    % topologia_str: string tipo "[10 10]"
    % f_treino: string tipo 'trainscg'
    % f_saida: string tipo 'softmax'
    % r_train, r_val, r_test: números (ex: 0.7, 0.15, 0.15)

    % 1. Converter a string da topologia para vetor numérico
    topologia = str2num(topologia_str);
    divisao = [r_train, r_val, r_test];

    % 2. Carregar e preparar dados (Sempre igual)
    if isfile(ficheiro)
        dataset = readtable(ficheiro);
    else
        error('Erro: Ficheiro de dados nao encontrado.');
    end

    inputs = table2array(dataset(:, 1:14))';
    %as amostras (motores) têm de estar nas colunas e as variáveis (sensores) nas linhas
    
    % Target Binário manual (estilo que já tinhas)
    cats = categorical(dataset.class_cat);
    lista_categorias = categories(cats); 
    targets = zeros(numel(lista_categorias), size(dataset, 1));
    for i = 1:numel(lista_categorias)
        targets(i, :) = (cats == lista_categorias{i})';
    end

    % 3. Chamar a função que faz as 10 repetições
    % (A função 'redeneuronal' que já tinhas, mas agora apenas uma vez)
    [m_glob, m_test] = redeneuronal(inputs, targets, epochs, topologia, f_treino, f_saida, divisao);

    fprintf('\nRESULTADO_INICIO\n');
    fprintf('Global:%.4f\n', m_glob);
    fprintf('Teste:%.4f\n', m_test);
    fprintf('RESULTADO_FIM\n');
    
end