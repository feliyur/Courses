function W = biharmonic_bounded(mesh, bv, bc, cv, pou)
%% 
% W = biharmonic_bounded(V, F, hp, he)
%
% Computes weights matrix from Bounded biharmonic weights for real-time deformation,
% Jackobson, Baran, Popovic, Sorkine
%
% mesh - mesh to deform
% bv - indexes of "boundary" vertices
% bc - values for vertices (boundary conditions) |bv|x|T|
% cv - vertices constrained to move together

if nargin < 5
    pou = true; 
end

if size(bv, 2) > 1
    bv = bv'; 
    warning('Looks like bv was a row vector. Working on transpose'); 
end


V = mesh.vertices; 
% F = mesh.faces; 

m = size(bc, 2); 
n = length(V); 
nv = size(bv, 1); 

W = zeros(n, m); 

M = spdiags(mesh.vertice_areas', 0, n, n);
L = -M*mesh.laplacian; 

% % model: w'Hw 
% % where H = Q + S
% % where Q = L*M^-1*L, S = G'*R*M*G
% for ii=1:m % iterate over transformations
%     % W(:, ii) = 
% %     quadprog
%     Q = 
% end
    
    bigI = eye(n); 
    
if pou
    
%     bigI = speye(n); 
    
     param = optimset( ...
                    'TolFun',1e-16, ...
                    'Algorithm','interior-point-convex', ...
                    ... % 'Algorithm','active-set', ...
                    'MaxIter', 1000, ...
                    'Display','off');

    Qi = L*(M\L);
    
    % construct Q
    Q = sparse(n*m, n*m); 
    
    
    for ii=1:m
        sidx = (ii-1)*n+1;  % start index
        Q(sidx:(sidx+n-1), sidx:(sidx+n-1)) = Qi; 
    end

    % W is the variable in our optimization. it is of size n*m. First appear
    % the weights of all vertices for the first transformation, the for the
    % second etc. 
    
    Aeq = sparse(nv*m+n, m*n);  % "+n" for partition of unity constraint
    beq = ones(size(Aeq, 1), 1); 
%     Aeq = sparse((m+1)*n, m*n); 
    
    % boundary conditions constraints
    for ii=1:m        
%         Aeq(sub2ind(size(Aeq), (1:nc)', bv)) = 1; 
        Aeq(nv*(ii-1)+(1:nv)', n*(ii-1)+1:n*ii) = bigI(bv, :); 
%         Aeq(sub2ind(size(Aeq), m*(ii-1)+(1:m)', n*(ii-1)+bv)) = 1; 
        beq((1+nv*(ii-1)):nv*ii) = bc(:, ii); 
    end
        
    % partition of unity constraints
    for ii=1:n
        Aeq(nv*m+ii, ii:n:end) = 1; 
    end    
%     beq(m*nc+1:end) = 1; 
        
    H = Q; 
    
%     W = quadprog(Q,zeros(size(Q, 1), 1),[],[],Aeq,beq,lb,ub,x0,options); 
    W = quadprog(Q,zeros(n*m, 1),[],[],Aeq,beq, zeros(n*m, 1), ones(n*m, 1), [], param); 
    W = reshape(W, n, m); 
else
    
    param = optimset( ...
                    'TolFun',1e-16, ...
                    'Algorithm','interior-point-convex', ...
                    ... % 'Algorithm','active-set', ...
                    'MaxIter', 1000, ...
                    'Display','off');
                
    for ii=1:m        
        Qi = L*(M\L);
        Aeq = bigI(bv, :); 
        beq = bc(:, ii); 
        w = quadprog(Qi,zeros(n, 1),[],[],Aeq,beq,zeros(n, 1),ones(n, 1),[],param);
        W(:, ii) = w; 
    end
    
    W = W./repmat(sum(W,2), 1, m); 
        
%     for ii=1:m
%         w = []; 
%         
%         W(:, ii) = w; 
%     end
    
%     error('Computation of weights without partition of unity not implemented');

end


