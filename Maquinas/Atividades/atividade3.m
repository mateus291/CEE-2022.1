close all
clear all
clc

dirName = 'Imagens/atividade3/';

%% Constantes

wg  = 2*pi*50;          % Frequência da tensão da fonte
Vgm = 220*sqrt(2);      % Tensão nominal da fonte
Ed  = 1.1*sqrt(3)*Vgm;  % Tensão do barramento
Igm = 20;               % Corrente nominal
pg  = 3*Vgm*Igm;        % Potência nominal
Zgm = Vgm/Igm;          % Impedância nominal

% Parâmetros do indutor da fonte RLE:
rg = 0.01*Zgm
lg =  0.1*Zgm/wg

% Parâmetros do PWM:
fpwm = 10000;  % Hz    % Frequência de chaveamento


%% Parâmetros de simulação
h = 1e-6; tmax = 0.5; t = (0:h:tmax)';

%% Fonte RLE
egj = Vgm*[
    cos(wg*t), cos(wg*t - 2*pi/3), cos(wg*t + 2*pi/3)
];

%% Conversor trifásico (Circuito 1)
% Tensão do conversor defasada em 5° da fonte, com ponto zero conectado ao
% neutro da carga (Circuito 1).

delta = -5*(pi/180); arm4 = 0; mi = 0;
[vgj, vgj0] = conv3p(Vgm,wg,delta,Ed,fpwm,arm4,mi,t);

%% Simulação (Circuito 1)
% Calculando a corrente (integração numérica):
igj = zeros(length(t),3);
for j = 1:(length(t)-1)
    diff_igj = (egj(j,:) - vgj(j,:) - rg*igj(j,:))/lg;
    igj(j+1,:) = igj(j,:) + diff_igj*h;
end

%% Resultados (Circuito 1)
[wthd_igj,~] = wthd(igj(floor(length(igj)/2):end,1), 50, 1/h, 21);

fig = figure('Position',[100,300,1800,400]); 
trange = [400 500]; %ms
irange = [-inf inf]; % Amperes

plot(1000*t, igj, 'LineWidth', 0.8);
grid on; xlim(trange); ylim(irange);
xlabel('t(ms)'); ylabel('i_{gj}(A)'); 
title(['Correntes na carga (wthd = ', num2str(100*wthd_igj),'%)']);

saveas(fig,strcat(dirName,'no4thArm.png'));


%% Conversor trifásico (Circuito 2)
% Tensão do conversor defasada em 5° da fonte, com adição de um quarto
% braço
delta = -5*(pi/180); arm4 = 1; miv = [0,1,0.5];

for i = 1:length(miv)

    mi = miv(i);
    [vgj, vgj0] = conv3p(Vgm,wg,delta,Ed,fpwm,arm4,mi,t);
    
    %% Simulação (Circuito 2)
    % Calculando a corrente (integração numérica):
    igj = zeros(length(t),3);
    for j = 1:(length(t)-1)
        diff_igj = (egj(j,:) - vgj(j,:) - rg*igj(j,:))/lg;
        igj(j+1,:) = igj(j,:) + diff_igj*h;
    end
    
    %% Resultados (Circuito 2)
    [wthd_igj,~] = wthd(igj(floor(length(igj)/2):end,1), 50, 1/h, 21);
    
    fig = figure('Position',[100,300,1800,400]);    
    plot(1000*t, igj, 'LineWidth', 0.8);
    grid on; xlim(trange); ylim(irange);
    xlabel('t(ms)'); ylabel('i_{gj}(A)'); 
    title(['Correntes na carga (wthd = ', num2str(100*wthd_igj),'%)']);
    
    saveas(fig,strcat(dirName,sprintf('4thArm_mi(%.2f).png', mi)));

end