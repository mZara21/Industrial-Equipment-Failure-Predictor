function [media_global, media_teste] = redeneuronal(inputs, targets, epochs, topologia, f_treino, f_saida, divisao)
    % Vetores para acumular as 10 repetições
    acc_global_vec = zeros(1, 10);
    acc_teste_vec = zeros(1, 10);
    
    for r = 1:10 
        % topologia
        net = feedforwardnet(topologia);
        
        % funcao de treino
        net.trainFcn = f_treino;
        
        % funcao de ativacao na saida
        net.layers{end}.transferFcn = f_saida;
        
        % divisão do dataset
        net.divideParam.trainRatio = divisao(1);
        net.divideParam.valRatio = divisao(2);
        net.divideParam.testRatio = divisao(3);
        
        net.trainParam.epochs = epochs;
        net.trainParam.showWindow = false; % Ocultar janelas para ser mais rápido
        
        [net, tr] = train(net, inputs, targets);
        
        out = sim(net, inputs);
        
        % Calcular precisao
        [~, class_out] = max(out);
        [~, class_target] = max(targets);
        %Se o número mais alto estiver na linha 1 (ex: [0.9; 0.1; 0.0]), o class_out passa a valer 1 (Normal).
        %Se estiver na linha 3 (ex: [0.0; 0.2; 0.8]), passa a valer 3 (Falha Elétrica).
        
        % Guardar precisao global da repetição r
        acc_global_vec(r) = sum(class_out == class_target) / length(class_target);
        
        idx_teste = tr.testInd;
        acc_teste_vec(r) = sum(class_out(idx_teste) == class_target(idx_teste)) / length(idx_teste);
    end
    
    % médias das 10 repeticões
    media_global = mean(acc_global_vec);
    media_teste = mean(acc_teste_vec);
end