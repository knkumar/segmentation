% function to compute a graph from a image
%  - The graph nodes are the pixels
%  - The graph edges are similarity between the vectors
%    measured as euclidean distance
%  - The edges are computed only to neighbourig pixels which warrants the
%    use of sparse matrix features
function make_graph()
    %matlabpool(8);
    addpath('./BSR/grouping/lib');
    img = 'drawing.jpg';
    im_fname = strtok(img,'.');
    iname = 'test.jpg';
    outname = 'test.mat';
    im_data = imread(img);
    im_size = size(im_data);
    n_nodes = im_size(1)*im_size(2);
    
    while n_nodes > 5000
       im_data = imresize(im_data, 0.5);
       im_size = size(im_data);
       n_nodes = im_size(1)*im_size(2);
    end
    imwrite(im_data,iname,'jpg');
    im_size = size(im_data);
    %img_graph = sparse(im_size(1)*im_size(2),im_size(1)*im_size(2));
    
    
    disp('');
    disp('computing gPb contours...');
    gPB_fname = strcat(im_fname,'_gPb_thin.mat');
    if exist(gPB_fname, 'file')
        load(gPB_fname,'gPb_thin');
    else
        [gPb_orient, gPb_thin, textons] = globalPb(iname); %#ok<NASGU,ASGLU>
        save(gPB_fname, 'gPb_thin');
        save(strcat(im_fname,'_gpb_opient.mat'), 'gPb_orient');
        save(strcat(im_fname,'_texton.mat'), 'textons');
    end
    id_time = tic;
    
    disp('');
    disp('creating the image graph based on energy potentials...');
    graph_fname = strcat(im_fname, '_graph.mat');
    [bgrnd fmask] = compute_sets(im_size);
    %normalize
    gPb_thin = gPb_thin ./ max(gPb_thin(:));
    %gPb_thin(gPb_thin < 0.5) = 0;
    if exist(graph_fname, 'file') 
        load(graph_fname, 'graph');
    else
        graph = iterate_pixel(im_size, gPb_thin);
        save(graph_fname, 'graph');
    end

    lambda = [50 100];    
    segmented_img = cell(size(lambda,2) ,size(fmask,2) );
    source_row = size(graph,2) - 1;
    sink_col = size(graph,2);
    %compute the edge adjacency list
    % adj_list(i) - gives all the edges incident on that vertex
    adj_list = compute_adjacency(graph);
    for j = 1:size(lambda,2)
        parfor i = 1:size(fmask,2)
            img_graph = compute_unary(bgrnd{2}, fmask{i}, graph, source_row, sink_col, lambda(j), im_data);
            disp('');
            str = sprintf('Solving graph for segmentation using ford fulkerson for lambda %f seed %d...',lambda(j),i);
            disp(str);
            flow_img = max_flow_ff(img_graph, adj_list);
            segmented_img{j,i} = extract_seg(img_graph, flow_img, im_size, bgrnd{2}, fmask{i});
            imwrite(segmented_img{j,i}, sprintf('%s_%f_%d.jpg',im_fname,lambda(j),i), 'jpeg');
        end
    end
    save(strcat(im_fname,'_seg.mat'),'segmented_img');
    %[seg_img_src, seg_img_sink] = mark_segment(segmented_img, im_size);
    time_fin = cputime;
    save((strcat(im_fname,'_time.mat')),'time_fin');
    %matlabpool close
end


%To compute the masks
function [segments] = max_flow_ff(img_graph, adj_list)
    gsize = size(img_graph);
    src = gsize(1) - 1;
    sink = gsize(1);
    max_flow = ford_fulk(src,sink,img_graph,gsize, adj_list);
    segments = max_flow;
end

function [img_seg] = extract_seg(graph, seg_img, im_size, bg, fg)
    test = (graph ~=0 & seg_img == graph) | seg_img == inf;
    [row, col] = find(test);
    r = row < im_size(1)*im_size(2);
    c = col < im_size(1)*im_size(2);
    seg = zeros(im_size(1), im_size(2));
    seg(col(c)) = 1;
    seg(row(r)) = 1;
    img_seg = seg > 0;
end
