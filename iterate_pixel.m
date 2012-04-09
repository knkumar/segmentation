%compute pairwise pixel energies and unary pixel energies

function [graph] = iterate_pixel(im_size, im_data, gpb_thin, bgrnd, fgrnd, lambda)
    graph_size = (im_size(1) * im_size(2)) + 2;
    sdev_gpb = compute_std(gpb_thin);
    graph = spalloc(graph_size,graph_size,10);
    %graph = zeros(graph_size,graph_size);
    %compute unary potentials while pairwise to avoid overlooping ??
    %compute pairwise potentials
    graph = compute_pairwise(graph, im_size, gpb_thin, sdev_gpb, lambda, bgrnd, fgrnd, im_data);
end

function sdev = compute_std(gpb_thin)
    gpb_size = size(gpb_thin);
    gpb_thin = reshape(gpb_thin,1,gpb_size(1)*gpb_size(2));
    sdev = std(gpb_thin);
end

function [graph] = compute_pairwise(graph, im_size, gpb_thin, sdev, lambda, bgrnd, fgrnd, im_data)
    gsize = size(graph);
    source_row = gsize(2) - 1;
    sink_col = gsize(2);
    for i = 1:im_size(1)
        for j = 1:im_size(2)
            %for every pixel compute the weights to every neighbouring pixel
            center = (i-1)*(im_size(1)) + j; %center
            center_value = gpb_thin(i,j);
            graph = compute_unary(bgrnd, fgrnd, graph, center, source_row, sink_col, lambda, permute(im_data, [2 1 3]) );
            [pos values] = make_grid(i,j,gpb_thin,im_size, center);
            if values(1,1) ~= -1
                val = exp(-max(center_value,values(1,1))/ (sdev^2));
                graph(center , pos(1,1)) = val; %center-left
                graph(pos(1,1) , center) = val; %center-left
            end
            if values(1,2) ~= -1
                val = exp(-max(center_value,values(1,2))/ (sdev^2));
                graph(center , pos(1,2)) =  val; %center-top
                graph(pos(1,2) , center) = val; %center-top
            end
            if values(2,1) ~= -1
                val = exp(-max(center_value,values(2,1))/ (sdev^2));
                graph(center , pos(2,1)) = val; %center-bottom
                graph(pos(2,1) , center) = val; %center-bottom
            end
            if values(2,2) ~= -1
                val = exp(max(center_value,values(2,2))/ (sdev^2));
                graph(center , pos(2,2)) = val; %center-right
                graph(pos(2,2) , center) = val; %center-right
            end
        end
    end
end

function [graph] = compute_unary(bgrnd, fgrnd, graph, pixel, source, sink , lambda, im_data)
    if( isempty(find(fgrnd == pixel, 1)) )
        p = pfb(im_data(fgrnd), im_data(bgrnd), im_data(pixel));
        graph(pixel,sink) = p + lambda;
    else
        graph(pixel,sink) = inf;
    end
    if( isempty(find(bgrnd == pixel, 1)) )
        graph(source,pixel) = 0;
    else
        graph(source,pixel) = inf;
    end
end


function [p] = pfb(fg, bg, pixel)
    p = mean(min(abs(fg-pixel)) / min(abs(bg-pixel)));
end

function [pos,values] = make_grid(pixel_row,pixel_col, gpb_thin, im_size, center)
    pos = zeros(2,2);
    pos(1,1) = center-1; %left
    pos(1,2) = center-im_size(2); %top
    pos(2,1) = center+im_size(2); %bottom
    pos(2,2) = center+1; %right
    values = zeros(2,2,3);
    try
        values(1,1,:) = gpb_thin(pixel_row,pixel_col-1,:); %left
    catch
        values(1,1,:) = [-1 -1 -1];
    end
    try
        values(1,2,:) = gpb_thin(pixel_row-1,pixel_col,:); %top
    catch
        values(1,2,:) = [-1 -1 -1];
    end
    try
        values(2,1,:) = gpb_thin(pixel_row+1,pixel_col,:); %bottom
    catch
        values(2,1,:) = [-1 -1 -1];
    end
    try
        values(2,2,:) = gpb_thin(pixel_row,pixel_col+1,:); %right
    catch
        values(2,2,:) = [-1 -1 -1];
    end
end