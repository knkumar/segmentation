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
function [max_flow] = ford_fulk(source,sink,graph,g_size)
    max_flow = spalloc(g_size(1),g_size(2),10);
    %max_flow = zeros(g_size);
    path = find_path(source,sink,graph, max_flow); 
    % path contains [from_node to_node capacity]
    while ~isempty(path)
        cf = min(path(:,3));
        from = path(:,1);
        to = path(:,2);
        indexes = (to-1) * size(max_flow,2) + from;
        reverse_ind = (from-1) * size(max_flow,2) + to;
        max_flow(indexes) = max_flow(indexes) + cf;
        max_flow(reverse_ind) = max_flow(reverse_ind) -cf;
        path = find_path(source, sink, graph, max_flow);
    end
end


%to find paths previously not found
function [path] = find_path(source,sink, graph, max_flow)
    q = []; %enqueue
    gsize = size(graph);
    visited = zeros(1,gsize(1));
    parent = zeros(1,gsize(1));
    q = [source q];
    visited(source) = 1; %mark source
    path = [];
    while ~isempty(q)
        %deque t
        t = q(end);
        q(end) = [];
        if t == sink
            visited(t) = 1;
            break;
        end
        edges = find_edges(graph, t);
        edge_indexes = (edges-1)*size(graph,2)+t;
        valid_visited = visited(edges) == 0;
        valid_capacities = graph(edge_indexes) > max_flow(edge_indexes);
        valid = valid_visited & valid_capacities;
        q = [edges(valid) q];
        parent(edges(valid)) = t;
        visited(edges(valid)) = 1;
    end
    if(visited(sink))
       to=sink;
       while to~=source
           from = parent(to);
           path = [from to graph(from,to) ; path];
           to = from;
       end
    else
        path = [];
    end
end

function [edge] = find_edges(graph, t)
    edges = graph(t,:) > 0;
    edge = find(edges);
end
