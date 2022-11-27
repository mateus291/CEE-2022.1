classdef maq3p
    %MAQ3P Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        rs
        rr
        ls
        lr
        lm
        lso
        lro
        as
        bs
        ar
        br
        jm
        kf
        cte_tempo_mec
        p
        cm
        wm
        ce
        isodq
        fsodq
        irodq
        frodq
        Vf
        vr123
        thetar
    end
    
    methods
        function obj = maq3p(rs,rr,ls,lr,lm,lso,lro,jm,kf,p,Vf)
            obj.rs = rs;
            obj.rr = rr;
            obj.ls = ls;
            obj.lr = lr;
            obj.lm = lm;
            obj.lso = lso;
            obj.lro = lro;
            obj.jm = jm;
            obj.kf = kf;
            obj.p = p;
            obj.Vf = Vf;

            Lssodq = [[lso, 0, 0];[0, ls, 0];[0, 0, ls]];
            Lrrodq = [[lro, 0, 0];[0, lr, 0];[0, 0, lr]];
            Lsrodq = [[0  , 0, 0];[0, lm, 0];[0, 0, lm]];

            obj.as = inv(eye(3)-((Lssodq\Lsrodq)/Lrrodq)*Lsrodq)/Lssodq;
            obj.bs = Lsrodq/Lrrodq;
            obj.ar = inv(eye(3)-((Lrrodq\Lsrodq)/Lssodq)*Lsrodq)/Lrrodq;
            obj.br = Lsrodq/Lssodq;

            obj.cte_tempo_mec = jm/kf;

            obj.cm = 0; obj.wm = 0; obj.ce = 0;
            obj.thetar = 0;
            obj.isodq = zeros(3,1); obj.irodq = zeros(3,1);
            obj.fsodq = zeros(3,1); obj.frodq = zeros(3,1);
            obj.vr123 = [Vf; -Vf/2; -Vf/2];
        end
        
        function obj = stepSim(obj, vs123, cm, h)
            obj.cm = cm;

            obj.thetar = maq3p.angSat(obj.thetar + obj.wm * h);
            vsodq = (maq3p.P(0)')*vs123;
            vrodq = (maq3p.P(-obj.thetar)')*obj.vr123;

            diff_fsodq = vsodq - obj.rs*obj.isodq;
            diff_frodq = vrodq - obj.rr*obj.irodq + ...
                obj.wm*[[0,0,0];[0,0,-1];[0,1,0]]*obj.frodq;

            obj.fsodq = obj.fsodq + diff_fsodq*h;
            obj.frodq = obj.frodq + diff_frodq*h;

            obj.isodq = obj.as*(obj.fsodq-obj.bs*obj.frodq); 
            isd = obj.isodq(2); isq = obj.isodq(3);
            
            obj.irodq = obj.ar*(obj.frodq-obj.br*obj.fsodq); 
            ird = obj.irodq(2); irq = obj.irodq(3);

            obj.ce = obj.p*obj.lm*(isq*ird - isd*irq);
            derw = -obj.wm/obj.cte_tempo_mec + obj.p*(obj.ce-obj.cm)/obj.jm;
            obj.wm = obj.wm + derw*h;
        end

        function [is123,fs123,ce,wm] = getOutput(obj)
            is123 = (maq3p.P(0))*obj.isodq;
            fs123 = (maq3p.P(0))*obj.fsodq;
            ce = obj.ce;
            wm = obj.wm;
        end
    end

    methods (Static)
        function p = P(deltag)
            p = sqrt(2/3)*[
                (1/sqrt(2))*ones(3, 1),...
                [ cos(deltag);  cos(deltag-(2*pi/3));  cos(deltag+(2*pi/3))],...
                [-sin(deltag); -sin(deltag-(2*pi/3)); -sin(deltag+(2*pi/3))];
            ];
        end

        function gamma = angSat(ang)
            gamma = ang - floor(ang/(2*pi))*2*pi;
        end
    end
end

