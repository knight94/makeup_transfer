function beta_arr = beta_gen(iml,masks)

    [x,y] = size(iml);
    mask_facecut = masks{1};
    beta_arr = zeros(size(iml));
    
    % lstx = [];
    % lsty = [];
    
    % do it for eyebrow separately
    
    
    for i = 1:x
        for j = 1:y
            if(mask_facecut(i,j)>0)
                beta_arr(i,j) = 1; 
    %         else
    %             beta_arr(i,j) = 0;
    %             lstx = [lstx i];
    %             lsty = [lsty j];
            end
        end 
    end
    
    % sigma = min(x,y) / 25;
    % 
    % h = waitbar(0,'beta is getting calculated...');
    % set(h,'Name','beta progress');
    % 
    % for l = 1:length(lstx)
    %     for m = 1:length(lsty)
    %         k_q = 1; % other skin area 
    %         p = iml(lstx(l), lsty(m));
    %         t_max = 0;
    %         for i = 1:x
    %              for j = 1:y  
    %                  q = iml(i,j);
    %                  to_max = k_q * exp( - (q-p)^2 / (2*(sigma)^2));
    %                  if(to_max > t_max)
    %                      t_max = to_max;
    %                  end 
    %              end
    %         end
    %         beta_arr(lstx(l),lsty(m)) = 1 - t_max;
    %     end 
    %     waitbar(l/length(lstx));
    % end
    % % Close waitbar.
    % close(h);

    end 