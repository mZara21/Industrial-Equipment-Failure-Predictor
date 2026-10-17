clear all; clc;
caminho_deste_script = fileparts(which(mfilename));
cd(caminho_deste_script);
addpath('../tratamento');

if isfile('../dataset_teste_final_normalizado.csv')
    dataset_final = readtable('../dataset_teste_final_normalizado.csv');
else
    error('Erro: Ficheiro dataset_teste_final_normalizado.csv não encontrado.');
end

% Preparar inputs e targets do novo ficheiro
inputs_final = table2array(dataset_final(:, 1:14))';
cats_final = categorical(dataset_final.class_cat);
lista_categorias = categories(cats_final); 
targets_final = zeros(numel(lista_categorias), size(dataset_final, 1));

for i = 1:numel(lista_categorias)
    targets_final(i, :) = (cats_final == lista_categorias{i})';
end



redes_para_testar = {'../MR1_topologia.mat', '../MR2_trainbr.mat', '../MR3_tansig.mat'};
nomes_redes = {'Melhor Rede (10 5 3)', 'Melhor Rede (trainbr)', 'Melhor Rede (tansig)'};

for i = 1:length(redes_para_testar)
    data = load(redes_para_testar{i});
    
    % extrair a rede dinamicamente
    campos = fieldnames(data);
    net_atual = data.(campos{1}); 
    
    out = sim(net_atual, inputs_final);
    
    % Calcular precisão total 
    [~, class_out] = max(out);
    [~, class_target] = max(targets_final); % ao usar os parênteses retos com duas posições [valor, posicao],
    acc = sum(class_out == class_target) / length(class_target);
    
    fprintf('Taxa de Acerto Final - %s: %.2f%%\n', nomes_redes{i}, acc * 100);
    
    % Gerar e guardar o Plot Confusion
    figure('Name', ['Confusão: ' nomes_redes{i}]);
    plotconfusion(targets_final, out, nomes_redes{i});
    
    % Guardar a imagem
    saveas(gcf, ['PlotConfusion_Final_Rede_' num2str(i) '.png']);
end

disp('-----------------------------------------');
disp('Teste concluído. As imagens PNG foram guardadas na pasta.');