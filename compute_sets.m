% compute sets of background and foreground seeds

function [bgrnd, fmask] = compute_sets(im_size)
   %computing background masks using linear indexing
   bmask1 = 1:im_size(2); %first column for linear indexing
   bmask2 = (2:im_size(1)-1) * im_size(2); %bottom edge
   bmask3 = (1:im_size(1)-1) * im_size(2) + 1;
   bmask4 = ((im_size(1)-1) * im_size(2) + 2) : ((im_size(1)*im_size(2))-1);
   bgrnd{1} = [bmask1 bmask2 bmask3]; %all but bottom
   bgrnd{2} = [bmask1 bmask2 bmask3 bmask4]; %all
   bgrnd{3} = [bmask1 bmask3]; %only vertical
   bgrnd{4} = [bmask2 bmask4]; %only horizontal
   %all the edges
   %bgrnd = [bmask1 bmask2 bmask3 bmask4];
   % computing foreground masks in a 8-neighbourhood
   row = floor(im_size(1)/5);
   col = floor(im_size(2)/5);
   rows = (1:5) * row;
   cols = (1:5) * col;
   rows = round(rows - row/2);
   cols = round(cols - col/2);
   [x,y] = meshgrid(rows,cols);
   mask = [x(:) y(:)];
   %iterate thru the grid setting the foreground seeds
   fmask = cell(1,size(mask,1));
   for i = 1:size(mask,1)
       row = mask(i,1);
       col = mask(i,2);
       rows = [row-3 row-2 row-1 row row+1 row+2 row+3];
       cols = [col-3 col-2 col-1 col col+1 col+2 col+3];
       [x,y] = meshgrid(rows,cols);
       fmask{i} = sub2ind([im_size(1) im_size(2)], x(:), y(:)); %add the index to the set
   end
   
end
