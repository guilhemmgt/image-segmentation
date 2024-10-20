function nearest_germ_index = find_nearest_germ(germs, image, px_x, px_y, S, m)
    nearest_germ_index = -1;    % Le germe le + près du pixel (au sens de Ds)
    min_d_s = realmax;          % Ds minimal trouvé

    % Voisinage de taille 2S*2S autour du pixel
    x1 = max(1, px_x - S);
    x2 = min(size(image, 2), px_x + S);
    y1 = max(1, px_y - S);
    y2 = min(size(image, 1), px_y + S);

    % Recherche du + proche germe (au sens de Ds)
    for k = 1:length(germs)
        germ_x = germs(k, 1);
        germ_y = germs(k, 2);

        % Le germe doit être dans le voisinage
        if (not (x1 <= germ_x && germ_x <= x2 && y1 <= germ_y && germ_y <= y2))
            continue
        end

        % Distance géométrique
        d_xy = norm([px_x, px_y] - germs(k, :));
        % Distance colorimétrique
        px_color = reshape(image(px_y, px_x, :), 1, 3);
        germ_color = reshape(image(round(germs(k, 2)), round(germs(k, 1)), :), 1, 3);
        d_color = norm(px_color - germ_color);
        % Distance pondérée
        d_s = d_color + m/S * d_xy;
        
        % Condition de nouveau meilleur germe
        if min_d_s > d_s
            min_d_s = d_s;
            nearest_germ_index = k;
        end
    end

end