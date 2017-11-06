% addpath(genpath(pwd)); 
close all;

filename = 'alligator.obj';
%filename                               = 'flag.obj';

  if ~isempty(regexp(filename,'\.off$'))
    [V,F] = readOFF(filename);
  elseif ~isempty(regexp(filename,'\.obj$'))
%     [V,F] = read_obj_file(filename);
    m = myMesh(filename); 
  else
    error('Input file must be .off or .obj file.');
  end
  
  F = m.faces'; 
  V = m.vertices(1:2, :)';

% input handle source: *.tgf
%handles_fileName = 'alligator-skeleton-cage-points.tgf';
handles_fileName = 'alligator-handles.txt';
[C,BE,CE] = getHandles(handles_fileName);
points_and_cages = 1:size(C,1);
points_and_cages = points_and_cages(~ismember(points_and_cages,BE(:)));
% only keep x and y
C = C(:,1:2);



points_and_bones_and_cages = 1:size(C,1);
points_and_cages = points_and_bones_and_cages(~ismember(points_and_bones_and_cages,BE(:))); %removing bones
points_only_indexes = points_and_cages(~ismember(points_and_cages,CE(:))); %removing cages
points_only_coordinates = C(points_only_indexes,:);
bones_coordinates = [32 , 125 ; 207 , 134 ; 218 , 97 ; 42 , 81];
cages_coordinates = C(CE);

% Compute boundary conditions
[b, bc] = boundary_conditions(m, points_only_coordinates, bones_coordinates, []); 
%[b,bc] = boundary_conditions(V,F,C,points_and_cages,BE,CE);
% Compute weights
if(exist('mosekopt','file'))
  % if mosek is installed this is the fastest option
  W1 = biharmonic_bounded(V,F,b,bc,'conic');
else
  % else this uses the default matlab quadratic programming solver
  W1 = biharmonic_bounded(m,b,bc,[], false);
end
% Normalize weights
W = W1./repmat(sum(W1,2),1,size(W1,2));

figure;
%deform_mesh(V,F,C,W,points_and_cages,BE,CE);
%alligator_animation(V,F,C,W,points_and_cages,BE,CE);

C = [32 125 ; 42 81 ; 218 97 ; 207 134 ; 842 114 ; 972 97];
BE=[1 4; 2 3 ; 3 4];
alligator_animation(V,F,C,W,points_and_cages,BE,[]);

