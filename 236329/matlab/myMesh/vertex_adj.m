function S = vertex_adj(vertices, faces)

adj = unique([faces(1:2, :), faces(2:3, :), [faces(3, :); faces(1, :)]]', 'rows'); 
S = sparse(adj(:,1),adj(:, 2), true, size(vertices, 2), size(vertices, 2), 2*length(adj)); 
S = S | S'; 
