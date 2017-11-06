function Ifv = faces_to_vertices(vertices, faces, faces_areas, vertice_areas)

if nargin<3 || isempty(faces_areas)
    faces_areas = triangle_areas(vertices, faces);  end

if nargin<4 || isempty(vertice_areas)
    vertice_areas = vertex_areas(vertices, faces, faces_areas); end

face_idxs = repmat(1:length(faces_areas), size(faces, 1), 1); 

Ifv = sparse(faces(:), face_idxs(:), faces_areas(face_idxs(:))./(3*vertice_areas(faces(:))), size(vertices, 2), size(faces, 2)); 
