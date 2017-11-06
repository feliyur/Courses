function alligator_animation(V,F,C,W,points_and_cages,BE,CE)    

    draw_bones = true;
    draw_cages = false;
    draw_points = true;

  num_of_bones = size(BE,1);
  num_of_cages_points = size(CE,1);

  current_vertices = V;
  
  % Set up figure with enough subplots for any additional visualizations
  % clear current figure
  clf
  number_of_subplots = 1;
  if(number_of_subplots>1)
    subplot(1,number_of_subplots,1);
  end
  
  identity_matrix = [eye(2) [0 ; 0]];
  TR = repmat(identity_matrix,[1,1,5]);
  final_transform = TR;
  initial_transform = TR;
  diff_transform = TR;
  diff_transform_each_iteration = TR;
  current_diff = TR;

    num_of_iterations = 50;
    num_of_seconds = 1/20;

    

%     final_transform(:,:,1) = [1 0 -8 ; 0 1 10];
%     final_transform(:,:,2) = [1 0 0 ; 0 1 10];
%     final_transform(:,:,3) = [1 0 10 ; 0 1 25];
%     final_transform(:,:,4) = [1 0 10 ; 0 1 -5];
%     final_transform(:,:,5) = [1 0 -8 ; 0 1 -5];
%     final_transform(:,:,6) = [1 0 0 ; 0 1 -num_of_iterations];
%     final_transform(:,:,7) = [1 0 0 ; 0 1 num_of_iterations];
%     final_transform(:,:,8) = [0.8995    0.2839  -17.2482 ; -0.2727    0.9587   61.9745];
%     final_transform(:,:,9) = [0.9695   -0.1000   16.3369 ; 0.0927    0.9948  -19.7116];     
%     num_of_transformations = 10;

    final_transform(:,:,1) = [1 0 0 ; 0 1 -num_of_iterations];
    final_transform(:,:,2) = [1 0 0 ; 0 1 num_of_iterations];
    final_transform(:,:,3) = [0.8995    0.2839  -17.2482 ; -0.2727    0.9587   61.9745];
    final_transform(:,:,4) = [0.9695   -0.1000   16.3369 ; 0.0927    0.9948  -19.7116];    
    num_of_transformations = 5;
    
    
    [min_indexes, new_control_points] = get_closest_points(C, current_vertices);
    new_C = current_vertices(min_indexes,:);
    weights_of_controls = W(min_indexes,:);
     
    for j=1:3
        
        for count=1:1:num_of_iterations
            hold off;
            trisurf(F,current_vertices(:,1),current_vertices(:,2),zeros(size(V,1),1), 'FaceColor','interp'); view(2); axis equal; axis manual;
            
            current_controls = compute_new_vertices(new_C,TR,weights_of_controls);                          
            hold on;              
            draw_handles;
                                         
            for index_transfrom = 1:num_of_transformations
                diff_transform(:,:,index_transfrom) = final_transform(:,:,index_transfrom) - initial_transform(:,:,index_transfrom);
                diff_transform_each_iteration(:,:,index_transfrom) = diff_transform(:,:,index_transfrom)/num_of_iterations;
               %TR(:,:,6) = [1,0,0;0,1,-count]; 
               current_diff(:,:,index_transfrom) = diff_transform_each_iteration(:,:,index_transfrom)*count;
               TR(:,:,index_transfrom) = initial_transform(:,:,index_transfrom) + current_diff(:,:,index_transfrom);               
            end            
            current_vertices = compute_new_vertices(V,TR,W);
            pause(num_of_seconds);             
        end


        for count=num_of_iterations-1:-1:1
            hold off;
            trisurf(F,current_vertices(:,1),current_vertices(:,2),zeros(size(V,1),1), 'FaceColor','interp'); view(2); axis equal; axis manual;
            
            current_controls = compute_new_vertices(new_C,TR,weights_of_controls);                          
            hold on;              
            draw_handles;
            
            for index_transfrom = 1:num_of_transformations
                diff_transform(:,:,index_transfrom) = final_transform(:,:,index_transfrom) - initial_transform(:,:,index_transfrom);
                diff_transform_each_iteration(:,:,index_transfrom) = diff_transform(:,:,index_transfrom)/num_of_iterations;
               %TR(:,:,6) = [1,0,0;0,1,-count]; 
               current_diff(:,:,index_transfrom) = diff_transform_each_iteration(:,:,index_transfrom)*count;
               TR(:,:,index_transfrom) = initial_transform(:,:,index_transfrom) + current_diff(:,:,index_transfrom);               
            end            
            current_vertices = compute_new_vertices(V,TR,W);
            pause(num_of_seconds);             
        end
    end
    
    function draw_handles
      if (draw_bones)
          if(num_of_bones > 0)
            ind_t1 = BE(:,1);
            ind_t2 = BE(:,2);                                              
            t11 = current_controls(ind_t1,1);        
            t21 = current_controls(ind_t2,1);
            t12 = current_controls(ind_t1,2);
            t22 = current_controls(ind_t2,2);
            vec1 = [t11 t21]';
            vec2 = [t12 t22]';                                               
            plot( vec1, vec2, '-k', 'LineWidth',5);
            plot(vec1, vec2, '-b', 'LineWidth',2);               
          end
      end

      if (draw_cages)
          if(num_of_cages_points > 0)
            ce_1 = CE(:,1);
            ce_2 = CE(:,2);

            p_ce_1 = points_and_cages(ce_1);
            p_ce_2 = points_and_cages(ce_2);

            c11 = current_controls(p_ce_1,1);
            c21 = current_controls(p_ce_2,1);
            c12 = current_controls(p_ce_1,2);
            c22 = current_controls(p_ce_2,2);

            cage1 = [c11 c21]';
            cage2 = [c12 c22]';

            plot(cage1, cage2, '-k', 'LineWidth',5);
            plot(cage1, cage2, '-', 'Color', [1 1 0.2], 'LineWidth',2);
          end
      end

      if (draw_points)
          scatter(current_controls(:,1),current_controls(:,2), ... 
            'o','MarkerFaceColor',[0.9 0.8 0.1], 'MarkerEdgeColor','k',...
            'LineWidth',2,'SizeData',50);
      end        
    end
end
