function areas = vertex_areas(vertices, faces, faces_areas)

if nargin<3 || isempty(faces_areas)
    faces_areas = triangle_areas(vertices, faces);  end


% create a matrix of face idxs replicated by number of vertices per face. 
face_idxs = repmat(1:length(faces_areas), size(faces, 1), 1); 

% a matrix of size |V| x |F| containing face areas at vertex-face
% incidences
vertex_face_areas = sparse(faces(:), face_idxs(:), faces_areas(face_idxs(:)), size(vertices, 2), size(faces, 2)); 
areas = full(sum(vertex_face_areas, 2)/3)'; 
