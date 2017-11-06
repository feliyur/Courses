function temp_yuri
    %% Load and display mesh
    close all
    % meshFilepath = 'data\2D\cat_s3.off'; 
    % meshFilepath = 'data\2D\alligator.obj'; 
    % meshFilepath = 'data\alligator.obj'; 
    meshFilepath = 'data\2D\woody.obj'; 

    if exist('hpoint', 'var') && ~isempty(hpoint)
        delete(hpoint); 
    end
    m = myMesh(meshFilepath); 
    m.show(); 
    hold on
    % hpoint1 = impoint; 

    %% Set handles
    lh = []; 
    finished = false; 
    
    function process_keypress(source, eventdata, handles)
        if finished
            return; end
        
        finished = true; 
%         hh = get(gcf, 'WindowKeyPressFcn'); 
%         eventdata.Character = char(27); 
%         eventdata.Key = 'escape'; 
%         hh(source, eventdata, handles); 
    end
    
    while ~finished
        set(gcf, 'WindowKeyPressFcn', @process_keypress); 

        h = impoly('Closed', false); 
        if ~isempty(h)
            pos = h.getPosition(); 
            lh = [lh; h]; 
        end
    end

    pg = []; 
    for ii=1:numel(lh)
        if ~isempty(pg) 
            pg = [pg; [NaN NaN]]; end
        
        cur_pos = lh(ii).getPosition(); 
%         cur_pos = unique([cur_pos; cur_pos(1, :)], 'rows'); 
        cur_pos = [cur_pos; cur_pos(1, :)]; 
        
        pg = [pg; cur_pos]; 
    end
    
    %%
    % m = myMesh(mesh_source); 
    % V = m.vertices(1:2, :)'; 
    F = m.faces'; 
%     % [x, y] = getpts; 
%     [x1, y1] = getline;
%     [x2, y2] = getline;
%     [x3, y3] = getline;
% 
%     plot(x1, y1, 'b'); 
%     plot(x2, y2, 'm'); 
%     plot(x3, y3, 'c'); 
    p = []; 
    pl = []; 
%     pl = [x1, y1; NaN, NaN; x2, y2; NaN NaN; x3, y3]; 
%     pg = []; 


    % C = [x, y]; 
    % hpoint2 = impoint; 
    % C = [hpoint1.getPosition(); hpoint2.getPosition()]; 

    % min_indexes = get_closest_points(C, m.vertices(1:2, :)'); 
    [bv, bc] = boundary_conditions(m, p, pl, pg); 
    hold on
    plot(m.vertices(1, bv)', m.vertices(2, bv)', 'r*'); 
    %%

    % set(hpoint)
    cv = []; 
    tic 
    % W = biharmonic_bounded(m, bv, bc, cv); 
    W = biharmonic_bounded(m, bv, bc, cv); 
    toc
end