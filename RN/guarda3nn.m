clear all; clc;


if isfile('dataset_final_3_1_normalizado.csv')
    dataset = readtable('dataset_final_3_1_normalizado.csv');
else
    error('Erro: Ficheiro de dados nao encontrado.');
end

inputs = table2array(dataset(:, 1:14))';

cats = categorical(dataset.class_cat);
lista_categorias = categories(cats); 
targets = zeros(numel(lista_categorias), size(dataset, 1));
for i = 1:numel(lista_categorias)
    targets(i, :) = (cats == lista_categorias{i})';
end

epochs = 50;

disp('A treinar a 1ª melhor rede...');
topo1 = [10 5 3]; f_treino1 = 'trainlm'; f_saida1 = 'purelin'; div = [0.7 0.15 0.15];

[m_glob1, m_test1, net1, tr1] = redeneuronal(inputs, targets, epochs, topo1, f_treino1, f_saida1, div);

save('MR1_topologia.mat', 'net1', 'tr1');
fprintf('Rede 1 guardada! (Acc Teste Média: %.4f)\n', m_test1);


disp('A treinar a 2ª melhor rede...');
topo2 = [5]; f_treino2 = 'trainbr'; f_saida2 = 'purelin';

[m_glob2, m_test2, net2, tr2] = redeneuronal(inputs, targets, epochs, topo2, f_treino2, f_saida2, div);

save('MR2_trainbr.mat', 'net2', 'tr2');
fprintf('Rede 2 guardada! (Acc Teste Média: %.4f)\n', m_test2);

disp('A treinar a 3ª melhor rede...');
topo3 = [5]; f_treino3 = 'trainlm'; f_saida3 = 'tansig';

[m_glob3, m_test3, net3, tr3] = redeneuronal(inputs, targets, epochs, topo3, f_treino3, f_saida3, div);

save('MR3_tansig.mat', 'net3', 'tr3');
fprintf('Rede 3 guardada! (Acc Teste Média: %.4f)\n', m_test3);

disp('-----------------------------------------');
disp('Processo concluído. Tens 3 ficheiros .mat na tua pasta.');