clear; clc; close all;

%% Model
t=(0:0.01:5)';
I_yy=3.45;
M_q_dot=-4.88;
M_q=-6.87;
M_th=-6.87;
M_s=-3.46;
U=1;
num_plnt_th=M_s/(I_yy-M_q_dot);
den_plnt_th=[1 -M_q/(I_yy-M_q_dot) -M_th/(I_yy-M_q_dot)];
plnt_th=tf(num_plnt_th,den_plnt_th);

%% Input Parameters
fdSrc=10;
dim=3;
lwrBnd=[-50 -50 -50];
uprBnd=[100 100 100];
maxItr=100;
popSize=fdSrc/2;
lim=popSize*dim;
trial=zeros(popSize,1);

X=ones(popSize,dim);
X_best=ones(maxItr,dim);
f_best=ones(maxItr,1);

%% Initial Population
for i=1:popSize
    for j=1:dim
        X(i,j)=lwrBnd(:,j)+rand.*(uprBnd(:,j)-lwrBnd(:,j));
    end
end
fitVal=objFunc(plnt_th,X,t,false);

%% Algorithm
for itr=1:maxItr
    %% Employee Bee
    for i=1:popSize
        X_new=X(i,:);
        param2Chng=ceil(rand.*dim);
        partner=ceil(rand.*popSize);
        
        % Double Check
        while partner==i
            partner=ceil(rand*popSize);
        end
        
        X_param2Chng=X(i,param2Chng);
        X_p=X(partner,param2Chng);
        X_new(param2Chng)=X_param2Chng+((rand-0.5).*2).*(X_param2Chng-X_p);
        
        % Check for Limits
        for j=1:dim
            if X_new(j)>uprBnd(j)
                X_new(j)=uprBnd(j);
            elseif X_new(j)<lwrBnd(j)
                X_new(j)=lwrBnd(j);
            end
        end
        
        % Trial Counter
        fitVal_new=objFunc(plnt_th,X_new,t,false);
        if fitVal_new<fitVal(i,:)
            X(i,:)=X_new;
            fitVal(i,:)=fitVal_new;
            trial(i)=0;
        else
            trial(i)=trial(i)+1;
        end
    end
    
    %% Onlooker Bee
    prob=fitVal./sum(fitVal);
    for i=1:popSize
        if rand<prob(i)
            X_new=X(i,:);
            param2Chng=ceil(rand.*dim);
            partner=ceil(rand.*popSize);
            
            % Double Check
            while partner==i
                partner=ceil(rand*popSize);
            end
            
            X_param2Chng=X(i,param2Chng);
            X_p=X(partner,param2Chng);
            X_new(param2Chng)=X_param2Chng+(rand-0.5).*2.*(X_param2Chng-X_p);
            
            % Check for Limits
            for j=1:dim
                if X_new(j)>uprBnd(j)
                    X_new(j)=uprBnd(j);
                elseif X_new(j)<lwrBnd(j)
                    X_new(j)=lwrBnd(j);
                end
            end
            
            % Trial Counter
            fitVal_new=objFunc(plnt_th,X_new,t,false);
            if fitVal_new<fitVal(i,:)
                X(i,:)=X_new;
                fitVal(i,:)=fitVal_new;
                trial(i)=0;
            else
                trial(i)=trial(i)+1;
            end
        end
    end
    
    %% Memorize Best Solution
    [f_x_val, f_x_itr]=min(fitVal);
    Xc_best=X(f_x_itr,:);
    f_curr=objFunc(plnt_th,Xc_best,t,true);
    X_best(itr,:)=Xc_best;
    f_best(itr)=f_x_val;
    
    %% Sout Bee
    H=find(trial>lim);
    if ~isempty(H)
        for j=1:dim
            X(i,j)=lwrBnd(:,j)+rand.*(uprBnd(:,j)-lwrBnd(:,j));
        end
        fitVal(H,:)=objFunc(plnt_th,X(H,:),t,false);
    end
end

%% Final Best Solution
[f_final f_final_itr]=min(f_best);
X_final=X_best(f_final_itr,:);
disp('Final PID Parameters are: -');
disp(X_final);
disp('Cost is: -');
disp(f_final);

figure(2);
plot(f_best,'-r','LineWidth',1);
title('Best Fitness');
grid on; grid minor;
xlabel('Iterations'); ylabel('Fitness');

%% Simulink Results
simOut=sim('model.slx');
figure(3);
subplot(3,1,1);
plot(simOut.tout,simOut.simOut.signals.values(:,1),'--r','LineWidth',2);
title('Output Response (x_1 = q)');
grid on; grid minor;
xlabel('time (s)'); ylabel('Amplitude');
subplot(3,1,2);
plot(simOut.tout,simOut.simOut.signals.values(:,2),'--m','LineWidth',2);
title('Output Response (x_2 = z)');
grid on; grid minor;
xlabel('time (s)'); ylabel('Amplitude');
subplot(3,1,3);
plot(simOut.tout,simOut.simOut.signals.values(:,3),'-b','LineWidth',2);
title('Output Response (x_3 = \theta)');
grid on; grid minor;
xlabel('time (s)'); ylabel('Amplitude');

figure(4);
subplot(2,1,1);
plot(simOut.tout,simOut.simOut.signals.values(:,4),'-g','LineWidth',2);
title('Error');
grid on; grid minor;
xlabel('time (s)'); ylabel('Amplitude');
subplot(2,1,2);
plot(simOut.tout,simOut.simOut.signals.values(:,5),'-k','LineWidth',2);
title('Input to Plant');
grid on; grid minor;
xlabel('time (s)'); ylabel('Amplitude');