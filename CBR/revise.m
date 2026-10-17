function [caso_revisto] = revise(new_case, nova_temp_norm, min_temp, max_temp)
    caso_revisto = new_case;
    
    % Transformar o valor da rede (normalizado) em valor real para a pergunta
    nova_temp_real = (nova_temp_norm * (max_temp - min_temp)) + min_temp;
    
    fprintf('\n--- Revise ---\n');

    prompt = sprintf('Pretende substituir a temperatura do sensor pelo valor previsto pela RN (%.2f °C)? (s/n): ', nova_temp_real);
    opcao = input(prompt, 's');
    
    if lower(opcao) == 's'
        % INJETA O VALOR NORMALIZADO! Mantém a matemática do dataset coerente.
        if istable(caso_revisto)
            caso_revisto.temperature = nova_temp_norm;
        else
            caso_revisto(1) = nova_temp_norm;
        end
        fprintf('Temperatura atualizada com sucesso!\n');
    else
        fprintf('Temperatura original mantida.\n');
    end
end