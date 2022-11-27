function [vgj,vgj0] = conv3p(Vgm,wg,thetag,Ed,fpwm,arm4,mi,t)
%% Sinais

% Fonte triangular:
vtri = @(t) (Ed/2)*sawtooth(2*pi*fpwm*t, 1/2);

% Sinal trifásico senoidal:
v3p = @(t, theta) [
    cos(wg*t + theta),...
    cos(wg*t - 2*pi/3 + theta),...
    cos(wg*t + 2*pi/3 + theta)
];

%% Cálculo da saída
tpwm = (1/fpwm)*floor(t*fpwm);
vgjref  = Vgm*v3p(tpwm, thetag);

vn0ref_max =  Ed/2 - max([vgjref, zeros(length(t),1)], [], 2);
vn0ref_min = -Ed/2 - min([vgjref, zeros(length(t),1)], [], 2);

% Tensão de referência entre neutros:
vn0ref = mi*vn0ref_max + (1-mi)*vn0ref_min;

vgj0ref = vgjref + (arm4 > 0)*vn0ref;  % Tensão de polo de referência

q = (vgj0ref >= vtri(t));   % estado das chaves
vgj0 = (2*q - 1)*(Ed/2);    % tensão de polo
vn0 = sum(vgj0,2)/3;        % tensão de neutro

vgj = vgj0 - vn0; % tensão de fase

end

