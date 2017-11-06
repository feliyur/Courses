function [min_indexes, new_control_points] = get_closest_points(control_points, vertices, faces)
%%
% [min_indexes, new_control_points] = get_closest_points(control_points, vertices)
%   Finds mesh vertices closest to input control_points
%
% [min_indexes, new_control_points] = get_closest_points(control_points, vertices, faces)
%   Interprets control_points as a polyline, finding the vertices closest
%   to its intrsection of edges
%
% Inputs:
%  control_points - points the user placed, stacked in a column
%  vertices - coordinates of mesh vertices stacked in a column
%
% Outputs: 
%  min_indexes - indexes of found vertices
%  new_control_points - coordinates of found vertices

if nargin < 3
    num_of_vertices = length(vertices);
    num_of_control_points = size(control_points, 1);
    dimensions_arrangments_vertices = [1 1 num_of_control_points];
    repeated_vertices = repmat(vertices, dimensions_arrangments_vertices);

    dimensions_arrangments_control_points = [1,1,num_of_vertices];
    repeated_control_points = repmat(control_points, dimensions_arrangments_control_points);
    repeated_control_points_rearrenged = permute(repeated_control_points, [3,2,1]);

    vec_distances_from_control_points = repeated_vertices - repeated_control_points_rearrenged;
    distances_from_control_points = sum(vec_distances_from_control_points.^2,2); %second dimension is now 1.
    distances_from_control_points = permute(distances_from_control_points, [1,3,2]);

%     [min_distances, min_indexes] = min(distances_from_control_points); 
    [~, min_indexes] = min(distances_from_control_points); 
    new_control_points = vertices(min_indexes,:);
else
    
end
