close all
clear all
clc

%% Máquina de Indução

rs = 0.39;        % Resistência do estator (cíclica)
rr = 1.41;        % Resistência do rotor (cíclica)
ls = 0.094;       % Indutância do estator (cíclica)
lr = 0.094;       % Indutância do rotor (cíclica)
lm = 0.091;       % Indutância mútua (cíclica)
lso = 0.1*ls;
lro = 0.1*lr;
jm = 0.04;        % Constante mecânica
kf = 0.01;        % Constante eletromagnética
p = 2;            % Número de pares de polos
Vf = 0;           % Tensão do enrolamento do rotor

maqInd = maq3p(rs,rr,ls,lr,lm,lso,lro,jm,kf,p,Vf);

%% Fonte trifásica (Aplicada ao estator)
ws = 2*pi*50;       % 50Hz
Vsm = 220*sqrt(2);  % Tensão de pico
v3p = @(t, theta) Vsm*[
    cos(ws*t + theta);
    cos(ws*t - 2*pi/3 + theta);
    cos(ws*t + 2*pi/3 + theta)
];

%% Simulação
h = 1e-4; tmax = 1;
t = (0:h:tmax);

vs123 = v3p(t, 0); cm = 0;
is123 = zeros(3,1); Rg = 100;

% Vetores de saída
is = zeros(3,length(t)); fs = zeros(3,length(t));
Ce = zeros(1,length(t)); Wm = zeros(1,length(t));

for i = 1:length(t)
    if t(i) > tmax/2 % Abertura de fase em t = tmax/2
        vs123(1,i) = vs123(1,i) - Rg*is123(1);
    end
    maqInd = maqInd.stepSim(vs123(:,i),cm,h);
    [is123,fs123,ce,wm] = maqInd.getOutput();

    is(:,i) = is123; fs(:,i) = fs123; Ce(i) = ce; Wm(i) = wm;
end

%% Figura
fig = figure(Position=[200,100,1500,800]);

subplot(2,2,1);
plot(t,is,LineWidth=1); grid on;
xlabel('t(s)'); ylabel('i_s(A)');
title('Correntes estatóricas');

subplot(2,2,3);
plot(t,fs,LineWidth=1); grid on;
xlabel('t(s)'); ylabel('\lambda_s(Wb)');
title('Fluxos estatóricos');

subplot(2,2,2);
plot(t,Ce,LineWidth=1); grid on;
xlabel('t(s)'); ylabel('C_e(N.m)');
title('Conjugado eletromagnético');

subplot(2,2,4);
plot(t,Wm,LineWidth=1); grid on;
xlabel('t(s)'); ylabel('\omega_m(rad/s)');
title('Velocidade mecânica');

%% Salvando figura
dirName = 'Imagens/atividade1/';
saveas(fig,strcat(dirName,'simResult.png'));
