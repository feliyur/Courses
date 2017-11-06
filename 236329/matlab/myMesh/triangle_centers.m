function tc = triangle_centers(vertices, faces)
    face_idxs = repmat(1:size(faces, 2), size(faces, 1), 1); 
    face_vertices_num = sum(faces(:, face_idxs(:)) ~= -1); 
    vertex_face_adj = sparse(faces(:), face_idxs(:), 1./face_vertices_num(:), size(vertices, 2), size(faces, 2)); 
    tc = vertices*vertex_face_adj; % 3xNv x Nv*Nf -> 3*Nf    
end