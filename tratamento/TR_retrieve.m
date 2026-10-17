function [best_index, max_similarity] = tr_retrieve(case_library, new_case)
    % Temp, Vib, Rot, Volt, Curr, Press, Noise, Eff, Load, Torq, Maint, Mode, Cool, Sens
    weights = [2.5, 3.0, 1.0, 2.2, 2.8, 1.2, 1.5, 1.2, 1.0, 2.0, 0.8, 0.5, 0.5, 0.5];
    
    if istable(case_library)
        lib = table2array(case_library(:, 1:14));
    else
        lib = case_library;
    end
    
    if istable(new_case)
        new = table2array(new_case(1, 1:14));
    else
        new = new_case;
    end

    max_similarity = -1;
    best_index = -1;

    for i = 1:size(lib, 1)
        distances = zeros(1, 14);

        % Atributos Quantitativos (1 a 12) - Distância Linear
         for col = 1:12
            distances(col) = abs(lib(i, col) - new(1, col));
        end

        % Atributos Nominais / Binários (13 a 14) - Distancia Binaria
        for col = 13:14
            if lib(i, col) == new(1, col)
                distances(col) = 0;
            else
                distances(col) = 1;
            end
        end
        
        final_similarity = 1 - ( distances * weights') / sum(weights);
        
        % Atualização do melhor caso encontrado
        if final_similarity > max_similarity 
            max_similarity = final_similarity;
            best_index = i;
        end
    end
end