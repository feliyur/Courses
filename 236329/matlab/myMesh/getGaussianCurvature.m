function [ gaussianCurvator ] = getGaussianCurvature( vertices, faces, vertice_areas)    
    edges12 = vertices(faces(:,2), :) - vertices(faces(:,1),:);
	edges13 = vertices(faces(:,3), :) - vertices(faces(:,1),:);
	edges23 = vertices(faces(:,3), :) - vertices(faces(:,2),:);
    
    edges12Length = sqrt(sum(edges12'.^2))';
    edges13Length = sqrt(sum(edges13'.^2))';
    edges23Length = sqrt(sum(edges23'.^2))';
    
	normalizedEdges12 = [1./edges12Length 1./edges12Length 1./edges12Length].*edges12;
	normalizedEdges13 = [1./edges13Length 1./edges13Length 1./edges13Length].*edges13;
	normalizedEdges23 = [1./edges23Length 1./edges23Length 1./edges23Length].*edges23;
    
    normalizedEdges21 = -normalizedEdges12;
    normalizedEdges31 = -normalizedEdges13;
    normalizedEdges32 = -normalizedEdges23;
    
    cosAngle1 = dot(normalizedEdges12' , normalizedEdges13')';
    cosAngle2 = dot(normalizedEdges21' , normalizedEdges23')';
    cosAngle3 = dot(normalizedEdges31' , normalizedEdges32')'; 
    
	radianAngles =  acos([cosAngle1 cosAngle2 cosAngle3]);
    
%    angleInDegrees = radtodeg(radianAngles)
    
    faces_indexes = (1:length(faces))';
    num_rows = length(vertices);
    num_columns = length(faces);
    sparse_radian_angles = sparse(faces, [faces_indexes faces_indexes faces_indexes], radianAngles, num_rows, num_columns);
    gaussianCurvator = (2*pi - sum(sparse_radian_angles,2)) ./ vertice_areas;
end
