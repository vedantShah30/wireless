clear; close all; clc;

theta_i = deg2rad(30);

theta_r = deg2rad([30,50,75]);

c = 3e8;
f = 3e9;
lambda = c/f;

k = 2*pi/lambda;

y = lambda*(-8:0.001:8);

phi_r = zeros(length(y),length(theta_r));

for m = 1:length(theta_r)
    
    for n = 1:length(y)
        
        check = mod(k*(-sin(theta_r(m)) + sin(theta_i)) .* (y(n)),2*pi);
        
        if check > pi
            phi_r(n,m) = mod(k*(-sin(theta_r(m)) + sin(theta_i)) .* (y(n)),-pi);
        else
            phi_r(n,m) = mod(k*(-sin(theta_r(m)) + sin(theta_i)) .* (y(n)),pi);
        end
    end
end

figure;
hold on; box on;

plot(y/lambda,rad2deg(phi_r(:,1)),'r-.','LineWidth',2)
plot(y/lambda,rad2deg(phi_r(:,2)),'b--','LineWidth',2)
plot(y/lambda,rad2deg(phi_r(:,3)),'k','LineWidth',2)

xlabel('$y/\lambda$','Interpreter','Latex');
ylabel('Local surface phase $\phi_r (y)$ ','Interpreter','Latex');

legend('$\theta_r =30^\circ $','$\theta_r =50^\circ$','$\theta_r =75^\circ$', ...
       'Location','NorthEast','Interpreter','Latex');

set(gca,'fontsize',18);

xlim([-8 8])
ylim([-185 185])