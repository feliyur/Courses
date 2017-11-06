function el = edge_lengths(vertices, adjM)

[I, J] = find(adjM); 

edge_vec = vertices(:, I) - vertices(:, J); 
el = sqrt(dot(edge_vec, edge_vec)); % dot (sum) along first dimension by default (R2015a)
