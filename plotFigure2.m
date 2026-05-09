clear; close all; clc;
disp("STARTED")

c=3e8;
fc=3e9;
lambda=c/fc;

theta_i = deg2rad(30);

k0 = 2*pi/lambda;

a = [0.2 ,1 ,10]*lambda;
b = [0.2 ,1 ,10]*lambda;

theta_s = deg2rad(0:0.00001:90);

S = zeros(length(theta_s),length(a));

for sizes = 1:length(a)
    
    for n = 1:length(theta_s)
        
        y = ((k0*b(sizes))/2) * (sin(theta_s(n)) - sin(theta_i));
        Y = (sin(y)/y)^2;
        
        if isnan(Y)
            Y = 1;
        end
        
        S(n,sizes) = ((a(sizes)*b(sizes))^2/(lambda^2)) * ((cos(theta_i)^2)) * Y;
        
    end
    
end

disp("REACHED PLOT")

theta_s = rad2deg(theta_s);

figure;
hold on; box on;

S_dB = pow2db(S);

plot(theta_s,S_dB(:,3),'r-.','LineWidth',2);
plot(theta_s,S_dB(:,2),'b--','LineWidth',2);
plot(theta_s,S_dB(:,1),'k-','LineWidth',2);

ylabel('Normalized $ S(r,\theta_s) $ [dB]','Interpreter','Latex');
xlabel('Observation angle $\theta_s$ [degrees]','Interpreter','Latex');

legend('$a=b=10\lambda$','$a=b=\lambda$','$a=b=\lambda/5$', ...
       'Location','NorthEast','Interpreter','Latex');

set(gca,'fontsize',18);

xlim([0 90]);
ylim([-60 20]);