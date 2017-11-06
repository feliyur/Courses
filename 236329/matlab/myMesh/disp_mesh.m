function disp_mesh(vertices, faces, vertex_func, varargin)

call_mode = []; 
isVectorField = false; 

if nargin >= 3
    if isempty(vertex_func)
        call_mode = DispMeshCallMode.NoFunc; 
    else
        if size(vertex_func, 1)>6
            warning('looks like function values are a column vector. transposing ')
            vertex_func = vertex_func'; 
        end
        if size(vertex_func, 1) == 3
            if size(vertex_func, 2) == size(faces, 2)
                call_mode = DispMeshCallMode.FaceVectorField; 
                isVectorField = true; 
            else
                call_mode = DispMeshCallMode.VertexVectorField; 
                isVectorField = true; 
            end
        elseif size(vertex_func, 1) == 6
            call_mode = DispMeshCallMode.VectorField; 
            isVectorField = true; 
        else
            if size(vertex_func, 2) == size(faces, 2)
                call_mode = DispMeshCallMode.FaceFunc; 
            else
                call_mode = DispMeshCallMode.VertexFunc; 
            end
        end
    end
else
    call_mode = DispMeshCallMode.TwoParams; 
end

switch call_mode
    case DispMeshCallMode.NoFunc
        patch('Faces',faces','Vertices',vertices','FaceColor','none', varargin{:});
    case {DispMeshCallMode.FaceVectorField, DispMeshCallMode.VertexVectorField}
%         patch('Faces',faces','Vertices',vertices', varargin{:}); 
    case DispMeshCallMode.FaceFunc
        patch('Faces',faces','Vertices',vertices','FaceVertexCData', vertex_func', 'FaceColor', 'flat', varargin{:}); 
    case DispMeshCallMode.VertexFunc
%        patch('Faces',faces','Vertices',vertices','FaceVertexCData', vertex_func', 'EdgeColor', 'interp', varargin{:}); 
patch('Faces',faces','Vertices',vertices','FaceVertexCData', vertex_func', 'FaceColor', 'interp', varargin{:});
    case DispMeshCallMode.TwoParams
        patch('Faces',faces','Vertices',vertices','FaceColor','none');                         
end

if isVectorField 
    toggledHold = false; 
    if ~ishold(gca)
        toggledHold = true; 
        hold(gca); 
    end
    
    switch call_mode
        case DispMeshCallMode.FaceVectorField
            tc = triangle_centers(vertices, faces); 
            quiver3(tc(1, :)', tc(2, :)', tc(3, :)', vertex_func(1, :)', vertex_func(2, :)', vertex_func(3, :)', 'color',[0 0 0]); 
        case DispMeshCallMode.VertexVectorField
            quiver3(vertices(1, :)', vertices(2, :)', vertices(3, :)', vertex_func(1, :)', vertex_func(2, :)', vertex_func(3, :)', 'color',[0 0 0]); 
        case DispMeshCallMode.VectorField
            quiver3(vertex_func(1, :)', vertex_func(2, :)', vertex_func(3, :)', vertex_func(4, :)', vertex_func(5, :)', vertex_func(6, :)', varargin{:}, 'color',[0 0 0]); 
    end
    
    if toggledHold
        hold(gca); end
end

axis equal; % Important
