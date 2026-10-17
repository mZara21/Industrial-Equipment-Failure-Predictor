function [cleanX, Y] = converterTeste(data)
    % Conversão de categóricos para números (0, 1, 2)
    data.maintenance_level = totalOrder(data.maintenance_level, {'Low', 'Medium', 'High'}, [0, 1, 2]);
    data.operating_mode = totalOrder(data.operating_mode, {'Idle', 'Normal', 'Overload'}, [0, 1, 2]);
    data.cooling_type = totalOrder(data.cooling_type, {'Air', 'Oil'}, [0, 1]);
    data.sensor_status = totalOrder(data.sensor_status, {'OK', 'Warning'}, [0, 1]);
    
    Y = data.class_cat;
    cleanX = removevars(data, 'class_cat'); 
    
    % Deixamos os NaNs para testar.
end

function numCol = totalOrder(catCol, labels, values)
    numCol = NaN(size(catCol));
    for i = 1:length(labels)
        idx = strcmpi(string(catCol), labels{i});
        numCol(idx) = values(i);
    end
end