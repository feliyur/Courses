function write_off_file(filepath, vertices,faces, num_lines, comments)

if nargin<5
    comments=[]; 
end

if nargin<4 || isempty(num_lines)
    num_lines = 0; 
end

fileID = fopen(plindp(filepath),'w');
if( fileID == -1 )
    error('Can''t open the file for writing.');
end

% OFF header
fprintf(fileID, 'OFF\n'); 

% Add comments
if ~isempty(comments)
    comments = strsplit(comments, char(10));
    for c=comments
        fprintf(fileID, '# %s\n', c{1}); 
    end
end

% % A separating linefeed
% fprintf(fileID, '\n'); 

% Write vertices
fprintf(fileID, '%d %d %d\n', int32(size(vertices, 2)), int32(size(faces, 2)), int32(num_lines)); 
fprintf(fileID, '%g %g %g\n', vertices); 

% Write faces
num_pts = sum(double(faces~=-1)); 
fprintf(fileID, '%d %d %d %d\n', int32([num_pts; faces-1])); 

fclose(fileID); 
