function [] = plot_superpixels(germs, labels, image, alpha)
    % Taille de l'image
    nb_px_x = size(image, 1);
    nb_px_y = size(image, 2);

    % Couleur d'un superpixel = couleur du pixel le + proche du germe
    germs_color = zeros (length(germs), 3);
    for k = 1:length(germs)
        germs_color (k, :) = image (round(germs(k, 1)), round(germs(k, 2)), :);
    end
    % ou: couluers aléatoires
    germs_color = zeros (length(germs), 3);
    germs_color(:, 1) = uint8(rand(length(germs), 1) * 100); % L
    germs_color(:, 2) = uint8(rand(length(germs), 1) * 255 - 128); % a
    germs_color(:, 3) = uint8(rand(length(germs), 1) * 255 - 128); % b


    % Couleur d'un pixel = couleur du superpixel auquel il appartient
    px_colored = zeros (nb_px_x, nb_px_y, 3);
    for x = 1:nb_px_x
        for y = 1:nb_px_y
            px_colored(x, y, :) = germs_color(labels(x,y), :);
        end
    end

    % Superpixels en transparence sur l'image originale
    imshow(alpha * lab2rgb(px_colored) + (1-alpha) * lab2rgb(image));
    % Germes
    scatter(germs(:, 2), germs(:, 1), 'r+', 'LineWidth', 2);

    % Affichage immédiat
    drawnow nocallbacks;
end

