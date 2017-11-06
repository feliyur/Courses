function [ meanCurvature ] = getMeanCurvature( laplacian, vertices )
    laplace_of_vertices = laplacian * vertices;
    %mean curvature is half the norm of laplace_of_vertices (||laplace_of_vertices||)
    %in the lectures notes it was different than in the book (it didn't
    %multiply by 0.5). we used the equation from the book.
    meanCurvature = 0.5*sqrt(sum((laplace_of_vertices).^2,2));
end

