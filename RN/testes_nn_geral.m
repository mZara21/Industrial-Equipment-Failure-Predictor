clear; clc;
caminho_deste_script = fileparts(which(mfilename));
cd(caminho_deste_script);
addpath('../tratamento');

configs = {
    % Topologia
    '[5]',        'trainlm',  'purelin', [0.70 0.15 0.15];
    '[2]',        'trainlm',  'purelin', [0.70 0.15 0.15];
    '[50]',       'trainlm',  'purelin', [0.70 0.15 0.15];
    '[10 10 10]', 'trainlm',  'purelin', [0.70 0.15 0.15];
    '[20 10 5]',  'trainlm',  'purelin', [0.70 0.15 0.15];

    % Algoritmos de Treino
    '[5]',        'trainbfg',  'purelin', [0.70 0.15 0.15];
    '[5]',        'trainbr',  'purelin', [0.70 0.15 0.15];
    '[5]',        'traingd',  'purelin', [0.70 0.15 0.15];
    '[5]',        'traingdx', 'purelin', [0.70 0.15 0.15];
    '[5]',        'trainrp',  'purelin', [0.70 0.15 0.15];
    '[5]',        'trainoss', 'purelin', [0.70 0.15 0.15];

    % Ativação na Saída
    '[5]',        'trainlm',  'hardlim', [0.70 0.15 0.15];
    '[5]',        'trainlm',  'satlin',  [0.70 0.15 0.15];
    '[5]',        'trainlm',  'poslin',  [0.70 0.15 0.15];
    '[5]',        'trainlm',  'radbas',  [0.70 0.15 0.15];
    '[5]',        'trainlm',  'netinv',  [0.70 0.15 0.15];

    % Divisao
    '[5]',        'trainlm',  'purelin', [0.05 0.45 0.50];
    '[5]',        'trainlm',  'purelin', [0.90 0.05 0.05];
    '[5]',        'trainlm',  'purelin', [0.70 0.15 0.15];
};


fprintf('ID\tTopologia\tTreino\tAtivacao\tDivisao\tMédia_Global\tMédia_Teste\tJustificacao\n');

for c = 1:size(configs, 1)
    topo_str = configs{c, 1};
    f_treino = configs{c, 2};
    f_ativ   = configs{c, 3};
    divs     = configs{c, 4};

    
    [m_glob, m_test] = treina_rede_nn('../dataset_final_3_1_normalizado.csv',topo_str, 50, f_treino, f_ativ, divs(1), divs(2), divs(3));

    div_str = sprintf('%d/%d/%d', divs(1)*100, divs(2)*100, divs(3)*100);
    fprintf('%d\t%s\t%s\t%s\t%s\t%.4f\t%.4f\n', c, topo_str, f_treino, f_ativ, div_str, m_glob, m_test);
end