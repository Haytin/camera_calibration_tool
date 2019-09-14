function[img_undistorted] = undistort_real(real_img, rad_to, tang_to, K_to)


K_inv = inv(K_to);

[x y] = meshgrid(1:size(real_img,2) , 1:size(real_img,2));

x = x(:)';
y = y(:)';
img = real_img(:)';

coords = [x;y;ones(1,length(x))];
coords_n = K_inv*coords;

coords_corr = ones(3,size(coords,2));


r = (coords_n(1,:)).^2 + (coords_n(2,:)).^2;

k1 = rad_to(1);
k2 = rad_to(2);
p1 = tang_to(1);
p2 = tang_to(2);



        coords_corr(1,:) = coords_n(1,:) + coords_n(1,:).*((k1*r + k2*(r).^2))...
                           + p1*(r + 2*coords_n(1,:).^2) + 2*p2*coords_n(1,:).*coords_n(2,:) ;                      
        coords_corr(2,:) = coords_n(2,:) + coords_n(2,:).*((k1*r + k2*(r).^2))...
                           + 2*p1*coords_n(1,:).*coords_n(2,:) + p2*(r + 2*coords_n(2,:).^2) ;               


coords_corr = K_to*coords_corr;
real_img = real_img(:)';
% coords_corr = round(coords_corr);

x_mini = min(coords_corr(1,:));
x_maxi = max(coords_corr(1,:));
y_mini = min(coords_corr(2,:));
y_maxi = max(coords_corr(2,:));

coords_corr(1,:) = coords_corr(1,:) + abs(x_mini)+1;
coords_corr(2,:) = coords_corr(2,:) + abs(y_mini)+1;



[xq yq] = meshgrid(1:x_maxi+5, 1:x_maxi);



img_undistorted = griddata(double(coords_corr(1,:)), double(coords_corr(2,:)), double(real_img), double(xq), double(yq), 'nearest');






           