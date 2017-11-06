function [ divergence ] = getDivergenceOperatorMatrix( vertice_areas, faces_areas, gradientOperator )

    num_rows_Gf = 3*length(faces_areas);
    num_columns_Gf = 3*length(faces_areas);
    Gf = spdiags([faces_areas';faces_areas';faces_areas'],0, num_rows_Gf, num_columns_Gf); 
    
    num_rows_Gvinv = length(vertice_areas);
    num_columns_Gvinv = length(vertice_areas);
    Gvinv = spdiags(1./vertice_areas',0, num_rows_Gvinv, num_columns_Gvinv);  
    
    divergence = -Gvinv*gradientOperator'*Gf;
end

