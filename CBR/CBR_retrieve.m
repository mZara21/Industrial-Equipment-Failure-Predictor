function [retrieved_indexes, similarities] = CBR_retrieve(case_library, new_case, threshold, weights)
    if nargin < 4
        weights = [2.5, 3.0, 1.0, 2.2, 2.8, 1.2, 1.5, 1.2, 1.0, 2.0, 0.8, 0.5, 0.5, 0.5];
    end
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
    
    retrieved_indexes = [];
    similarities = [];
    
    for i = 1:size(lib, 1)
        sum_weights = 0;
        distances = zeros(1, 14);
        
       % Atributos Quantitativos e Ordinais (1 a 12) - Distancia Linear
        for col = 1:12
            if isnan(new(1,col))
                distances(col) = 0; % Fica 0 para anular no numerador
            else
                % =======================================================================================
                % PORQUÊ DISTÂNCIA LOCAL LINEAR ABSOLUTA E NÃO EUCLIDIANA?
                %
                % 2. PRESERVAÇÃO DA EXPLICABILIDADE E PROPORÇÃO DOS PESOS (W_i):
                %    A nossa fórmula de Similaridade Global segue uma Média Ponderada Linear. Isto garante
                %    transparência absoluta para o Especialista Humano: se ele definir que o peso da Vibração
                %    é 2.0 e o da Temperatura é 1.0, a Vibração retirará exatamente o dobro dos pontos na 
                %    similaridade final. Se usássemos a Euclidiana, a raiz quadrada global iria "engolir" os pesos,
                %    destruindo esta proporção direta e tornando a afinação manual não-linear e imprevisível.
                distances(col) = abs(lib(i, col) - new(1, col));
                sum_weights = sum_weights + weights(col); % Soma o peso (Denominador)
            end
        end
        
        % Atributos Nominais / Binários (13 a 14) - Distancia Binaria
        for col = 13:14 
            if isnan(new(1,col))
                distances(col) = 0;
            else
                if lib(i, col) == new(1, col)
                    distances(col) = 0;
                else
                    distances(col) = 1;
                end
                sum_weights = sum_weights + weights(col);
            end
        end
        
        % Só calcula se houver pelo menos 1 sensor a funcionar
        if sum_weights > 0
            %Quando multiplicas uma linha por uma coluna no MATLAB, ele faz o Produto Escalar (Dot Product). 
            % Ou seja, ele faz isto automaticamente: distancia1 * peso1 ...
            final_similarity = 1 - (distances * weights') / sum_weights;
            
            % Atualização do melhor caso encontrado
            if final_similarity >= threshold 
                retrieved_indexes = [retrieved_indexes, i];
                similarities = [similarities, final_similarity];
            end
        end
    end
    
    % Ordenar do mais parecido para o menos parecido
    [similarities, order] = sort(similarities, 'descend'); %Cria o vetor (order) que te diz para onde as coisas foram movidas
    retrieved_indexes = retrieved_indexes(order);
end