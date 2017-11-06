function areas = vertex_areas(vertices, faces, faces_areas)

if nargin<3
    faces_areas = triangle_areas(vertices, faces);  end

face_idxs = repmat(1:length(faces_areas), size(faces, 1), 1); 

vertex_face_areas = sparse(faces(:), face_idxs(:), faces_areas(face_idxs(:)), size(vertices, 2), size(faces, 2)); 
areas = full(sum(vertex_face_areas, 2)/3)'; 
