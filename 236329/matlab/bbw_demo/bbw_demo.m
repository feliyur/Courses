% This is a script that demos computing Bounded Biharmonic Weights
% automatically for a 2D shape.
%
% This file and any included files (unless otherwise noted) are copyright Alec
% Jacobson. Email jacobson@inf.ethz.ch if you have questions
%
% Copyright 2011, Alec Jacobson (jacobson@inf.ethz.ch)
%

% NOTE: Please contact Alec Jacobson, jacobson@inf.ethz.ch before
% using this code outside of an informal setting, i.e. for comparisons.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load a mesh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% input mesh source: *.obj, *.off, *.poly, or *.png
filename = 'woody.obj';
%mesh_source = 'Cube_obj.obj';
%mesh_source = 'flag.obj';
%mesh_source = 'tpe9035778_4d9e_4dfc_b85f_42de24112e17.1.poly';
%mesh_source = 'alligator.obj';
%mesh_source = 'beethoven.obj';
%mesh_source = 'banana.obj';
%mesh_source = 'cat_s2.off';
%mesh_source = 'mona.png';
%mesh_source = 'mario.png';
% should input mesh be upsampled
upsample_mesh = false;

% if(~isempty(regexp(mesh_source,'\.(off|obj)$')))
%   % load a mesh from an OBJ
%   [V,F] = load_mesh(mesh_source);
%   % only keep x and y coordinates, since we're working only in 2D
%   V = V(:,1:2);
% elseif ~isempty(regexp(mesh_source,'\.poly$'))
%   % load a mesh from a .POLY polygon file format
%   % Triangulate in two-passes. First pass with just angle constraint forces
%   % triangles near the boundary to be small, but internal triangles will be very
%   % graded
%   [V,F] = triangle(mesh_source,'Quality',30);
%   % phony z-coordinate
%   V = [V, zeros(size(V,1),1)];
%   % compute minimum angle 
%   min_area = min(doublearea(V,F))/2;
%   % Use minimum area of first pass as maximum area constraint of second pass for
%   % a more uniform triangulation. probably there exists a good heuristic for a
%   % maximum area based on the input edge lengths, but for now this is easy
%   % enough
%   [V,F] = triangle(mesh_source,'Quality',30,'MaxArea',min_area);
% elseif ~isempty(regexp(mesh_source,'\.png$'))
%   % load a mesh from a PNG image with transparency
%   [V,F] = png2mesh(mesh_source,1,50);
% end
% 
% % upsample each triangle
% if(upsample_mesh)
%   [V,F] = upsample(V,F);
% end

  if ~isempty(regexp(filename,'\.off$'))
    [V,F] = readOFF(filename);
  elseif ~isempty(regexp(filename,'\.obj$'))
    [V,F] = read_obj_file(filename);
  else
    error('Input file must be .off or .obj file.');
  end
  
  V = V(:,1:2);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Place controls on mesh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% display mesh
%tsurf(F,V)
trisurf(F,V(:,1),V(:,2),zeros(size(V,1),1), 'FaceColor','interp');
view(2);
axis equal
axis manual

axis equal;
fprintf( ...
  ['\nCLICK on mesh at each location where you would like to add a ' ...
  'point handle.\n' ...
  'Press ENTER when finished.\n\n']);
% User clicks many times on mesh at locations of control points
try
  [Cx,Cy] = getpts;  
  %Cx = [53 ; 300]; Cy = [247 ; 247]; %david
%  Cx = [125 ; 125 ; 175 ; 175]; Cy = [125 ; 175 ; 125 ; 175]; %david
  %Cx = [-75 ; -75 ; 75 ; 75]; Cy = [-75 ; 75 ; -75 ; 75]; %david
catch e
  % quit early, stop script
  return
end
% store control points in single #P by 2 list of points
C = [Cx,Cy];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bind controls to mesh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Note: This computes the "normalized" or "optimized" version of BBW, *not* the
% full solution which solve for all weights simultaneously and enforce
% partition of unity as a proper contstraint. 

% Compute boundary conditions
[b,bc] = boundary_conditions(V,F,C);
% Compute weights
if(exist('mosekopt','file'))
  % if mosek is installed this is the fastest option
  W1 = biharmonic_bounded(V,F,b,bc,'conic');
else
  % else this uses the default matlab quadratic programming solver
  W1 = biharmonic_bounded(V,F,b,bc,'quad');
end
% Normalize weights
W = W1./repmat(sum(W1,2),1,size(W1,2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deform mesh via controls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Display mesh and control points and allow user to interactively deform mesh
% and view weight visualizations

% Commented out are examples of how to call "simple_deform.m" with various options
%points_and_cages = 
%simple_deform_david(V,F,C,W,'ShowWeightVisualization');
points_and_cages = 1:size(C,1);
BE=[];
CE=[];
simple_deform_david(V,F,C,W,points_and_cages,BE,CE);
% interactively deform point controls
%simple_deform(V,F,C,W)

