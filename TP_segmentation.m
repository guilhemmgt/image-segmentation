clear;
close all;
% Nombre d'images utilisees
nb_images = 36; 

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A COMPLETER                                             %
% Calculs des superpixels                                 % 
% Conseil : afficher les germes + les régions             %
% à chaque étape / à chaque itération                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ........................................................%

% Variables
num = 1;
K = 100;
Seuil = 10;
m = 10;

% Correction de K
K = ceil(sqrt(K))^2;

% Choix de l'image
image = im(:,:,:,num);

sizeY = size(image, 1);
sizeX = size(image, 2);
N =  sizeX * sizeY;
S = sqrt(N/K); % dimension d'un côté d'une région à l'itération 0

grille_superpixels_x = floor (sizeX / S);
grille_superpixels_y = floor (sizeY / S);

% Placement des germes
posX = zeros(grille_superpixels_x, grille_superpixels_y);
posY = zeros(grille_superpixels_x, grille_superpixels_y);

for i = 0:grille_superpixels_x-1
    for j = 0:grille_superpixels_y-1
        posX(i+1,j+1) = S/2 + S*i;
        posY(i+1,j+1) = S/2 + S*j;
    end
end

% Recentrage des germes

% Selon Y
distToTop = posY(1,1);
distToBottom = sizeY - posY(grille_superpixels_x, grille_superpixels_y);
offsetY = (distToBottom + distToTop)/2 - distToTop;
posY = posY + offsetY;

% Selon X
distToLeft = posX(1,1);
distToRight = sizeX - posX(grille_superpixels_x, grille_superpixels_y);
offsetX = (distToRight + distToLeft)/2 - distToLeft;
posX = posX + offsetX;

posY = round (posY);
posX = round (posX);


imshow(im(:,:,:,num)); title('Image');

hold on;

scatter(posX, posY, 'r+', 'LineWidth', 2);

% A enlever pour faire la suite
% return

%% Deuxième partie

nb_iter_max = 1;
nb_current_iter = 0;

% Algorithme itératif
while 1

    % Calcul des superpixels
    etiquette = zeros(sizeX,sizeY,2);

    % On boucle sur chaque pixel
    for px_x = 1:sizeX
        for px_y = 1:sizeY

            % Recherche du meilleur germe pour chaque pixel
            min_d = realmax;

            % On boucle sur chaque germe
            for germe_i = 1:grille_superpixels_x
                for germe_j = 1:grille_superpixels_y
                    % Distance du pixel au centre
                    dx = abs(px_x - posX(germe_i, germe_j));
                    dy = abs(px_y - posY(germe_i, germe_j));
                    % 
                    % if ((dx > S || dy > S) && min_d ~= realmax)
                    %     continue
                    % end
                    if (dx > S || dy > S)
                        continue
                    end
                    dxy = sqrt(dx^2 + dy^2);
                    pixel_RGB = image(px_y, px_x, :);
                    germe_RGB = image(posY(germe_i, germe_j), posX(germe_i, germe_j), :);
                    drgb = sum(pixel_RGB - germe_RGB);

                    D = drgb + (m/S)*dxy;
                    
                    % Condition de nouveau meilleur germe
                    if min_d > D
                        min_d = D;

                        % On choisit id_germe = (x-1) * tailleCarre + y
                        %etiquette(px_x, px_y) = (germe_i-1) * grille_superpixels_y + germe_j;
                        etiquette(px_x, px_y,1) = germe_i;
                        etiquette(px_x, px_y,2) = germe_j;
                    end
                    
                end
            end

       
        end
    end

    % color = uint8(rand(grille_superpixels_x, grille_superpixels_y, 3) * 255);
    color = zeros (grille_superpixels_x, grille_superpixels_y, 3);
    for germe_i = 1:grille_superpixels_x
        for germe_j = 1:grille_superpixels_y
            color (germe_i, germe_j, :) = image (posY(germe_i, germe_j), posX(germe_i, germe_j), :);
        end
    end

    % g_i = floor((etiquette-1)/grille_superpixels_y) + 1;
    % g_j = mod(etiquette,grille_superpixels_y) + 1;
    image_etiquette = zeros (sizeY, sizeX, 3);
    for x = 1:sizeX
        for y = 1:sizeY
           image_etiquette(y, x, :) = color(etiquette(x,y,1), etiquette(x,y,2), :);
        end
    end
    image_etiquette = uint8(image_etiquette);
    

    alpha = 1;
    image_3 = alpha * image_etiquette + (1-alpha) * image;
    imshow(image_3)

    scatter(posX, posY, 'r+', 'LineWidth', 2);

    % Mise à jour des centres (moyennes des attributs)

    % Obj : changer posX et posY

    % pour chaque germe, on récupère les pixels attribués
    positionsPixelsGermes = zeros(sizeX, sizeY, grille_superpixels_x, grille_superpixels_y);

    for germe_i = 1:grille_superpixels_x
        for germe_j = 1:grille_superpixels_y
            %islinkedToCurrentGerm = find(etiquette(:,:,1) == germe_i) .* find(etiquette(:,:,2) == germe_j);
        end
    end


    % maj = zeros (grille_superpixels_x, grille_superpixels_y, 1, 1, 1);    
    % for px_x = 1:sizeX
    %     for px_y = 1:sizeY
    %         gi, gj = etiquette(px_x, px_y, :);
    %         old_x, old_y, old_n = maj (gi, gj, :, :, :);
    %         maj (gi, gj, 1, 1, 1) = maj (gi, gj, old_x + px_x, old_y + px_y, old_n + 1);
    %     end
    % end

    
    % Calcul de E (L1 entre les anciens et nouveaux Ck)
    %if E<Seuil
     %   break
    %end

    if nb_current_iter >= nb_iter_max
        break
    end

    nb_current_iter = nb_current_iter + 1;
    break
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

