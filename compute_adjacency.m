function adj_list = compute_adjacency(graph)
    gsize = size(graph);
    adj_list = cell(gsize(1),1);
    for i = 1:gsize(1)-2
        adj_list{i} = [find(graph(i,:)) gsize(1)];
    end
    adj_list{gsize(1)-1} = 1:gsize(1)-2;
    adj_list{gsize(2)} = [];
end