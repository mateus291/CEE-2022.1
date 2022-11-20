close all
clear all
clc

%% Constantes

pi23=2*pi/3;
rq23=sqrt(2/3);
rq3=sqrt(3);

%parametros da maquina 0
rs=0.39;
rr=1.41;  %1.41
ls=0.094;
lr=0.094;
msr=0.091;
lso=0.1*ls;

jm = 0.04;
kf = 0.01;
cte_tempo_mec=jm/kf;
idt=1/(ls*lr-msr*msr);
p = 2;   %numero de pares de polos
amsr = p*idt*msr;

%% Condicoes iniciais

cm=0;		%conjugado mecanico
wm=0.;		%velocidade da maquina

ce = 0; ws= 2*pi*60; 
Vsm=220*sqrt(2);  
Vs=Vsm; tete=0;

fsd=0; fsq=0; 
frd=0; frq=0;
isd=0; isq=0;
ird=0; irq=0;

iso = 0; fso = 0;

vs1 = 0; vs2 = 0; vs3 = 0;
is1 = 0; is2 = 0; is3 = 0;

%% Parametros da simulacao

h = 1.e-5;  % 1.e-4; 2.e-4; 5.e-4;
% h = input('entre com o periodo de discretizacao h  ')

tmax = 1;
% tmax = input('entre com o tempo de simulacao (tmax)  ')

t = 0:h:tmax;

% Número de amostras para exposição dos resultados:
N = 2000;
% N = input('entre com o número de amostras para os gráficos (N)  ')
hp = tmax / N; tp = 0; % <- tempo de amostragem de saída
jp = 1;

%% Simulação

% Resistência em série com vs1 para abertura de fase:
Rg = 100;

% Vetores de saída
z = zeros(N, 1);
tempo = z; 
corrented = z; correnteq = z;
tensaosd = z; tensaosq = z;
fluxord = z; fluxorq = z;
fluxosd = z; fluxosq = z;

corrente1 = z; corrente2 = z; corrente3 = z;
tensao1 = z;tensao2 = z; tensao3 = z;
fluxos1 = z; fluxos2 = z; fluxos3 = z;

conjugado = z; velocidade = z;
frequencia = z; conjcarga = z;

for j = 1:length(t)
	
	tete = t(j)*ws;
	
    % Tensões:
    if t(j) > tmax/2 % Abertura da fase 1 na metade da simulação
        vs1 = Vs*cos(tete) - Rg*is1;
    else
        vs1 = Vs*cos(tete);
    end
    vs2 = Vs*cos(tete-pi23);
	vs3 = Vs*cos(tete+pi23);

	vsd = rq23.*(vs1 - vs2./2 - vs3./2); 
	vsq = rq23.*(vs2*rq3./2 - vs3*rq3./2);
	vso = (1/rq3).*(vs1 + vs2 + vs3);
    
    % Diferenciais:
	dervfsd = vsd - rs*isd;
	dervfsq = vsq - rs*isq;
	dervfrd = -rr*ird - frq*wm;
	dervfrq = -rr*irq + frd*wm;
	deriso  = (vso - iso*rs)/lso;
    
    % Fluxos:
	fsd = fsd + dervfsd*h;
	fsq = fsq + dervfsq*h;
	frd = frd + dervfrd*h;
	frq = frq + dervfrq*h;

    % Componente homopolar:
	iso = iso+deriso*h;
    fso = lso*iso;
    
	ce = amsr*(fsq*frd-fsd*frq);
	
	isd = idt*(lr*fsd - msr*frd);
	isq = idt*(lr*fsq - msr*frq);
	
	ird = idt*(-msr*fsd + ls*frd);
	irq = idt*(-msr*fsq + ls*frq);
	
	is1 = rq23*isd + (1/rq3)*iso;
	is2 = rq23*(-isd./2 + rq3*isq/2) + (1/rq3)*iso;
	is3 = rq23*(-isd./2 - rq3*isq/2) + (1/rq3)*iso;
	
	fs1 = rq23*fsd + (1/rq3)*fso;
	fs2 = rq23*(-fsd./2 + rq3*fsq./2) + (1/rq3)*fso;
	fs3 = rq23*(-fsd./2 - rq3*fsq./2) + (1/rq3)*fso;
	
	%equacao de estado mecanica discreta
	derwm = - wm/cte_tempo_mec + p*(ce-cm)/jm;
	wm = wm + derwm*h;       
	
    % Armazenando dados para visualização:
	if t(j) > tp
	    tempo(jp) = t(j);
	    corrented(jp) = isd;
	    correnteq(jp) = isq;
	    corrente1(jp) = is1;
	    corrente2(jp) = is2;
	    corrente3(jp) = is3;
	    tensao1(jp) = vs1;
	    tensao2(jp) = vs2;
	    tensao3(jp) = vs3;
	    tensaosd(jp) = vsd;
	    tensaosq(jp) = vsq;
	    fluxord(jp) = frd;
	    fluxorq(jp) = frq;
	    fluxos1(jp) = fs1;
	    fluxos2(jp) = fs2;
	    fluxos3(jp) = fs3;
	    fluxosd(jp) = fsd;
	    fluxosq(jp) = fsq;
	    conjugado(jp) = ce;
	    velocidade(jp) = wm;
	    frequencia(jp) = ws;
	    conjcarga(jp) = cm;

        tp = tp + hp;
        jp = jp + 1;
	end
	%
end   %fim da simulação

%% Plotando os resultados

figure(1),plot(tempo,corrente1,tempo,corrente2,tempo,corrente3),zoom
title('correntes');
%pause

figure(2),plot(tempo,tensao1,tempo,tensao2,tempo,tensao3),zoom
title('tensoes');
%pause

figure(3),plot(tempo,fluxos1,tempo,fluxos2,tempo,fluxos3),zoom
title('fluxos');
%pause

figure(4),plot(tempo,conjugado),zoom
title('conjugado eletromagnético');
%pause

figure(5),plot(tempo,velocidade),zoom
title('velocidade');
%pause

figure(6),plot(tempo,conjcarga),zoom
title('conjugado de carga');
%pause

