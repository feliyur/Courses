classdef myMesh < handle    
   % myMesh class
   %
   % Constructor usage: 
   % 1) obj=myMesh(filename)
   % 2) obj=myMesh(V, F)
   %
   % In option (1), filename must contain a path to a valid
   % mesh file (.obj or .off as of 06/07/2015
   %
   % In (2), V must be the 2xn or 3xn matrix containig the vertex
   % coordinates, where n is the total number of vertices, F is the
   % 3 by m matrix of triangular faces. 
   properties (Access = public)
      adjM = []
      vertices = []
      faces = []
      faces_areas = []
      vertice_areas = []
      faces_centers = []
      matrixIvf = [];
      vertice_valencies = []; 
      edge_lengths = []; 
      Ifv = []; % faces to vertices
      Ivf = []; % vertices to faces
      faces_normals=[]
      E = [];
      gradient = [];
      divergence = [];
      laplacian = [];
      gaussianCurvator = [];
      meanCurvature = [];
      vertice_normals = []; 
      W = [];  % cotangent weights matrix
   end
   methods (Access = public)
       % constructor
       function obj=myMesh(varargin)           
           % create two calling schemes, one for only filename,
           fnameonly = inputParser;
           addRequired(fnameonly, 'filename', @ischar);
           
           vandf = inputParser;
           addRequired(vandf, 'V', @(x)(isnumeric(x) && (size(x, 1)==2 || size(x, 1)==3)));
           addRequired(vandf, 'F', @(x)(isnumeric(x) && (size(x, 1)==3)));
           
           switch nargin
               case 1
                   parse(fnameonly, varargin{:});
                   obj.load(fnameonly.Results.filename);
               case 2
                   parse(vandf, varargin{:}); 
                   setMesh(obj, vandf.Results.V, vandf.Results.F);                    
           end
       end
       
       % load function
       function load(obj, filename)
           [~, ~, ext] = fileparts(filename); 
           switch ext
               case '.off'
%                    [obj.vertices, obj.faces] = read_off_file(filename);
                    [V, F] = read_off_file(filename);
               case '.obj'
                   [V,F] = readOBJfast(filename); 
                   V = V';
                   F = F'; 
%                    [obj.vertices,obj.faces] = readOBJfast(filename); 
%                    obj.vertices = obj.vertices' ; 
%                    obj.faces = obj.faces';
               otherwise
                   error(['Unrecognized extension for file ''' filename '''']); 
           end      
           setMesh(obj, V, F);            
       end
       
       % write function
       function write(obj, filename)
           write_off_file(filename, obj.vertices, obj.faces); 
       end
       
       % show
       function show(obj, vertex_func, varargin)
           if nargin < 2
               disp_mesh(obj.vertices, obj.faces); 
           else
               disp_mesh(obj.vertices, obj.faces, vertex_func, varargin{:});
           end
       end       
       
       % face areas
       function [areas, normals] = compute_triangle_areas(obj)
           [areas, normals] = triangle_areas(obj.vertices, obj.faces); 
       end
       
       % vertex areas
       function areas = compute_vertex_areas(obj, faces_areas)
           if nargin>1
               areas = vertex_areas(obj.vertices, obj.faces, faces_areas);   
           else
               areas = vertex_areas(obj.vertices, obj.faces); 
           end
       end
       
       % interpolate vertices to faces
       function mIvf = vertices_to_faces(obj, mIfv)
           if nargin<2 || isempty(mIfv)
               mIfv = faces_to_vertices(obj); end
%            mIvf = interpolate_vertices_to_faces(obj.vertices, obj.faces);
            mIvf = diag(sparse(1./obj.faces_areas))*mIfv'*diag(sparse(obj.vertice_areas)); 
       end
       
       function mIfv = faces_to_vertices(obj)
           mIfv = faces_to_vertices(obj.vertices, obj.faces, obj.faces_areas, obj.vertice_areas); 
       end       
       
       function W = cot_weights_matrix(obj)
           if ~isempty(obj.W)
               W = obj.W; 
               return;
           end
           
           if isempty(obj.faces_areas)
               [obj.faces_areas, obj.faces_normals] = compute_triangle_areas(obj);  end
           
           if isempty(obj.E)
               obj.E = calculate_E(obj.vertices', obj.faces', obj.faces_normals');  end
           
           W = obj.E'*spdiags(1./(repmat(obj.faces_areas', 3, 1)), 0, 3*length(obj.faces_areas), 3*length(obj.faces_areas))*obj.E; 
           obj.W = W; 
       end
   end
   methods (Access = private)
       function setMesh(obj, V, F)
           obj.vertices = V; 
           obj.faces = F; 
           
           obj.adjM = vertex_adj(obj.vertices, obj.faces); 
           [obj.faces_areas, obj.faces_normals] = obj.compute_triangle_areas(); 
           obj.E = calculate_E(obj.vertices', obj.faces', obj.faces_normals');
           
           obj.gradient = getGradientOperatorMatrix(obj.faces_areas', obj.E);
           
           
           obj.vertice_areas = obj.compute_vertex_areas(obj.faces_areas);
           obj.gaussianCurvator = getGaussianCurvature(obj.vertices', obj.faces', obj.vertice_areas');
           
           obj.divergence = getDivergenceOperatorMatrix( obj.vertice_areas, obj.faces_areas, obj.gradient );
           obj.laplacian = getLaplacianOperator( obj.divergence , obj.gradient);
           obj.meanCurvature = getMeanCurvature( obj.laplacian, obj.vertices' );
           
           obj.Ifv = obj.faces_to_vertices(); 
           [obj.matrixIvf, obj.Ivf] = deal(obj.vertices_to_faces());
%            obj.vertex_valency = obj.compute_vertices_valency();   removed because no 
%                                                                   need to wrap one line
           obj.vertice_valencies = full(sum(obj.adjM,2)); 
           obj.edge_lengths = edge_lengths(obj.vertices, obj.adjM);  %#ok<CPROP>
           obj.faces_centers = triangle_centers(obj.vertices, obj.faces); 
           obj.vertice_normals = vertex_normals(obj.vertices, obj.faces, obj.faces_normals, obj.faces_areas);
       end
   end
%    enumeration
%       
%    end
end