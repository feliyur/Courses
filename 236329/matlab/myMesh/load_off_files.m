%% Do some stuff
close all;
clear all;
clc; 

%%
[vertices, faces, adj] = read_off_file('..\hw2_data\cat_s3.off');

patch('Faces',faces','Vertices',vertices','FaceColor','none');

%%