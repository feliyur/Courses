%%
close all
clc
% meshFilepath = 'data\2D\cat_s3.off'; 
% meshFilepath = 'alligator.obj'; 
meshFilepath = 'woody.obj'; 
% meshFilepath = 'data\2D\woody.obj'; 

if exist('hpoint', 'var') && ~isempty(hpoint)
    delete(hpoint); 
end
m = myMesh(meshFilepath); 
m.show(); 
% hpoint1 = impoint; 
% hpoint2 = impoint; 

% point1 = hpoint1.getPosition();
% point2 = hpoint2.getPosition();
point1 = [53, 247];
point2 = [300, 247];
vertices2D = m.vertices(1:2, :)';
min_indexes = get_closest_points([point1; point2], vertices2D); 
hold on
plot(m.vertices(1, min_indexes)', m.vertices(2, min_indexes)', 'r*'); 


% set(hpoint)
cv = []; 
tic 
W = biharmonic_bounded(m, min_indexes', [1 0; 0, 1], cv); 
toc

control_points = [point1 ; point2];
new_control_points = [point1(1),point1(2)+300 ; point2(1) point2(2)];
transformation_matrixs = get_transformation_matrix(control_points, new_control_points);
new_vertices = compute_new_vertices( vertices2D, transformation_matrixs, W );

figure;
disp_mesh(new_vertices', m.faces);


% %%
% close all;
% clc;
% 
% addpath('matlab');
% addpath('matlab/myMesh');
% % 
% % 
% % %colors by vertices areas
% % %gradient of vertices areas
% % figure;
% % title('gradient on vertices areas');
% % %m = myMesh('../hw_data/alligator.obj'); 
% % m = myMesh('../hw_data/flag.obj');
% % %m = myMesh('../hw_data/phands.off'); 
% 
% % meshFilepath = 'Z:\236329\project\bbw_project\data\cat_s3.off'; 
% % meshFilepath = 'Z:\236329\project\bbw_project\data\alligator.obj'; 
% %meshFilepath = 'hw_data/flag.obj'; 
% meshFilepath = 'alligator.obj'; 
% 
% m = myMesh(meshFilepath); 
% m.show(); 
% 
% %%%%
% close all
% % meshFilepath = 'data\2D\cat_s3.off'; 
% % meshFilepath = 'data\2D\alligator.obj'; 
% % meshFilepath = 'data\2D\woody.obj'; 
% meshFilepath = 'alligator.obj'; 
% 
% if exist('hpoint', 'var') && ~isempty(hpoint)
%     delete(hpoint); 
% end
% m = myMesh(meshFilepath); 
% m.show(); 
% hpoint1 = impoint; 
% hpoint2 = impoint;
 
