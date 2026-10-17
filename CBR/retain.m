function [lib_norm_up, lib_bruta_up] = retain(lib_norm, lib_bruta, caso_revisto, classe_prevista, global_mins, global_maxs)
    lib_norm_up = lib_norm;
    lib_bruta_up = lib_bruta;
    
    fprintf('\n--- Retain ---\n');
    opcao = input('Acha que o diagnóstico foi útil? Deseja adicionar o caso à Base? (s/n): ', 's');
    
    if lower(opcao) == 's'
        if istable(caso_revisto)

            dados_num = table2array(caso_revisto(1, 1:14));
            num_nans = sum(isnan(dados_num));

            if num_nans > 2
                fprintf(' > Erro: Caso com demasiados valores vazios ( %d sensores ). Não será gravado.\n', num_nans);
            else
                if num_nans > 0
                    % Preenche o que falta com a mediana, para não guardar NaNs
                    medias_lib = median(table2array(lib_norm(:, 1:14)), 'omitnan');
                    indices_vazios = isnan(dados_num);
                    dados_num(indices_vazios) = medias_lib(indices_vazios);
                    caso_revisto{1, 1:14} = dados_num;
                    fprintf(' > Nota: %d sensores preenchidos com medianas antes de salvar.\n', num_nans);
                end

                caso_revisto.class_cat = classe_prevista;
                
                try
                    % 1. Preparar linha Normalizada
                    caso_norm = caso_revisto(:, lib_norm.Properties.VariableNames);
                    
                    % 2. Preparar linha Bruta (Desnormalizar)
                    array_norm = table2array(caso_norm(:, 1:14));
                    array_bruto = (array_norm .* (global_maxs - global_mins)) + global_mins;
                    
                    caso_bruto = caso_norm; % Herda a estrutura e a coluna target
                    caso_bruto{1, 1:14} = array_bruto; % Injeta os valores físicos originais
                    
                    % 3. Atualizar memórias
                    lib_norm_up = [lib_norm; caso_norm];
                    lib_bruta_up = [lib_bruta; caso_bruto];
                    
                    % 4. Escrever nos dois ficheiros
                    writetable(lib_norm_up, '../dataset_final_3_1_normalizado.csv');
                    writetable(lib_bruta_up, '../dataset_final_3_1_BRUTO.csv');
                    
                    fprintf(' > Sucesso: O sistema aprendeu e atualizou AMBOS datasets!\n');
                catch ME
                    fprintf(' > Erro crítico ao fundir tabelas.\n');
                    disp(ME.message);
                end
            end
        end
    else
        fprintf(' > O caso foi descartado.\n');
    end
end