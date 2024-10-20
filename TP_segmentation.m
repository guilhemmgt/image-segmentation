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
K = 200;      % Nb de superpixels
num = 1;      % N° de l'image traitée
seuil = 10;   % Seuil pour condition d'arrêt
m = 10;       % Poids de la distance géométrique (contre la distance colorimétrique)

%% INITIALISATION

% Image originale
image = rgb2lab(im(:, :, :, num));
nb_px_x = size(image, 1);   % Nb de pixels sur la hauteur
nb_px_y = size(image, 2);   % Nb de pixels sur la largeur
N =  nb_px_x * nb_px_y;     % Nb de pixels

% Superpixels
S = sqrt(N/K);                           % A l'itération 0, un superpixel à une taille S*S
nb_superpixels_x = ceil (nb_px_x / S);   % Nb de superpixels sur la largeur
nb_superpixels_y = ceil (nb_px_y / S);   % Nb de superpixels sur la hauteur

% Placement des germes
% germes = zeros (nb_superpixels_x, nb_superpixels_y, 2);
% for i = 1:nb_superpixels_x
%     for j = 1:nb_superpixels_y
%         % germes(i, j, 1) = (nb_px_x - S * (nb_superpixels_x-1))/2 + S*(i-1); % x
%         % germes(i, j, 2) = (nb_px_y - S * (nb_superpixels_y-1))/2 + S*(j-1); % y
%         germes(i, j, 1) = S*(i-1); % x
%         germes(i, j, 2) = S*(j-1); % y
%     end
% end
germs = zeros (nb_superpixels_x * nb_superpixels_y, 2);
for i = 1:nb_superpixels_x
    for j = 1:nb_superpixels_y
        germs((j-1)*nb_superpixels_x+i, 1) = (nb_px_x - S * (nb_superpixels_x-1))/2 + S*(i-1); % x
        germs((j-1)*nb_superpixels_x+i, 2) = (nb_px_y - S * (nb_superpixels_y-1))/2 + S*(j-1); % y
    end
end
% germes = reshape(germes, [], 2); % Flattening

% Plot
imshow(im(:,:,:,num)); title('Image');
hold on;
scatter(germs(:, 2), germs(:, 1), 'r+', 'LineWidth', 2);

%% ITÉRATIONS

nb_iter_max = 1000;
iter = 0;
E = realmax;
labels = zeros(nb_px_x, nb_px_y); % Appartenances pixel/germe

while iter < nb_iter_max && E > seuil
    % Calcul des superpixels
    for px_x = 1:nb_px_x
        for px_y = 1:nb_px_y
            labels(px_x, px_y) = find_nearest_germ(germs, image, px_x, px_y, S, m);
        end
    end

    % Plot
    plot_superpixels (germs, labels, image, 1);

    % Mise à jour des centres (moyennes des attributs)
    [germs, E] = update_germs (germs, labels);

    % Nb d'itérations
    iter = iter + 1;
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

