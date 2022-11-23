%close all
clear all
clc

%% Funções úteis
% Representação de ângulos no intervalo [0, 2*pi):
angSat = @(ang) ang - floor(ang/(2*pi))*2*pi;

% Matriz de transformação P:
P = @(deltag) sqrt(2/3)*[
    (1/sqrt(2))*ones(3, 1),...
    [ cos(deltag);  cos(deltag-(2*pi/3));  cos(deltag+(2*pi/3))],...
    [-sin(deltag); -sin(deltag-(2*pi/3)); -sin(deltag+(2*pi/3))];
];

%% Constantes
%parametros da maquina 0
rs=0.39;
rr=1.41;  %1.41
ls=0.094;
lr=0.094;
msr=0.091;
lso=0.1*ls;
lro=0.1*lr;

Lssodq = [[lso, 0, 0];[0, ls, 0];[0, 0, ls]];
Lrrodq = [[lro, 0, 0];[0, lr, 0];[0, 0, lr]];
Lsrodq = [[0  , 0, 0];[0, msr,0];[0, 0,msr]];

% Matrizes coeficientes da solução para as correntes:
as = inv(eye(3)-((Lssodq\Lsrodq)/Lrrodq)*Lsrodq)/Lssodq;
bs = Lsrodq/Lrrodq;
ar = inv(eye(3)-((Lrrodq\Lsrodq)/Lssodq)*Lsrodq)/Lrrodq;
br = Lsrodq/Lssodq;

jm = 0.04;
kf = 0.01;
cte_tempo_mec=jm/kf;
p = 2;   %numero de pares de polos

%% Condicoes iniciais

cm=0;		%conjugado mecanico
wm=0;		%velocidade da maquina

ce = 0; ws= 2*pi*60; 
Vsm = 220*sqrt(2);  
Vs = Vsm; % Tensão de pico de uma fase do estator
Vf = 50; % Tensão do rotor
thetae = 0; thetar = 0; 

isodq = zeros(3, 1); fsodq = zeros(3, 1);
irodq = zeros(3, 1); frodq = zeros(3, 1);

%% Parametros da simulacao

h = 1.e-4;  % 1.e-4; 2.e-4; 5.e-4;
% h = input('entre com o periodo de discretizacao h  ')

tmax = 4;
% tmax = input('entre com o tempo de simulacao (tmax)  ')

t = 0:h:tmax;

% Número de amostras para exposição dos resultados:
N = 8000;
% N = input('entre com o número de amostras para os gráficos (N)  ')
hp = tmax / N; tp = 0; % <- tempo de amostragem de saída
jp = 1;

%% Simulação

% Vetores de saída:
tempo = zeros(N, 1);
corrente1=zeros(N, 1); corrente2=zeros(N, 1); corrente3=zeros(N, 1);
tensao1 = zeros(N, 1); tensao2 = zeros(N, 1); tensao3 = zeros(N, 1);
fluxo1  = zeros(N, 1); fluxo2  = zeros(N, 1); fluxo3  = zeros(N, 1);
conjugado=zeros(N, 1); velocidade=zeros(N,1); conjcarga=zeros(N, 1);

for j = 1:length(t)
	
	thetae = angSat(t(j)*ws);
    thetar = angSat(t(j)*wm);
	
    % Tensões estator:
    vs123 = [
        Vs*cos(thetae);
        Vs*cos(thetae-(2*pi/3));
        Vs*cos(thetae+(2*pi/3))
    ];
    vsodq = (P(0)')*vs123;
    
    % Tensões rotor:
    vr123 = [Vf; -Vf/2; -Vf/2];
    vrodq = (P(-thetar)')*vr123;
    
    % Correntes:
	isodq = as*(fsodq-bs*frodq); isd = isodq(2); isq = isodq(3);
    irodq = ar*(frodq-br*fsodq); ird = irodq(2); irq = irodq(3);
	
    % Diferenciais:
    diff_fsodq = vsodq - rs*isodq;
    diff_frodq = vrodq - rr*irodq + wm*[[0,0,0];[0,0,-1];[0,1,0]]*frodq;

    % Fluxos:
    fsodq = fsodq + diff_fsodq*h;
    frodq = frodq + diff_frodq*h;

    % Conjugado eletromagnético:
	ce = p*msr*(isq*ird - isd*irq);

    % Adição de conjugado mecânico em t = tmax/2:
    if(t(j) > tmax/2)
        cm = 40;
    end

	% Equacao de estado mecanica discreta
	derwm = - wm/cte_tempo_mec + p*(ce-cm)/jm;
	wm = wm + derwm*h;

    % Transformação inversa dos fluxos e correntes:
    is123 = (P(   0   ))*isodq;
    ir123 = (P(-thetar))*irodq;
    fs123 = (P(   0   ))*fsodq;
    fr123 = (P(-thetar))*frodq;

    % Armazenando dados para visualização:
	if t(j) > tp
        tempo(jp)       = t(j);
        corrente1(jp)   = is123(1);
        corrente2(jp)   = is123(2);
        corrente3(jp)   = is123(3);
        tensao1(jp)     = vs123(1);
        tensao2(jp)     = vs123(2);
        tensao3(jp)     = vs123(3);
        fluxo1(jp)      = fs123(1);
        fluxo2(jp)      = fs123(2);
        fluxo3(jp)      = fs123(3);
        conjugado(jp)   = ce;
        velocidade(jp)  = wm;
        conjcarga(jp)   = cm;

	    tp = tp + hp;
        jp = jp + 1;
	end
	%
end   %fim da simulação

%% Plotando os resultados

figure('Position',[50, 50, 850, 850]),
subplot(321);
plot(tempo,corrente1,tempo,corrente2,tempo,corrente3),zoom
title('correntes');
%pause

subplot(323);
plot(tempo,tensao1,tempo,tensao2,tempo,tensao3),zoom
title('tensoes');
%pause

subplot(325);
plot(tempo,fluxo1,tempo,fluxo2,tempo,fluxo3),zoom
title('fluxos');
%pause

subplot(322)
plot(tempo,conjugado),zoom,
title('conjugado eletromagnético');
%pause

subplot(324);
plot(tempo,velocidade),zoom,
title('velocidade');
%pause

subplot(326);
plot(tempo,conjcarga),zoom,
title('conjugado de carga');
%pause

