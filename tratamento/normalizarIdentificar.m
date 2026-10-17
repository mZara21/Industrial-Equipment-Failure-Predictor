function [X_final, X_com_target, Y_conhecido, X_sem_target, indices_para_preencher, mins, maxs] = normalizarIdentificar(cleanX, data)
    X_matriz = table2array(cleanX);

    % Normalização Min-Max 
    % Adicionamos o eps para evitar divisões por zero caso o max seja igual ao min
    mins = min(X_matriz);
    maxs = max(X_matriz);
    X_norm = (X_matriz - mins) ./ (maxs - mins + eps);

    % Transformar de volta em tabela
    X_final = array2table(X_norm, 'VariableNames', cleanX.Properties.VariableNames);

    % Identificar as linhas onde o Target (class_cat) está vazio
    isMissingTarget = ismissing(data.class_cat);

    % Casos com Target conhecido
    X_com_target = X_norm(~isMissingTarget, :);
    Y_conhecido = data.class_cat(~isMissingTarget);

    % Casos SEM Target
    X_sem_target = X_norm(isMissingTarget, :);
    indices_para_preencher = find(isMissingTarget);
    
    fprintf('Identificados %d casos com target e %d casos em falta.\n', ...
        size(X_com_target, 1), size(X_sem_target, 1));
end