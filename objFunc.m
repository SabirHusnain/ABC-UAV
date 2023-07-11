function out=objFunc(varargin)
if nargin==2
    plnt_th=varargin{1};
    k=varargin{2};
    time=20;
    bool=0;
elseif nargin==3
    plnt_th=varargin{1};
    k=varargin{2};
    time=varargin{3};
    bool=1;
else
    plnt_th=varargin{1};
    k=varargin{2};
    time=varargin{3};
    bool=varargin{4};
end

[m, n]=size(k);
out=ones(m,1);

for i=1:m
    k_p=k(i,1); k_i=k(i,2); k_d=k(i,3);
    G=plnt_th;
    G_c=tf([k_d k_p k_i],[1 0]);
    sys_th_loop=feedback(series(G,G_c),1);
    u=ones(length(time),1);
    y=lsim(sys_th_loop,u,time);
    e=u-y;
    out(i)=sum(abs(e).^2);
    if bool
        figure(1);
        subplot(2,1,1);
        plot(time,y,'-r','LineWidth',2); hold on;
        plot(time,u,'--k','LineWidth',1); hold off;
        strTitle=sprintf('Response of System --> PID = [%s, %s, %s]',k_p,k_i,k_d);
        title(strTitle); grid on; grid minor;
        xlabel('time (s)'); ylabel('Amplitude');
        subplot(2,1,2);
        plot(time,e,'-b','LineWidth',2);
        strTitle=sprintf('Error');
        title(strTitle); grid on; grid minor;
        xlabel('time (s)'); ylabel('Amplitude');
    end
end
end