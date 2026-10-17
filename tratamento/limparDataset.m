function dataset_final = limparDataset()

pasta_tratamento = fileparts(which(mfilename));
cd(pasta_tratamento);
caminho_csv = fullfile(pasta_tratamento, '..', 'dataset_TP.csv');


data = readtable(caminho_csv);

% Converter categóricos e preencher NaNs dos inputs (X)
[cleanX, Y] = converterPreencher(data); 

% Normalizar dados e separar quem tem target de quem não tem
[X_final, X_com_target, Y_conhecido, X_sem_target, indices_para_preencher, mins, maxs] = normalizarIdentificar(cleanX, data);

% Preencheer com Retrieve 
target_atualizado = data.class_cat;

fprintf('A iniciar o Retrieve para %d casos em falta...\n', length(indices_para_preencher));

for i = 1:length(indices_para_preencher)
    % Identificar o caso atual que está sem target (já normalizado)
    caso_vazio = X_sem_target(i, :);
    
    [best_idx, sim] = TR_retrieve(X_com_target, caso_vazio);
    
    idx_original = indices_para_preencher(i);
    target_atualizado(idx_original) = Y_conhecido(best_idx);

end

dataset_final = X_final; 
dataset_final.class_cat = target_atualizado;

writetable(dataset_final, '../dataset_final_3_1_normalizado.csv');



dataset_bruto = cleanX; 
% Colamos-lhe a mesma coluna de target já preenchida
dataset_bruto.class_cat = target_atualizado; 
writetable(dataset_bruto, '../dataset_final_3_1_BRUTO.csv');

end