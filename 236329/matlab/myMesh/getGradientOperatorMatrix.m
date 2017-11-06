function [ gradientsM ] = getGradientOperatorMatrix( faces_areas, E )    
    num_rows = 3*length(faces_areas);
    num_columns = 3*length(faces_areas);
    faces_areas_column = 1./faces_areas;
    GfInverse = spdiags([faces_areas_column;faces_areas_column;faces_areas_column],0, num_rows, num_columns);
    gradientsM = 0.5 * GfInverse * E;
end

