function [ gradientOfFunctionMatrix ] = getGradientOfFunction( gradient, vector_values )
    gradientOfFunctionVector = gradient * vector_values;
    %if (size(vector_values,2) == 3)
    gradientOfFunctionMatrix = reshape(gradientOfFunctionVector, length(gradientOfFunctionVector)/3, 3);    
    %end    
    gradientOfFunctionMatrix = gradientOfFunctionMatrix';
end

