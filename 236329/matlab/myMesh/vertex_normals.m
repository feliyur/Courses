function normals = vertex_normals(vertices, faces, face_normals, face_areas)

if nargin < 4
    [face_areas, new_normals] = triangle_areas(vertices, faces); 
    if nargin < 3
        face_normals = new_normals; 
    end    
end

face_idxs = repmat(1:size(faces, 2), size(faces, 1), 1); 

% matrix size: face num x vertex num 
face_vertex_incidence  = sparse(face_idxs(:), faces(:), face_areas(face_idxs(:)), size(faces, 2), size(vertices, 2)); 


assert(size(face_normals, 2)==size(faces, 2) && size(face_normals, 1)==3); 
normals = full(face_normals*face_vertex_incidence); 

normals = full(normals*spdiags(1./sqrt(dot(normals, normals))', 0, size(normals, 2), size(normals, 2))); 