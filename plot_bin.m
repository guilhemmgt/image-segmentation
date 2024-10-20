function [] = plot_bin(bin_segmentation)

    bin_image = bin_segmentation * 255;
    imshow (bin_image);

end

