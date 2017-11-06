function [bv, bc] = boundary_conditions(mesh, p, pl, pg)
%%
% [bv, bc] = boundary_conditions(p, pl, pg)
% Computes constraints for specified handles
% inputs: 
%  mesh - a myMesh object
%  p  - point constraints
%  pl - polyline constraints (bones)
%  pg - polygon constraints (cages)
%
% outputs: 
%  bv - constained vertices indices
%  bc - weights for constraints, a |bv| x m matrix


V = mesh.vertices(1:2, :)'; 
F = mesh.faces'; 


% num of constraints
ncp = size(p, 1);    

if isempty(pl)
    ncpl = 0;
else
    plidx = find(isnan(pl(:, 1))); 
    ncpl = diff([0 plidx' size(pl, 1)+1]);
    ncpl = sum(ncpl-2) + sum(ncpl==2); 
end

if isempty(pg)
    ncpg = 0; 
else
    ncpg = sum(~isnan(pg(:, 1))); 
end

nc = ncp + ncpl + ncpg; 

bigI = eye(nc); 

[bvp, bcp]  = point_constraints(V, p); 
[bvpl, bcpl] = polyline_constraints(V, F, pl); 
[bvpg, bcpg] = polygon_constraints(V, F, pg); 

bv = [bvp; bvpl; bvpg]; 
bc = [bcp; bcpl; bcpg]; 

function [bv, bc] = point_constraints(V, p)
    if isempty(p)
        [bv, bc] = deal([]); 
        return; 
    end

    [min_indexes, ~] = get_closest_points(p, V); 
    bv = min_indexes';     
    bc = bigI(1:ncp, :); 
end

function [bvpl, bcpl] = polyline_constraints(V, F, pl)
    if isempty(pl)
        bvpl = []; 
        bcpl = []; 
        return; 
    end
    
    if size(pl, 2) > 3
        warning('looks like polyline coordinates are stacked in a row. Working on transpose')
        pl = pl';
    end
    pos_pl = [0; find(isnan(pl(:, 1))); size(pl, 1)+1]; 
    num_pl = numel(pos_pl)-1; 

    base_transf = ncp; 
    
    bvpl = []; 
    bcpl = []; 
    for ii=1:num_pl
        cur_pl = pl(pos_pl(ii)+1:pos_pl(ii+1)-1, :); 
        cur_np = size(cur_pl, 1); % current num points
        cur_ne = cur_np-1; % current num edges        

        % find mesh vertices related to polyline vertices 
        [flidx, ~] = get_closest_points(cur_pl, V); 
        
        if length(flidx)> 1
            % point constraints 
            flctr = [bigI(base_transf+1, :); (bigI(base_transf + (1:cur_ne-1), :)+ bigI(base_transf + (2:cur_ne), :))/2; bigI(base_transf+cur_ne, :)]; 
            
            % find polyline itersections with mesh edges
            [ise, isp] = intersect_with_edges(V, F, cur_pl);  

            % find related mesh vertices
            [pidx, ~] = get_closest_points(isp, V); 

            % remove vertices already associated to polyline endpoints
            sel = ~ismember(pidx, flidx); 
            pidx = pidx(sel); ise = ise(sel); isp = isp(sel, :); 
            
            % arrange by edge order
            [cur_bvpl, I] = sortrows([(0.5:cur_np)', flidx', flctr; ise, pidx', bigI(base_transf+ise, :)], 2); 
            bvpl = [bvpl; cur_bvpl(:, 2)]; 
            bcpl = [bcpl; cur_bvpl(:, 3:end)]; 

            base_transf = base_transf + cur_ne; 
        else
            bvpl = [bvpl; flidx]; 
            bcpl = [bcpl; bigI(base_transf+1, :)]; 
            base_transf = base_transf + 1; 
        end
    end
end

function [bvpg, bcpg] = polygon_constraints(V, F, pg)
    if size(pg, 2) > 3
        warning('looks like polygon coordinates are stacked in a row. Working on transpose')
        pg = pg';
    end
    pos_pg = [0; find(isnan(pg(:, 1))); size(pg, 1)+1]; 
    num_pg = numel(pos_pg)-1; 

    base_transf = ncp+ncpl; 
    
    bvpg = []; 
    bcpg = []; 
    for ii=1:num_pg
        cur_pg = pg(pos_pg(ii)+1:pos_pg(ii+1)-1, :); 
        cur_np = size(cur_pg, 1); % current num points
        cur_ne = cur_np; % current num edges        

        % find mesh vertices related to polyline vertices 
        [flidx, modified_pg] = get_closest_points(cur_pg, V); 
        
        if length(flidx)> 1
            % point constraints 
%             flctr = [bigI(base_transf+1, :); (bigI(base_transf + (1:cur_ne-1), :)+ bigI(base_transf + (2:cur_ne), :))/2; bigI(base_transf+cur_ne, :)]; 
            flctr = bigI(base_transf + (1:cur_np), :); 
            
            % find modified polyline itersections with mesh edges
            [ise, isp] = intersect_with_edges(V, F, modified_pg);  

            % find related mesh vertices
            [pidx, ~] = get_closest_points(isp, V); 

            % remove vertices already associated to polyline endpoints
            sel = ~ismember(pidx, flidx); 
            pidx = pidx(sel); ise = ise(sel); isp = isp(sel, :); 
            
            % arrange by edge order
            [cur_bvpl, I] = sortrows([(0.5:cur_np)', flidx', flctr; ise, pidx', bigI(base_transf+ise, :)], 2); 
            bvpg = [bvpg; cur_bvpl(:, 2)]; 
            bcpg = [bcpg; cur_bvpl(:, 3:end)]; 

            % compute projections of mesh points to modified_pg edges
            edge_vectors = (modified_pg(ise+1, :)-modified_pg(ise, :)); 
            edge_vectors = edge_vectors./dot(edge_vectors,edge_vectors, 2); 
            
            % compute the direction vector of weights
            diffI = diff(bigI(base_transf + (1:cur_ne), :)); 
            
            proj = min(max(0, dot(isp-modified_pg(ise, :), edge_vectors)), 1); 
            bigI(base_transf + (1:cur_ne-1), :) + diag(proj)*diffI; 
            
            base_transf = base_transf + cur_np; 
        else
            bvpg = [bvpg; flidx]; 
            bcpg = [bcpg; bigI(base_transf+1, :)]; 
            base_transf = base_transf + 1; 
        end
    end
end

end