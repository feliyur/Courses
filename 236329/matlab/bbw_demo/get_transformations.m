function transformation_of_all_handles = get_transformations(all_handles,points_and_cages,BE,new_C,rotation_inputs)
  dim = size(all_handles,2);  
  points_and_cages = points_and_cages';
  num_of_points_and_cages = numel(points_and_cages);
  num_of_bone_controls = size(BE,1);
  

  num_of_handles = num_of_points_and_cages+num_of_bone_controls;

  rotation_matrices = repmat(eye(dim,dim),[1,1,num_of_handles]);
  S = repmat(eye(dim,dim),[1,1,num_of_handles]);


  rotation_angles = reshape(rotation_inputs,num_of_points_and_cages,1);
  rotation_matrices(1,1,1:num_of_points_and_cages) = cos(rotation_angles);
  rotation_matrices(1,2,1:num_of_points_and_cages) = -sin(rotation_angles);
  rotation_matrices(2,1,1:num_of_points_and_cages) = sin(rotation_angles);
  rotation_matrices(2,2,1:num_of_points_and_cages) = cos(rotation_angles);



  % insert bone rotations (and scales)
  if(num_of_bone_controls > 0)
    % edge vector at rest state
    BE_2 = BE(:,2);
    BE_1 = BE(:,1);
    c2 = all_handles(BE_2,:);
    c1 = all_handles(BE_1,:);
    rest = c2 - c1;
    rest_square = rest.^2;
    sum_rest_square = sum(rest_square,2);
    rest_norms = sqrt(sum_rest_square);
    % edge vector at pose
    new_c2 = new_C(BE_2,:);
    new_c1 = new_C(BE_1,:);
    pose = new_c2 - new_c1;
    pose_square = pose.^2;
    sum_pose_square = sum(pose_square,2);
    pose_norms = sqrt(sum_pose_square);
    

    % first take care of scaling anisotropically along bone
    % rotate so that rest vector is x-axis
    bones_transformations = zeros([dim , dim , num_of_bone_controls]);
    % signed angle that takes rest to x-axis
    rest_1 = rest(:,1);
    rest_2 = rest(:,2);
    
    
    angle_bones = -atan2(rest_2,rest_1);
    bones_transformations(1,1,:) =  cos(angle_bones);
    bones_transformations(1,2,:) = -sin(angle_bones);
    bones_transformations(2,1,:) =  sin(angle_bones);
    bones_transformations(2,2,:) =  cos(angle_bones);


    % store rotation in scale spot
    first_index_of_bones_transformations = num_of_points_and_cages+1;
    indexes_of_bones_transformations = first_index_of_bones_transformations:num_of_handles;
    S(:,:,indexes_of_bones_transformations) = bones_transformations;
    % scale along x-axis
    bones_transformations_first_line = bones_transformations(1,:,:);
    ratio_bones = pose_norms./rest_norms;
    repeat_transformations = [1 dim 1];
    repeat_matrixes = repmat(ratio_bones,repeat_transformations);
    permute_bones_transformations = permute(repeat_matrixes,[3 2 1]);
    S(1,:,indexes_of_bones_transformations) = bones_transformations_first_line .* permute_bones_transformations;
    % unrotate each scale
    for bone_index = 1:num_of_bone_controls
        bone_current_transformation = bones_transformations(:,:,bone_index);
        S_current_transformation = S(:,:,num_of_points_and_cages+bone_index);
        S_new_matrix = bone_current_transformation \ S_current_transformation;
        S(:,:,num_of_points_and_cages+bone_index) = S_new_matrix;
    end



    pose_2 = pose(:,2);
    pose_1 = pose(:,1);
    angles_new = atan2(pose_2,pose_1);
    angles_old = atan2(rest_2,rest_1);
    angles_differences = angles_new - angles_old;
    rotation_matrices(1,1,indexes_of_bones_transformations) =  cos(angles_differences);
    rotation_matrices(1,2,indexes_of_bones_transformations) = -sin(angles_differences);
    rotation_matrices(2,1,indexes_of_bones_transformations) =  sin(angles_differences);
    rotation_matrices(2,2,indexes_of_bones_transformations) =  cos(angles_differences);
  end

  % add to translation, differnce in origin and rotation/scale applied to 
  % apply scale before rotation
  RS = zeros(dim*num_of_handles,dim);
  for bone_index = 1:num_of_handles
    RS((1+dim*(bone_index-1)):(dim*bone_index),1:dim) = rotation_matrices(1:dim,1:dim,bone_index) * S(:,:,bone_index);
  end
  % origin
  T_matrices = zeros(num_of_handles,dim);
  matrices_before_changes = zeros(num_of_handles,dim);
  points_and_cages_coordinates_before_changes = all_handles(points_and_cages,:);
  points_and_cages_coordinates_after_changes = new_C(points_and_cages,:);
  points_and_cages_translations = points_and_cages_coordinates_after_changes - points_and_cages_coordinates_before_changes;
  matrices_before_changes(1:num_of_points_and_cages,:) = points_and_cages_coordinates_before_changes;
  T_matrices(1:num_of_points_and_cages,:) = points_and_cages_translations;
  if(num_of_bone_controls > 0)
    bones_start_indexes = BE(:,1);
    bones_coordinates_before_changes = all_handles(bones_start_indexes,:);
    bones_coordinates_after_changes = new_C(bones_start_indexes,:);
    bones_translations = bones_coordinates_after_changes - bones_coordinates_before_changes;
    matrices_before_changes(indexes_of_bones_transformations,:) = bones_coordinates_before_changes;
    T_matrices(indexes_of_bones_transformations,:) = bones_translations;
  end


  num_of_handles_in_all_dimesions = dim*num_of_handles;
  vec_handles_in_all_dimensions = 1:num_of_handles_in_all_dimesions;
  repeated_vec_handles_in_all_dimensions = [vec_handles_in_all_dimensions , vec_handles_in_all_dimensions];

  vec_handles_in_dim_jumps = 1:dim:num_of_handles_in_all_dimesions;
  repeated_handles = [vec_handles_in_dim_jumps ; vec_handles_in_dim_jumps];
  %repeated_handles = repmat(1:dim:num_of_handles_in_all_dimesions,dim,1);
  reshape_repmat_handles = reshape(repeated_handles,1,num_of_handles_in_all_dimesions);
  vec_dimesions_handles_repeated = repmat(reshape_repmat_handles,1,dim);
  repmat_handles2 = repmat(0:(dim-1),num_of_handles_in_all_dimesions,1);
  handles_indexes_for_each_dimension = reshape(repmat_handles2,1,num_of_handles_in_all_dimesions*dim);
  vec_of_handles_indexes = vec_dimesions_handles_repeated + handles_indexes_for_each_dimension;
  RS_single_vector = RS(:);
  temp1 = sparse(repeated_vec_handles_in_all_dimensions,vec_of_handles_indexes,RS_single_vector);
  temp2 = reshape(matrices_before_changes',num_of_handles_in_all_dimesions,1);
  stacktimes_RS_O = reshape(temp1*temp2,dim,num_of_handles)';
    
  translation_matrices = (T_matrices+matrices_before_changes-stacktimes_RS_O);
  transformation_of_all_handles = zeros([dim , dim+1 , num_of_handles]);
  transformation_of_all_handles(:,1:dim,:) = permute(reshape(RS',[dim , dim , num_of_handles]),[2 1 3]);
  translation_column = dim+1;
  permute_translation_matrices = permute(translation_matrices,[2,3,1]);
  transformation_of_all_handles(:,translation_column,:)= permute_translation_matrices;
end
