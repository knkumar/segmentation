% compute sets of background and foreground seeds

function [bgrnd, fmask] = compute_sets(im_size)
   %computing background masks
   bmask1 = 1:im_size(2);
   bmask2 = (1:im_size(1)-1) * im_size(2);
   bmask3 = (2:im_size(2)-1) * im_size(2);
   %bmask4 = (2:im_size(2)-1) + (im_size(1)-1)* im_size(2);
   %all but the bottom edge
   bgrnd = [bmask1 bmask2 bmask3];
   %all the edges
   %bgrnd = [bmask1 bmask2 bmask3 bmask4];
   % computing foreground masks in a 8-neighbourhood
   row = floor(im_size(1)/5);
   col = floor(im_size(2)/5);
   fmask = [];
   %iterate thru the grid setting the foreground seeds
   row_ind = row/2;
   col_ind = col/2;
   start_col = col_ind;
   for i = 1:4
       for j = 1:4
           ind = im_size(2) * (row_ind-1);
           ind = ind + col_ind; %find the pixel number
           left = ind-1;
           right = ind+1;
           top = ind - im_size(2);
           bottom = ind + im_size(2);
           top_left = top - 1;
           top_right = top + 1;
           bottom_left = bottom - 1;
           bottom_right = bottom + 1;
           fmask = [fmask ind left right top bottom top_left top_right bottom_left bottom_right]; %add the index to the set
           col_ind = col_ind + col;
       end
       col_ind = start_col;
       row_ind = row_ind + row;
   end
   
end
