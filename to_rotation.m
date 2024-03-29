function[R] = to_rotation(roh)

    %  rotation matrix around z-axis
        rot_matrix_z = [cosd(roh(1)) -sind(roh(1)) 0;...
                        sind(roh(1)) cosd(roh(1)) 0;...
                        0 0 1];
 
    % rotation matrix around y-axis     
        rot_matrix_y = [cosd(roh(2)) 0 sind(roh(2));...
                        0 1 0;...
                       -sind(roh(2)) 0 cosd(roh(2))];
                   
    % rotation matrix around x-axis               
        rot_matrix_x = [1 0 0;...
                        0 cosd(roh(3)) -sind(roh(3));...
                        0 sind(roh(3)) cosd(roh(3))]; 
                   
        R =  rot_matrix_z * rot_matrix_y * rot_matrix_x;
 