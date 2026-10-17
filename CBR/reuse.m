function [nova_temp, novo_caso_seguro] = reuse(case_library, new_case, min_temp, max_temp)
    
    if istable(new_case)
        array_novo = table2array(new_case(1, 1:14));
    else
        array_novo = new_case(1:14);
    end

    % Preencher com mediana
    buracos = isnan(array_novo);
    if any(buracos)
        fprintf('AVISO Reuse: Valores nao preenchidos. Vao ser preenchidos com a Mediana da base de casos...\n');
        medianas = median(table2array(case_library(:, 1:14)), 'omitnan');
        array_novo(buracos) = medianas(buracos); 
    end

    novo_caso_seguro = new_case;
    if istable(novo_caso_seguro)
        novo_caso_seguro{1, 1:14} = array_novo; 
    else
        novo_caso_seguro(1:14) = array_novo;
    end

    % Extrair Inputs para a Rede Neuronal (Vib=2, Rot=3, Volt=4)
    inputs_novo = array_novo([2, 3, 4])'; % transposta formato exigido pela toolbox de Deep Learning do MATLAB
    temp_atual_norm = array_novo(1);


    nome_rede = 'net_reuse_temperatura.mat';
    if ~isfile(nome_rede)
        fprintf('A treinar rede feedforward para o Reuse...\n');
        X = table2array(case_library(:, [2, 3, 4]))'; % Inputs
        Y = table2array(case_library(:, 1))';         % Target
        net = feedforwardnet();
        net.trainParam.showWindow = false; 
        net = train(net, X, Y);
        save(nome_rede, 'net');
    else
        load(nome_rede, 'net');
    end

    nova_temp = net(inputs_novo);
    
    % Desnormalizar 
    temp_atual_real = (temp_atual_norm * (max_temp - min_temp)) + min_temp;
    nova_temp_real = (nova_temp * (max_temp - min_temp)) + min_temp;
    
    fprintf('\n--- Reuse ---\n');
    fprintf('Com base na Vibração, Rotação e Voltagem dos casos conhecidos,\n');
    fprintf('a Rede Neuronal estimou a Temperatura em %.2f °C (Lido no sensor: %.2f °C).\n', nova_temp_real, temp_atual_real);
end