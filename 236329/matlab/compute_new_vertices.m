function new_vertices = compute_new_vertices( original_vertices, transformations, weights )
    dimension = 2;

    [rows, cols, num_of_controls] = size(transformations);
    num_of_vertices = size(original_vertices,1);
    z_values = ones(num_of_vertices,1);
    original_vertices_with_z = [original_vertices , z_values]';
    transformations_rearrenged = permute(transformations, [2, 1, 3]);
    
    %all the transformations should be one under another so we can make the
    %multiplication with the vector coordinates column
    transformations_single_matrix = reshape(transformations_rearrenged, [cols, rows*num_of_controls])';
    
     new_vertices_single_matrix1 = transformations_single_matrix * original_vertices_with_z;
     new_vertices_single_matrix1_transpose = new_vertices_single_matrix1';
     
     %duplicate every column of weight matrix twice
     duplicated_weights=weights(:,ceil((1:2*size(weights,2))/2));
     
     
     new_weighted_vertices = duplicated_weights.*new_vertices_single_matrix1_transpose;
     
     %single_column = new_vertices_single_matrix1_transpose(:);
     
     %new_vertices_single_matrix2=reshape(single_column,[num_of_vertices*dimension,num_of_controls])'; 
     
     %new_vertices_single_matrix = new_vertices_single_matrix2';
     
     new_vertices_for_each_control = reshape(new_weighted_vertices,[num_of_vertices,dimension,num_of_controls]);
     
     %sum the results of all transformations (multiplied by their weights)
     %for the final new vertices
     
     
     
     new_vertices = sum(new_vertices_for_each_control,3);
    
    

end

