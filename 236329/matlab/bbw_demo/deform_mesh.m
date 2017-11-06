function deform_mesh(V,F,C,W,points_and_cages,BE,CE)

  show_weight_visualization = true;
  num_of_points_and_cages = numel(points_and_cages);
  num_of_bones = size(BE,1);


  new_C = [];
  R = zeros(num_of_points_and_cages,1);

  % Set up figure with enough subplots for any additional visualizations
  % clear current figure
  clf
  number_of_subplots = 1;
  current_subplot = 1;
  if(show_weight_visualization)
    number_of_subplots = number_of_subplots +1;
  end
  if(number_of_subplots>1)
    subplot(1,number_of_subplots,1);
  end

  % plot the original mesh
  tsh = trisurf(F,V(:,1),V(:,2),zeros(size(V,1),1), 'FaceColor','interp');
  % 2D view
  view(2); 
  axis equal
  axis manual
  % plot bones
  hold on;
  %plot(V(:,1),V(:,2),'bo','MarkerFaceColor','b'); %david
  if(num_of_bones > 0)
    % plot thick lines for bones (outline of lines)
    ind_t1 = BE(:,1);
    ind_t2 = BE(:,2);
    
    t11 = C(ind_t1,1);        
    t21 = C(ind_t2,1);
    t12 = C(ind_t1,2);
    t22 = C(ind_t2,2);
    
    vec1 = [t11 t21]';
    vec2 = [t12 t22]';
    
    B_plot_outer = plot( vec1, vec2, '-k', 'LineWidth',5);
    % plot thin lines for bones (innerline of lines)
    B_plot_inner = plot(vec1, vec2, '-b', 'LineWidth',2);
  end

  if(size(CE,1) > 0)
    ce_1 = CE(:,1);
    ce_2 = CE(:,2);
    
    p_ce_1 = points_and_cages(ce_1);
    p_ce_2 = points_and_cages(ce_2);
    
    c11 = C(p_ce_1,1);
    c21 = C(p_ce_2,1);
    c12 = C(p_ce_1,2);
    c22 = C(p_ce_2,2);
    
    cage1 = [c11 c21]';
    cage2 = [c12 c22]';
      
      
    % plot lines for cage edges
    CE_plot_outer = plot(cage1, cage2, '-k', 'LineWidth',5);
    CE_plot_inner = plot(cage1, cage2, '-', 'Color', [1 1 0.2], 'LineWidth',2);
  end
  % plot the control points (use 3D plot and fake a depth offset by pushing
  % control points up in z-direction)
  C_plot = scatter3( ...
    C(:,1),C(:,2),0.1+0*C(:,1), ... 
    'o','MarkerFaceColor',[0.9 0.8 0.1], 'MarkerEdgeColor','k',...
    'LineWidth',2,'SizeData',100, ...
    'ButtonDownFcn',@oncontrolsdown);
  hold off;

  % set up weight visualization plot
  if(show_weight_visualization)
    current_subplot = current_subplot + 1;
    subplot(1,number_of_subplots,current_subplot);
    hold on;
    % plot the original mesh
    wvsh = ...
      trisurf(F,V(:,1),V(:,2),zeros(size(V,1),1), 'FaceColor','interp');
    view(2);
    axis equal
    axis manual
    hold off;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Set up interaction variables
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % keep track of window xmin, xmax, ymin, ymax
  win_min = min([C(:,1:2); V(:,1:2)]);
  win_max = max([C(:,1:2); V(:,1:2)]);
  % keep track of down position
  down_pos = [];
  % keep track of last two drag positions
  drag_pos = [];
  last_drag_pos = [];
  % keep track of mesh vertices at mouse down
  down_V = [];
  % keep track of index of selected control point
  ci = [];
  % type of click ('left','right')
  down_type  = '';

  if(show_weight_visualization)
    fprintf(['\nCLICK a control point to visualize its corresponding ' ...
      'weights on the mesh.\n']);
  end
  fprintf( ...
    ['DRAG a control point to deform the mesh.\n' ...
    'RIGHT CLICK DRAG a control point to rotate point handles.\n\n']);

  return

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Callback functions for keyboard and mouse
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Callback for mouse down on control points
  function oncontrolsdown(src,ev)
    % get current mouse position, and remember old one
    down_pos=get(gca,'currentpoint');
    down_pos=[down_pos(1,1,1) down_pos(1,2,1)];
    last_drag_pos=down_pos;
    drag_pos=down_pos;
    % keep track of control point positions at mouse down
    new_C = [get(C_plot,'XData')' get(C_plot,'YData')'];
    % get index of closest control point
    [minD,ci] =  ...
      min(sum((new_C(:,1:2) - ...
      repmat(down_pos,size(new_C,1),1)).^2,2));
    % keep track of mesh vertices at mouse down
    down_V = get(tsh,'Vertices');
    down_V = down_V(:,1:2);

    % tell window that drag and up events should be handled by controls
    set(gcf,'windowbuttonmotionfcn',@oncontrolsdrag)
    set(gcf,'windowbuttonupfcn',@oncontrolsup)
    set(gcf,'KeyPressFcn',@onkeypress)
    if(strcmp('normal',get(gcf,'SelectionType')))
      % left-click
      down_type = 'left';
    else
      % other (right) click
      down_type = 'right';
    end

    % try to find ci in list of point handles
    [found, iP] = ismember(ci,points_and_cages);
    if(found)
      % set color of mesh plot to weights of selected
      %set(tsh,'CData',W(:,iP));
      % change weights in weight visualization
      if(show_weight_visualization)
        set(wvsh,'CData',W(:,iP));
      end
    end

  end

  % Callback for mouse drag on control points
  function oncontrolsdrag(src,ev)
    % keep last drag position
    last_drag_pos=drag_pos;
    % get current mouse position
     drag_pos=get(gca,'currentpoint');
     drag_pos=[drag_pos(1,1,1) drag_pos(1,2,1)];

    if(strcmp('left',down_type))
      % move selected control point by drag offset
      new_C(ci,:) = new_C(ci,:) + drag_pos-last_drag_pos;
    else
      [found, iP] = ismember(ci,points_and_cages);
      if(found)
        R(iP) = R(iP) + 2*pi*(drag_pos(1)-last_drag_pos(1))/100;
      end
    end
    update_positions();
  end

  function update_positions()
    set(C_plot,'XData',new_C(:,1));
    set(C_plot,'YData',new_C(:,2));    
    
    if(num_of_bones > 0)
        BE_1 = BE(:,1);
        BE_2 = BE(:,2);
        new_C_BE_1_1 = new_C(BE_1,1);
        new_C_BE_2_1 = new_C(BE_2,1);
        new_C_BE_1_2 = new_C(BE_1,2);
        new_C_BE_2_2 = new_C(BE_2,2);         
      set(B_plot_outer,{'XData'}, num2cell([new_C_BE_1_1 new_C_BE_2_1],2));
      set(B_plot_outer,{'YData'}, num2cell([new_C_BE_1_2 new_C_BE_2_2],2));
      set(B_plot_inner,{'XData'}, num2cell([new_C_BE_1_1 new_C_BE_2_1],2));
      set(B_plot_inner,{'YData'}, num2cell([new_C_BE_1_2 new_C_BE_2_2],2));
    end
    % update cage edge plots
    if(size(CE,1)>0)
        CE_1 = CE(:,1);
        CE_2 = CE(:,2);
        point_and_cages_1 = points_and_cages(CE_1);
        point_and_cages_2 = points_and_cages(CE_2);
        new_C_point_and_cages_1_1 = new_C(point_and_cages_1,1);
        new_C_point_and_cages_1_2 = new_C(point_and_cages_1,2);
        new_C_point_and_cages_2_1 = new_C(point_and_cages_2,1);
        new_C_point_and_cages_2_2 = new_C(point_and_cages_2,2);        
      set(CE_plot_outer,{'XData'}, num2cell([new_C_point_and_cages_1_1 new_C_point_and_cages_2_1],2));
      set(CE_plot_outer,{'YData'}, num2cell([new_C_point_and_cages_1_2 new_C_point_and_cages_2_2],2));
      set(CE_plot_inner,{'XData'}, num2cell([new_C_point_and_cages_1_1 new_C_point_and_cages_2_1],2));
      set(CE_plot_inner,{'YData'}, num2cell([new_C_point_and_cages_1_2 new_C_point_and_cages_2_2],2));
    end
    % update mesh positions


      % get transformations stored at each point and bone handle
      %TR = skinning_transformations(C,points_and_cages,BE,new_C,R);
      TR = get_transformations(C,points_and_cages,BE,new_C,R);


      % linear blend skinning
      new_V = compute_new_vertices(V(:,1:2),TR,W);


    % update mesh positions
    hold(gca, 'on'); 
    %plot(gca, new_V(:,1),new_V(:,2),'ro','MarkerFaceColor','r'); %david
    axis(gca, 'equal'); 
    set(tsh,'Vertices',new_V(:,1:2));
  end

  % Callback for mouse release of control points
  function oncontrolsup(src,ev)
    % Tell window to handle drag and up events itself
    set(gcf,'windowbuttonmotionfcn','');
    set(gcf,'windowbuttonupfcn','');
    cur_V = get(tsh,'Vertices');
    cur_V = cur_V(:,1:2);

    % scale window to fit
    win_min = min([win_min; cur_V]);
    win_max = max([win_max; cur_V]);
    axis(reshape([win_min;win_max],1,2*size(cur_V,2)))
  end

  function onkeypress(src,ev)
    if(strcmp(ev.Character,'r'))
      new_C = C;
      R = zeros(num_of_points_and_cages,1);
      update_positions();
    elseif(strcmp(ev.Character,'u'))
      update_positions();
    end
  end

end
