function [yHist,VHist,ConsRatioAgent1Hist,Emlogm_distmarg_agent1Hist,Emlogm_distmarg_agent2Hist,MPRHist]=SimulateV(yHist,V0,Para,c,Q,x_state,PolicyRules,dgp)
close all
Y=Para.Y;
YSize=Para.YSize;
P1=Para.P1;
P2=Para.P2;
WeightP2=Para.WeightP2;
VMax=max(Para.VGrid');
VMin=min(Para.VGrid');
y_draw(1)=yHist(1);
V(1)=V0;
xtest=[y_draw(1) V(1)];
xInit=GetInitalPolicyApprox(xtest,x_state,PolicyRules);
resQNew=getQNew(y_draw(1),V(1),c,Q,Para,xInit);

VStar=resQNew.VStar;
ConsStar=resQNew.ConsStar';
ConsStarRatio=ConsStar/Y(y_draw(1));

Distfactor1=resQNew.Distfactor1;
Distfactor2=resQNew.Distfactor2;
LambdaStar=resQNew.LambdaStar;
Lambda=resQNew.Lambda;

yHist(1)=y_draw(1);
if length(yHist)<Para.N
   flagExistingDraws='no'
else
    flagExistingDraws='yes'
end

VHist(1)=VStar(y_draw(1));
ConsRatioAgent1Hist(1)=ConsStarRatio(y_draw(1));


tic
for i=2:Para.N
    
xtest=[y_draw(i-1) VHist(i-1)];
xInit=GetInitalPolicyApprox(xtest,x_state,PolicyRules);
if min(xInit)<.0001
    xInit=xInit+.01;
end
resQNew=getQNew(y_draw(i-1),VHist(i-1),c,Q,Para,xInit);
exitflag=resQNew.ExitFlag;
switch dgp
        case 'RefModelAgent1'
           y_dist=P1(y_draw(i-1),:);
        case 'RefModelAgent2'
           y_dist=P2(y_draw(i-1),:);
            case 'DistModelAgent1'
            y_dist=P1(y_draw(i-1),:).*resQNew.Distfactor1;   
            case 'DistModelAgent2'
            y_dist=P2(y_draw(i-1),:).*resQNew.Distfactor2;   
            case 'ConvexCombination'
            y_dist=P2(y_draw(i-1),:)*WeightP2+(1-WeightP2)*P1;
           
    end
    if strcmpi(flagExistingDraws,'yes')
        y_draw(i)=yHist(i);
    else
    y_draw(i)=discretesample(y_dist, 1);
    end
    

% retriving the results
VStar=resQNew.VStar;                                                        % Continuation values
Cons=resQNew.Cons;                                                          % Consumption of Agent 1
ConsStar=resQNew.ConsStar;
Distfactor1=resQNew.Distfactor1;                                            % RN derivative Agent 1
Distfactor2=resQNew.Distfactor2;                                            % RN derivative Agent 2
ConsStarRatio(1)=ConsStar(1)./Y(1);                                                  % Consumption/Output ratio of Agent 1 tomorrow
ConsStarRatio(2)=ConsStar(2)./Y(2);                                                  % Consumption/Output ratio of Agent 1 tomorrow
Distorted_P_agent1=Para.P1(y_draw(i-1),:).*Distfactor1;                                  % Distorted Beleifs Agent 1
Distorted_P_agent2=Para.P2(y_draw(i-1),:).*Distfactor2;                                  % Distorted Beleifs Agent 2
Emlogm_distmarg_agent1=sum((Distorted_P_agent1./y_dist).*log((Distorted_P_agent1./y_dist)).*y_dist);                   % Relative Entropy for Agent 1
Emlogm_distmarg_agent2=sum((Distorted_P_agent2./y_dist).*log((Distorted_P_agent2./y_dist)).*y_dist);                   % Relative Entropy for Agent 1
if ~(Cons==0)
MRS=(der_u(ConsStar,Para.gamma)./der_u(Cons,Para.gamma)).*Distorted_P_agent1./y_dist;                    % MRS (RU) = usual MRS x Radon Nikodyn for Agent 1 
else
MRS=(der_u(Y',Para.gamma)./der_u(Y(y_draw(i-1)),Para.gamma)).*Distorted_P_agent1./y_dist;                    % MRS (RU) = usual MRS x Radon Nikodyn for Agent 1 
end    
MulogMRS= sum(y_dist.*log(MRS));                                                        % Mean(logMRS) for Robust Utility under the Reference Model
SigmalogMRS=sum((y_dist.*(log(MRS)-((MulogMRS))*ones(1,YSize)).^2).^.5);                                      % Std (logMRS) for Robust Utility under the Reference Model
MPR=SigmalogMRS;                                                        % Market Price of Risk  (MRS) for Robust Utility under the dgp
 
% Storing the history for simulations
% 0. YShock
% 1. Continuation Value
VHist(i)=VStar(y_draw(i));
% 2. Consumption Share of Agent 1
ConsRatioAgent1Hist(i)=ConsStarRatio(y_draw(i));
% 3. Relative Entropies
Emlogm_distmarg_agent1Hist(i-1)=Emlogm_distmarg_agent1;
Emlogm_distmarg_agent2Hist(i-1)=Emlogm_distmarg_agent2;
% 4. Market Price of Risk
MPRHist(i-1)=MPR;

if VHist(i)> VMax(y_draw(i))
    disp('truncating vstar')
    VHist(i)=VMax(y_draw(i));
end
    
    
if ConsRatioAgent1Hist(i)> 0.999
    VHist(i)=VMin(y_draw(i));
end


if mod(i,Para.N/10)==0
    disp('Executing iteration..');
    disp(i);
    toc
    tic
end

end

yHist=y_draw;
