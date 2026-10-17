function [cleanX,Y] = converterPreencher(data)
    % Conversão de 'maintenance_level' (Low=1, Medium=2, High=3) 
    data.maintenance_level = totalOrder(data.maintenance_level, {'Low', 'Medium', 'High'}, [0, 1, 2]);

    % Conversão de 'operating_mode' (Idle=0, Normal=1, Overload=2)
    data.operating_mode = totalOrder(data.operating_mode, {'Idle', 'Normal', 'Overload'}, [0, 1, 2]);
    
    % Conversão de 'cooling_type' (Air=0, Oil=1) 
    data.cooling_type = totalOrder(data.cooling_type, {'Air', 'Oil'}, [0, 1]);
    
    % Conversão de 'sensor_status' (OK=0, Warning=1) 
    data.sensor_status = totalOrder(data.sensor_status, {'OK', 'Warning'}, [0, 1]);
    
    Y = data.class_cat;
    X = removevars(data, 'class_cat'); 
    

    % Extrair os dados para uma matriz
    matrizX = table2array(X);
    
    % Calcular a mediana de cada coluna ignorando os NaNs 
    medias_colunas = median(matrizX, 'omitnan');
    
    % Preencher os buracos
    matrizX_limpa = fillmissing(matrizX, 'constant', medias_colunas);
    
    % Devolver como tabela para manter os nomes das colunas
    cleanX = array2table(matrizX_limpa, 'VariableNames', X.Properties.VariableNames);
end

function numericCol = totalOrder(column, labels, values)
    % Converter para string caso venha como cell ou categorical para evitar erros no strcmp
    column = string(column); 
    numericCol = zeros(size(column, 1), 1);
    for i = 1:length(labels)
        idx = strcmpi(column, labels{i});
        numericCol(idx) = values(i);
    end
end


