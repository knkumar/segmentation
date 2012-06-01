% syntax:
%   [max_flow] = ford_fulk(source,sink,graph, g_size)
%
% description:
%   compute maxflow of a network using ford_fulkerson/Edmond karps
%
% arguments:
%   source :  source node in graph
%   sink   :  sink node in graph
%   graph  :  graph of nxn sparse matrix
%   g_size :  size of graph
%
% outputs (uint8):
%   max_flow : computed maxflow of the graph between source and sink
%
% Kiran Kumar <krankumar@gmail.com>
% Mar 2012
function [max_flow] = ford_fulk(source,sink,graph,g_size, adj_list)
    max_flow = spalloc(g_size(1),g_size(2),10);
    %max_flow = zeros(g_size);
    path = find_path(source,sink,graph, max_flow, g_size, adj_list); 
    
    % path contains [from_node to_node capacity]
    while ~isempty(path)
        cf = min(path(:,3));
        from = path(:,1);
        to = path(:,2);
        indexes = sub2ind(g_size, from, to); 
        reverse_ind = sub2ind(g_size, to, from); 
        max_flow(indexes) = max_flow(indexes) + cf;
        max_flow(reverse_ind) = max_flow(reverse_ind) -cf;
        path = find_path(source, sink, graph, max_flow,g_size, adj_list);
    end
end


%to find paths previously not found
function [path] = find_path(source,sink, graph, max_flow, gsize, adj_list)
    q = []; %enqueue
    %gsize = size(graph);
    visited = zeros(1,gsize(1));
    parent = zeros(1,gsize(1));
    q = [source q];
    visited(source) = 1; %mark source
    path = [];
    while ~isempty(q)
        %deque t
        t = q(end);
        q(end) = [];
        visited(t) = 2;
        col = adj_list{t};
        if isempty(col)
            continue;
        end
        valid_visited = visited(col) == 0;
        valid_cols = col(valid_visited);
        valid_capacities = graph(t,valid_cols) > max_flow(t,valid_cols);
        valid_edges = valid_cols(valid_capacities);
        q = [valid_edges(end:-1:1) q];
        parent(valid_edges) = t;
        visited(valid_edges) = 1;
    end
    if(visited(sink) == 2)
       to=sink;
       while to~=source
           from = parent(to);
           path = [from to ( graph(from,to)-max_flow(from,to) ) ; path];
           to = from;
       end
    else
        path = [];
    end
end