close all
clear all
clc

%% Constantes

wg  = 2*pi*50;          % Frequência da tensão da fonte
Vgm = 220*sqrt(2);      % Tensão nominal da fonte
Ed  = 1.1*sqrt(3)*Vgm;  % Tensão do barramento
Igm = 20;               % Corrente nominal
pg  = 3*Vgm*Igm;        % Potência nominal
Zgm = Vgm/Igm;          % Impedância nominal

% Parâmetros do indutor da fonte:
rg = 0.01*Zgm
lg =  0.1*Zgm/wg

% Parâmetros do PWM:
fpwm = 10000;  % Hz    % Frequência de chaveamento

%% Sinais

% Fonte triangular:
vtri = @(t) (Ed/2)*sawtooth(2*pi*fpwm*t, 1/2);

% Sinal trifásico senoidal:
v3p = @(t, theta) [
    cos(wg*t + theta),...
    cos(wg*t - 2*pi/3 + theta),...
    cos(wg*t + 2*pi/3 + theta)
];

%% Parâmetros configuráveis:
% Fase da referência:
delta = -2*(pi/180)

% Parâmetro da tensão de referência do neutro:
mi_v = [0, 1, 0.5];

%% Simulação
% Parâmetros da simulação:
tmax = 0.5; h = 1e-6; t = (0:h:tmax)';
tpwm = (1/fpwm)*floor(t*fpwm);

egj     = Vgm*v3p(t, 0);
vgjref  = Vgm*v3p(tpwm, delta);

vn0ref_max =  Ed/2 - max(vgjref, [], 2);
vn0ref_min = -Ed/2 - min(vgjref, [], 2);

figure('Position',[400,70,800,800]); trange = [450 500]; %ms
irange = [-inf inf]; % Amperes
for i = 1:3
    mi = mi_v(i); % parâmetro mi atual
    
    % Tensão de referência entre neutros:
    vn0ref = mi*vn0ref_max + (1-mi)*vn0ref_min;
    
    vgj0ref = vgjref + vn0ref;  % Tensão de polo de referência
    
    q = (vgj0ref >= vtri(t));   % estado das chaves
    vgj0 = (2*q - 1)*(Ed/2);    % tensão de polo
    vn0 = sum(vgj0,2)/3;        % tensão de neutro
    
    vgj = vgj0 - vn0; % tensão de fase
    
    % Calculando a corrente (integração numérica):
    igj = zeros(length(t),3);
    for j = 1:(length(t)-1)
        diff_igj = (egj(j,:) - vgj(j,:) - rg*igj(j,:))/lg;
        igj(j+1,:) = igj(j,:) + diff_igj*h;
    end

    [wthd_igj,~] = wthd(igj(floor(length(igj)/2):end,1), 50, 1/h, 21);
    disp(['mi: ', num2str(mi),' -> wthd: ', num2str(100*wthd_igj), '%']);

    subplot(3,1,i);
    plot(1000*t, igj, 'LineWidth', 0.8);
    grid on; xlim(trange); ylim(irange);
    xlabel('t(ms)'); ylabel('i_{gj}(A)'); 
    title(['Correntes na carga (\mu = ', num2str(mi), ', wthd = ',...
        num2str(100*wthd_igj),'%)']);
end

%%
