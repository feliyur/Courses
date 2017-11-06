function [vertices, faces] = read_off_file(filename)

fileID = fopen(plindp(filename),'r');
if( fileID == -1 )
    error('Can''t open the file.');
end

tline = fgets(fileID);
if strcmp(tline(1:3), 'OFF') == 0
    error('The file is not a valid OFF one.');    
    fclose(fileID); 
end

% skip comments
tline = '#'; iscomment=true; 
while(isempty(tline) || iscomment)
    tline = fgets(fileID); % -1 if eof
    tline = strtrim(tline); 
    iscomment = ~isempty(regexp(tline, '^#*', 'once')); 
end 

% tline = fgets(fileID);
[numOfVerticesString,remain] = strtok(tline);
numOfVertices = str2num(numOfVerticesString);
numOfFaces = str2num(strtok(remain));



[verticesColumn,numOfCoordinates] = fscanf(fileID,'%f %f %f', 3*numOfVertices);
if numOfCoordinates ~= 3*numOfVertices
    warning('Problem in reading vertices.');
end
vertices = reshape(verticesColumn, 3, numOfCoordinates/3);


[facesColumn,numOfVerticesIndexes] = fscanf(fileID,'%d %d %d %d\n', 4*numOfFaces);
if numOfVerticesIndexes~=4*numOfFaces
    warning('Problem in reading faces.');
end
facesMatrix = reshape(facesColumn, 4, numOfVerticesIndexes/4);
%remove num of vertices (since we can assume all faces are triangles) and
%add 1 to all indexes since the indexes should start with 1 and not 0

faces = facesMatrix(2:4,:)+1;

% adj=zeros(numOfVertices,numOfVertices,3);
% 
% for i=1:length(faces)
%     index1 = faces(1,i);
%     index2 = faces(2,i);
%     index3 = faces(3,i);
%     
%     adj(index1,index2) = vertices(index2)-vertices(index1);
%     adj(index2,index1) = adj(index1,index2);
%     
%     adj(index2,index3) = vertices(index3)-vertices(index2);
%     adj(index3,index2) = adj(index2,index3);
%     
%     adj(index3,index1) = vertices(index1)-vertices(index3);
%     adj(index1,index3) = adj(index3,index1);
% end


fclose(fileID);
