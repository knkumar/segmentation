% function to compute a graph from a image
%  - The graph nodes are the pixels
%  - The graph edges are similarity between the vectors
%    measured as euclidean distance
%  - The edges are computed only to neighbourig pixels which warrants the
%    use of sparse matrix features
function make_graph()
    addpath('./BSR/grouping/lib');
    img = '86016.jpg';
    im_fname = strtok(img,'.');
    iname = 'test.jpg';
    outname = 'test.mat';
    im_data = imread(img);
    im_size = size(im_data);
    n_nodes = im_size(1)*im_size(2);
    lambda = 0.3;
    while n_nodes > 15000
       im_data = imresize(im_data,[100 100]);
       im_size = size(im_data);
       n_nodes = im_size(1)*im_size(2);
    end
    imwrite(im_data,iname,'jpg');
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
    tic
    disp('');
    disp('creating the image graph based on energy potentials...');
    graph_fname = strcat(im_fname, '_graph.mat');
    if exist(graph_fname, 'file') 
        load(graph_fname, 'img_graph');
    else
        [bgrnd fmask] = compute_sets(im_size);
        img_graph = iterate_pixel(im_size, im_data, gPb_thin, bgrnd, fmask, lambda);
        save(graph_fname, 'img_graph');
    end
    time = toc; %#ok<*NASGU>
    disp('');
    disp('Solving graph for segmentation using ford fulkerson...');
    segmented_img = max_flow_ff(img_graph);
    save(strcat(im_fname,'_seg.mat'),'segmented_img');
    %[seg_img_src, seg_img_sink] = mark_segment(segmented_img, im_size);
    time_fin = toc;
    save((strcat(im_fname,'_time.mat')),'time_fin');
end

%To compute the masks
function [segments] = max_flow_ff(img_graph)
    gsize = size(img_graph);
    src = gsize(1) - 1;
    sink = gsize(1);
    max_flow = ford_fulk(src,sink,img_graph,gsize);
    segments = max_flow;
    time_ff = toc;
end

