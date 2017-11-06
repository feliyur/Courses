function E = calculate_E(vertices, faces, normals)

    rotatedEdge3 = cross(normals,vertices(faces(:,2), :) - vertices(faces(:,1),:),2);
    rotatedEdge2 = cross(normals,vertices(faces(:,1), :) - vertices(faces(:,3),:),2);
    rotatedEdge1 = cross(normals,vertices(faces(:,3), :) - vertices(faces(:,2),:),2);
    
    facesIndexes = (1:length(faces))';
    num_rows = length(faces);
    num_columns = length(vertices);
    
    x=sparse([facesIndexes facesIndexes facesIndexes],faces,[rotatedEdge1(:,1) rotatedEdge2(:,1) rotatedEdge3(:,1)],num_rows,num_columns);
    y=sparse([facesIndexes facesIndexes facesIndexes],faces,[rotatedEdge1(:,2) rotatedEdge2(:,2) rotatedEdge3(:,2)],num_rows,num_columns);
    z=sparse([facesIndexes facesIndexes facesIndexes],faces,[rotatedEdge1(:,3) rotatedEdge2(:,3) rotatedEdge3(:,3)],num_rows,num_columns);
    
    E=[x; y; z];
end