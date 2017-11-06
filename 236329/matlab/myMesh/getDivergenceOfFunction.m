function [ divergenceOfFunction ] = getDivergenceOfFunction( divergenceOperator, vector_field )
    divergenceOfFunction = divergenceOperator * vector_field;
    divergenceOfFunction = divergenceOfFunction';
end

