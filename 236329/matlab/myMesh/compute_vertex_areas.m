function areas = compute_vertex_areas(vertices, faces, faces_areas)
   if nargin>1
       areas = vertex_areas(vertices, faces, faces_areas);   
   else
       areas = vertex_areas(vertices, faces); 
   end
end