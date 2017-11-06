function mIvf = interpolate_vertices_to_faces(vertices, faces)

mIvf = zeros(length(vertices),length(faces));

for i=1:length(vertices)
   for j=1:length(faces)
      mIvf(i,j) 
   end
end

% areas = zeros(1,length(vertices));
% for i=1:length(vertices)
%     indx = find(faces==i);
%     [r c] = ind2sub(size(faces),indx);
%     faces_areas = triangle_areas(vertices, faces);
%     areas(i) = sum(faces_areas(c));
% end


end

