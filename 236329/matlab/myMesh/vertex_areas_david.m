function areas = vertex_areas(vertices, faces)

faces_areas = triangle_areas(vertices, faces);

areas = zeros(1,length(vertices));
for i=1:length(vertices)
    indx = find(faces==i);
    [r c] = ind2sub(size(faces),indx);
    areas(i) = sum(faces_areas(c));
end

