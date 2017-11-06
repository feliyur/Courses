function [areas, normals]=triangle_areas(vertices, faces)

ind1 = faces(1, :); 
ind2 = faces(2, :); 
ind3 = faces(3, :); 

vec1 = vertices(:, ind1)-vertices(:, ind2); 
vec2 = vertices(:, ind3)-vertices(:, ind2); 

normals = cross(vec1, vec2); 
areas = sqrt(dot(normals, normals))/2; 
%normals = -normals*diag(1./(2*areas)); % unit normals
normals = -normals*spdiags(1./(2*areas'), 0, length(areas), length(areas)); % unit normals

