clear all; clc;
caminho_deste_script = fileparts(which(mfilename));
cd(caminho_deste_script);
addpath('../tratamento');

% 3 melhores e 3 piores
configs = {
    '[10 5 3]', 'trainlm', 'purelin', [0.7 0.15 0.15]; % 1 Melhor
    '[5]',       'trainbr', 'purelin', [0.7 0.15 0.15]; % 2 Melhor
    '[50]',      'trainlm', 'purelin', [0.7 0.15 0.15]; % 3 Melhor
    '[5]',       'traingd', 'purelin', [0.7 0.15 0.15]; % 1 Pior
    '[5]',       'trainlm', 'hardlim', [0.7 0.15 0.15]; % 2 Pior
    '[5]',       'trainlm', 'netinv',  [0.7 0.15 0.15]; % 3 Pior
};

datasets = {'../dataset_final_3_1_normalizado.csv', '../dataset_final_3_1_BRUTO.csv'};
% dir *.csv

for d = 1:2
    current_file = datasets{d};
    fprintf('\n\n--- A TESTAR DATASET: %s ---\n', current_file);
    fprintf('ID\tTopologia\tTreino\tAtivacao\tDivisao\tAccGlobal\tAccTeste\n');
    
    for c = 1:size(configs, 1)
        topo_str = configs{c, 1};
        f_treino = configs{c, 2};
        f_ativ   = configs{c, 3};
        divs     = configs{c, 4};
        
        [m_glob, m_test] = treina_rede_nn(current_file, topo_str, 50, f_treino, f_ativ, divs(1), divs(2), divs(3));
    
        div_str = sprintf('%d/%d/%d', divs(1)*100, divs(2)*100, divs(3)*100);
        fprintf('%d\t%s\t%s\t%s\t%s\t%.4f\t%.4f\n', c, topo_str, f_treino, f_ativ, div_str, m_glob, m_test);

    end
end