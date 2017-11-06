function [ise, isp] = intersect_with_edges(V, F, pl)
%%
% intersect_with_edges(V, F, pl)
% 
% F - |F|xn 

nf = size(F, 1); 
ne = size(F, 2); 

E = zeros(nf*ne, 2); 
for ii=1:size(F, 2)
    dd = (ii-1)*nf+1; 
    sf = circshift(F, 1-ii, 2); 
    E(dd:dd+nf-1, :) = sf(:, 1:2);  
end
% E = [F(:, 1), F(: ,2); F(:, 2), F(:, 3)]; 

E_start = V(E(:, 1), :); 
E_end = V(E(:, 2), :); 
padd = NaN(size(E_start, 1), 1); 

Ex = [E_start(:, 1), E_end(:, 1), padd]'; Ex = Ex(:); 
Ey = [E_start(:, 2), E_end(:, 2), padd]'; Ey = Ey(:); 
% Ez = ones(size(Ey, 1), 1); 
% Ez = [E_start(:, 3), E_end(:, 3), padd]'; Ez = Ez(:); 
[XI,YI,II] = polyxpoly(Ex, Ey, pl(:, 1), pl(:, 2)); 

ise = II(:, 2); 
isp = [XI, YI]; 
