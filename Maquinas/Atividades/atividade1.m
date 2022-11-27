close all
clear all
clc

%% M�quina de Indu��o

rs = 0.39;        % Resist�ncia do estator (c�clica)
rr = 1.41;        % Resist�ncia do rotor (c�clica)
ls = 0.094;       % Indut�ncia do estator (c�clica)
lr = 0.094;       % Indut�ncia do rotor (c�clica)
lm = 0.091;       % Indut�ncia m�tua (c�clica)
lso = 0.1*ls;
lro = 0.1*lr;
jm = 0.04;        % Constante mec�nica
kf = 0.01;        % Constante eletromagn�tica
p = 2;            % N�mero de pares de polos
Vf = 0;           % Tens�o do enrolamento do rotor

maqInd = maq3p(rs,rr,ls,lr,lm,lso,lro,jm,kf,p,Vf);

%% Fonte trif�sica (Aplicada ao estator)
ws = 2*pi*50;       % 50Hz
Vsm = 220*sqrt(2);  % Tens�o de pico
v3p = @(t, theta) Vsm*[
    cos(ws*t + theta);
    cos(ws*t - 2*pi/3 + theta);
    cos(ws*t + 2*pi/3 + theta)
];

%% Simula��o
h = 1e-4; tmax = 1;
t = (0:h:tmax);

vs123 = v3p(t, 0); cm = 0;
is123 = zeros(3,1); Rg = 100;

% Vetores de sa�da
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
title('Correntes estat�ricas');

subplot(2,2,3);
plot(t,fs,LineWidth=1); grid on;
xlabel('t(s)'); ylabel('\lambda_s(Wb)');
title('Fluxos estat�ricos');

subplot(2,2,2);
plot(t,Ce,LineWidth=1); grid on;
xlabel('t(s)'); ylabel('C_e(N.m)');
title('Conjugado eletromagn�tico');

subplot(2,2,4);
plot(t,Wm,LineWidth=1); grid on;
xlabel('t(s)'); ylabel('\omega_m(rad/s)');
title('Velocidade mec�nica');

%% Salvando figura
dirName = 'Imagens/atividade1/';
saveas(fig,strcat(dirName,'simResult.png'));
