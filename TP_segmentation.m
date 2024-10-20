clear;
close all;

nb_images = 36;     % Nombre d'images utilisees

% chargement des images
for i = 1:nb_images
    if i<=10
        nom = sprintf('images/viff.00%d.ppm',i-1);
    else
        nom = sprintf('images/viff.0%d.ppm',i-1);
    end;
    % im est une matrice de dimension 4 qui contient 
    % l'ensemble des images couleur de taille : nb_lignes x nb_colonnes x nb_canaux 
    % im est donc de dimension nb_lignes x nb_colonnes x nb_canaux x nb_images
    im(:,:,:,i) = imread(nom); 
end;

% Affichage d'exemples d'images
figure; 
%subplot(2,2,1); imshow(im(:,:,:,1)); title('Image 1');
%subplot(2,2,2); imshow(im(:,:,:,9)); title('Image 9');
%subplot(2,2,3); imshow(im(:,:,:,17)); title('Image 17');
%subplot(2,2,4); imshow(im(:,:,:,25)); title('Image 25');

%% VARIABLES
K = 100;      % Nb de superpixels
num = 1;      % N° de l'image traitée
Seuil = 10;   % Seuil pour condition d'arrêt
m = 10;       % Poids de la distance géométrique (contre la distance colorimétrique)

%% INITIALISATION

% Image originale
image = rgb2lab(im(:, :, :, num));
nb_px_x = size(image, 2);   % Nb de pixels sur la largeur
nb_px_y = size(image, 1);   % Nb de pixels sur la hauteur
N =  nb_px_x * nb_px_y;     % Nb de pixels

% Superpixels
S = sqrt(N/K);                           % A l'itération 0, un superpixel à une taille S*S
nb_superpixels_x = ceil (nb_px_x / S);   % Nb de superpixels sur la largeur
nb_superpixels_y = ceil (nb_px_y / S);   % Nb de superpixels sur la hauteur

% Placement des germes
germes = zeros (nb_superpixels_x, nb_superpixels_y, 2);
for i = 1:nb_superpixels_x
    for j = 1:nb_superpixels_y
        germes(i, j, 1) = (nb_px_x - S * (nb_superpixels_x-1))/2 + S*(i-1); % x
        germes(i, j, 2) = (nb_px_y - S * (nb_superpixels_y-1))/2 + S*(j-1); % y
    end
end
germes = reshape(germes, [], 2); % Flattening

% Plot
imshow(im(:,:,:,num)); title('Image');
hold on;
scatter(germes(:, 1), germes(:, 2), 'r+', 'LineWidth', 2);

%% ITÉRATIONS

nb_iter_max = 1000;
nb_current_iter = 0;
E = realmax;
etiquettes = zeros(nb_px_y, nb_px_x); % Appartenances pixel/germe

while nb_current_iter < nb_iter_max && E > Seuil
    %% Calcul des superpixels
    for px_x = 1:nb_px_x
        for px_y = 1:nb_px_y
            etiquettes(px_y, px_x) = find_nearest_germ(germes, image, px_x, px_y, S, m);
        end
    end

    %% Plot
    % Couleur d'un superpixel = couleur du pixel le + proche du germe
    color = zeros (length(germes), 3);
    for germe = 1:length(germes)
        color (germe, :) = image (round(germes(germe, 2)), round(germes(germe, 1)), :);
    end
    % color = uint8(rand(length(germes), 3) * 255); % couleurs aléatoires
    % Couleur d'un pixel = couleur du superpixel auquel il appartient
    image_etiquettes = zeros (nb_px_y, nb_px_x, 3);
    for x = 1:nb_px_x
        for y = 1:nb_px_y
            image_etiquettes(y, x, :) = color(etiquettes(y,x), :);
        end
    end
    %image_etiquettes = uint8(image_etiquettes);
    % Superpixels en transparence
    alpha = 1;
    imshow(alpha * lab2rgb(image_etiquettes) + (1-alpha) * lab2rgb(image));
    scatter(germes(:, 1), germes(:, 2), 'r+', 'LineWidth', 2);
    drawnow nocallbacks

    %% Mise à jour des centres (moyennes des attributs)
    new_germes = zeros(size(germes, 1), size(germes, 2));
    for k = 1:length(germes)
        [px_y, px_x] = find(etiquettes == k);
        new_germes(k, :) = [mean(px_x), mean(px_y)];
    end
     
    %% Màj des conditions d'arrêt
    E = norm (new_germes - germes);         % Calcul de E (L1 entre les anciens et nouveaux Ck)
    nb_current_iter = nb_current_iter + 1;  % Nb max d'itérations

    germes = new_germes;

    E
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A COMPLETER                                             %
% Binarisation de l'image à partir des superpixels        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ........................................................%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A DECOMMENTER ET COMPLETER                              %
% quand vous aurez les images segmentées                  %
% Affichage des masques associes                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure;
% subplot(2,2,1); ... ; title('Masque image 1');
% subplot(2,2,2); ... ; title('Masque image 9');
% subplot(2,2,3); ... ; title('Masque image 17');
% subplot(2,2,4); ... ; title('Masque image 25');

