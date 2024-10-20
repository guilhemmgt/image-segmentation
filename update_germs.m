function [new_germs, E] = update_germs(germs, labels)
    % Actualisation de la position des germes
    new_germs = zeros(size(germs, 1), size(germs, 2));
    for k = 1:length(germs)
        [px_x, px_y] = find(labels == k);
        new_germs(k, :) = [mean(px_x), mean(px_y)];
    end
     
    % Calcul de l'énergie
    E = 0;
    for k = 1:length(germs)
        E = E + ( (new_germs(k,1) - germs(k,1))^2 + (new_germs(k,2) - germs(k,2))^2 );
    end
    E = E / length(germs);
end

