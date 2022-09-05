function [y] = jonswapIEE(f,Tp,Hs)


alfa=0.0081; %parameter alfa
beta=1.25; %parameter beta
gamma=3.3; %parameter gamma
g=9.81; %[m/s2]

xa = f*Tp;

sigma       = (xa < 1) * 0.07 + (xa >= 1) * 0.09;
% 
% fac1        = 0.3125*Hs^2*Tp*xa .^ (-5);
% fac2        = exp (-beta*(xa.^(-4)));
% fac3a  = (1 - 0.287*log(gamma))*(gamma * ones(size(xa)));
% fac3b   = (exp(-0.5.*((xa -1)./sigma).^2));
% 
% y = fac1 .* fac2 .* (fac3a.^fac3b);

% alpha  = 0.0624 / (0.23 + 0.0336*gamma - 0.185/(1.9 + gamma));
% % alpha = 0.0081;
% % fac1 = alpha*g^2*(2*pi)^-4*f.^-5;
% fac1        = 2*pi*alpha*Hs^2.*(xa .^ (-4))./f;
% fac2        = exp (-beta*(xa.^(-4)));
% 
% fac3a  = (gamma * ones(size(xa)));
% fac3b   = (exp(-0.5.*((xa -1)./sigma).^2));

alpha  =alfa;
fac1        = alpha*g^2*(2*pi)^-4*f.^(-5);
fac2        = exp (-beta*(xa.^(-4)));

fac3a  = (gamma * ones(size(xa)));
fac3b   = (exp(-0.5.*((xa -1)./sigma).^2));



y = fac1 .* fac2 .* (fac3a.^fac3b);

if ~isempty(Hs)
    y = (y/trapz(f,y))*Hs^2/16; 
end


end



