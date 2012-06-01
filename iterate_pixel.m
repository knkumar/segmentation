%compute pairwise pixel energies and unary pixel energies

function [graph] = iterate_pixel(im_size, gpb_thin)
    graph_size = (im_size(1) * im_size(2)) + 2;
    %sigma = compute_std(gpb_thin);
    sigma = 2;
    graph = spalloc(graph_size,graph_size,4);
    graph = compute_pairwise(graph, im_size, gpb_thin, sigma);
end

function sdev = compute_std(gpb_thin)
    gPb_thin = gpb_thin(:);
    sdev = std(gPb_thin);
end

function [graph] = compute_pairwise(graph, im_size, gpb_thin, sigma)
    for i = 1:im_size(1)
        for j = 1:im_size(2)
            %for every pixel compute the weights to every neighbouring pixel
            center = sub2ind(im_size, i ,j); %center
            center_value = gpb_thin(center);
            if i < im_size(1)
                bottom = sub2ind(im_size, i+1 ,j);
                val = exp( -max(center_value, gpb_thin(bottom))/(sigma^2) );
                graph(center , bottom) = val; %center-bottom
                graph(bottom , center) = val; %bottom-center
            end
            if j < im_size(2)
                right = sub2ind(im_size, i ,j+1);
                val = exp( -max(center_value, gpb_thin(right))/(sigma^2) );
                graph(center , right) = val; %center-right
                graph(right , center) = val; %right-center
            end
            if i < im_size(1) && j < im_size(2)
                diag = sub2ind(im_size, i+1 ,j+1);
                val = exp( -max(center_value, gpb_thin(diag))/(sigma^2) );
                graph(center , diag) = val; %center-right
                graph(diag , center) = val; %right-center
            end
        end
    end
end
