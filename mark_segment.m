function [seg_img_src, seg_img_sink] = mark_segment(seg_graph, img_size)
    seg_img_src = size(img_size);
    seg_img_sink = size(img_size);
    seg_size = size(seg_graph);
    source = seg_size(1) - 1;
    sink = seg_size(1);
    %mark all source nodes as 0
    set(0,'RecursionLimit',inf)
    seg_img_src = mark_nodes(seg_img_src, source, seg_graph, 0);
    %mark all sink nodes as 1
    seg_img_sink = mark_nodes(seg_img_sink, sink, seg_graph', 1);
end

function [seg_img] = mark_nodes(seg_img, source, seg_graph, value)
    seg_temp = seg_img';
    seg_temp(seg_graph(source,:) > 0) = value;
    seg_img = seg_temp';
    next = find(seg_graph(source,:));
    for i = 1:size(next,1)
        seg_img = mark_nodes(seg_img, next(i), seg_graph, value);
    end
end