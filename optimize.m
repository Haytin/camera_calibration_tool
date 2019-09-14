function[K_opti, Rt_opti, k_final, p_final] = optimize(K, Rt, object, img)
%OPTIMIZE: optimize calibration results

options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt','Display','iter');
% get zyx euler angles
[phi, theta, psi] = zyx_euler(Rt(:,1:3));
roh = [phi; theta; psi];
k_initial = [0 0];
p_initial = [0 0];

params = [K(1,1) K(1,3) K(2,2) K(2,3) roh' Rt(1,4) Rt(2,4) Rt(3,4) k_initial p_initial];

x = lsqnonlin(@costfun, params ,[],[], options, img, object);
K_opti = [x(1) 0 x(2); 0 x(3) x(4); 0 0 1];
R = to_rotation(x(5:7));
Rt_opti = [R x(8:10)'];
k_final = x(11:12);   
p_final = x(13:14);
