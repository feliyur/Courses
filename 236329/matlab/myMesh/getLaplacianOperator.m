function [ laplacian ] = getLaplacianOperator( divergence , gradient)
    laplacian = -divergence*gradient;
end



