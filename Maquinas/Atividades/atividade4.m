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

maqAsinc = maq3p(rs,rr,ls,lr,lm,lso,lro,jm,kf,p,Vf);

%% Conversor trifásico

wg  = 2*pi*50;          % Frequência da tensão de referência da fonte
Vgm = 220*sqrt(2);      % Tensão nominal da fonte
thetag = 0;             % Fase da tensão de referência da fonte
Ed  = 1.1*sqrt(3)*Vgm;  % Tensão do barramento
fpwm = 10000;  % Hz     % Frequência de chaveamento
arm4 = 0;               % Quarto braço presente / ausente
mi = 0.5;               % Distribuição da referência no quarto braço

h = 5e-6; tmax = 0.5;
t = (0:h:tmax)';

[vs123,vsj0] = conv3p(Vgm,wg,thetag,Ed,fpwm,arm4,mi,t);

%% Simulação

cm = 0;

% Vetores de saída
is = zeros(length(t),3); fs = zeros(length(t),3); 
Ce = zeros(length(t),1); Wm = zeros(length(t),1); Cm = zeros(length(t),1);
is123 = zeros(3,1); fs123 = zeros(3,1);

% Loop de simulação
for i = 1:length(t)
    if t(i) > tmax/2 % Adição de conjugado mecânico em t = tmax/2
        cm = 40;
    end
    maqAsinc = maqAsinc.stepSim(vs123(i,:)', cm, h);
    [is123,fs123,ce,wm] = maqAsinc.getOutput();
    
    is(i,:) = is123'; fs(i,:) = fs123';
    Ce(i) = ce; Wm(i) = wm; Cm(i) = cm;
end

%% Figuras
tspan = Inf;
trange = [(tmax-tspan)/2, (tmax+tspan)/2];

fig1 = figure('Position',[200,100,1500,800]);
subplot(2,2,1);
plot(t, is, LineWidth=1); grid on; xlim(trange);
title('Correntes estatóricas'); xlabel('t(s'); ylabel('i_s(A)');

subplot(2,2,3);
plot(t, fs, LineWidth=1); grid on; xlim(trange);
title('Fluxos estatóricos'); xlabel('t(s'); ylabel('\lambda_s(Wb)');

subplot(2,2,2);
plot(t,Cm,t,Ce,LineWidth=1); grid on; xlim(trange);
title('Conjugados');
xlabel('t(s)'); ylabel('C(N.m)');
legend({'Conjugado Mecânico', 'Conjugado Eletromagnético'});

subplot(2,2,4);
plot(t, Wm, LineWidth=1); grid on; xlim(trange);
title('Velocidade do rotor');
xlabel('t(s'); ylabel('\omega_m(rad/s)');

tspan = 0.05;
trange = [(tmax-tspan)/2, (tmax+tspan)/2];

fig2 = figure('Position',[200,100,1500,800]);
subplot(2,1,1);
plot(t, vs123, LineWidth=1); grid on; xlim(trange);
title('Tensões de fase');
xlabel('t(s)'); ylabel('v_s(V)');

subplot(2,1,2);
plot(t, vsj0, LineWidth=1); grid on; xlim(trange);
title('Tensões de polo');
xlabel('t(s)'); ylabel('v_{s0}(V)');

%% Salvando figuras
dirName = 'Imagens/atividade4/';
saveas(fig1,strcat(dirName,'maquina.png'));
saveas(fig2,strcat(dirName,'conversor.png'));
