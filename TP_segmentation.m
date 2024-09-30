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
K = 10;
Seuil = 10;
m = 10;

% Correction de K
K = ceil(sqrt(K))^2;
tailleCarre = sqrt(K);

% Choix de l'image
image = im(:,:,:,num);

sizeX = size(image,1);
sizeY = size(image,2);
N =  sizeX * sizeY;
S = sqrt(N/K); % dimension d'un côté d'une région à l'itération 0

% Placement des germes
posX = zeros(tailleCarre, tailleCarre);
posY = zeros(tailleCarre, tailleCarre);

for i = 0:tailleCarre-1
    for j = 0:tailleCarre-1
        posX(i+1,j+1) = S/2 + S*i;
        posY(i+1,j+1) = S/2 + S*j;
    end
end

imshow(im(:,:,:,num)); title('Image');
hold on;
scatter(posX, posY, 'r+', 'LineWidth', 2);


% Algorithme itératif
while 1

    % Calcul des superpixels

    % On boucle sur chaque pixel
    for px_i = 1:sizeX
        for px_j = 1:sizeY

            % Recherche du meilleur germe pour chaque pixel
            min_d = realmax;
            best_germe_i = 0;
            best_germe_j = 0;

            % On boucle sur chaque germe
            for germe_i = 1:tailleCarre
                for germe_j = 1:tailleCarre
                    % Distance du pixel au centre
                    dx = abs(px_i - posX(germe_i,germe_j));
                    dy = abs(px_y - posY(germe_i,germe_j));

                    if (dx > S || dy > S)
                        break
                    end
                    dxy = sqrt(dx^2 + dy^2);
                    pixel_RGB = image(px_i, px_j, :);
                    germe_RGB = image(germe_i, germe_j,:);
                    drgb = sum(pixel_RGB - germe_RGB);

                    D = drbg + (m/S)*dxy;
                    
                    % Condition de nouveau meilleur germe
                    if min_d > D
                        min_d = D;
                        best_germe_i = germe_i;
                        best_germe_j = germe_j;                       
                    end
                    
                end
            end
        end

    end
    
    for px_i = (max(0, posX(i,j)-S)) : (min(sizeX, posX(i,j)+S))
        for px_j = (max(0, posY(i,j)-S)) : (min(sizeY, posY(i,j)+S))
                    
        end
    end

    % Mise à jour des centres (moyennes des attributs)
    
    % Calcul de E (L1 entre les anciens et nouveaux Ck)
    if E<Seuil
        break
    end

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

