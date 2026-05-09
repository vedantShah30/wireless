clear; close all; clc;

c = 3e8;
fc = 3e9;
lambda = c/fc;

theta_i = deg2rad(30);

k0 = 2*pi/lambda;

theta_r = deg2rad(60);

a = [0.5,10,50]*lambda;
b = [0.5,10,50]*lambda;

theta_s = deg2rad(-90:0.00001:90);

dt = 50;
dr = 25;

Gt = db2pow(5);
Gr = db2pow(5);

beta_IRS = zeros(length(theta_s),length(a));

for sizes = 1:length(a)
    
    for n = 1:length(theta_s)
       
        y = ((k0*b(sizes))/2) * (sin(theta_s(n)) - sin(theta_r));
        Y = (sin(y)/y)^2;
        
        if isnan(Y)
            Y = 1;
        end
        
        beta_IRS(n,sizes) = (Gt*Gr/((4*pi)^2)) * ...
                            ((a(sizes)*b(sizes))/(dt*dr))^2 * ...
                            (cos(theta_i)^2) * Y;
    end
    
end

theta_s = rad2deg(theta_s);

figure;

pathloss_dB = pow2db(beta_IRS);

hold on; box on;

plot(theta_s,pathloss_dB(:,3),'r-','LineWidth',2);
plot(theta_s,pathloss_dB(:,2),'b--','LineWidth',2);
plot(theta_s,pathloss_dB(:,1),'k-.','LineWidth',2);

ylabel('Pathloss $\beta_\mathrm{IRS}$ [dB]','Interpreter','Latex')
xlabel('Observation angle $\theta_s$ [degrees]','Interpreter','Latex');

legend('$a=b=50\lambda$', '$a=b=10\lambda$', '$a=b= \lambda/2$', ...
       'Interpreter','Latex','Location','NorthWest');

set(gca,'fontsize',18);

ylim([-200 -45])
xlim([-90 90])