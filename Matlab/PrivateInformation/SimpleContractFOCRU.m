% This program computes the Dynamic Incentive and Promise Keeping Constraints for the robust utility case. It also computes the gradients
 function res = SimpleContractFOCRU(x,v0,z_,Para)
% v0 is the exante promised utility
% z_ is the state previous period
% These both are the state variables for the Optimization. We solve for the
% simple contract which imposes c2=c1+Delta and v^*(1)=v^*(2); This
% contract always satisfies the incentive constraints


% get components from x
c=x(1);
bar_vstar=x(2);


% get components from Para struc
P=Para.P(:,:,Para.m_true);
ra=Para.RA;
delta=Para.delta;
y=Para.y;
sl=Para.sl;
sh=Para.sh;
Delta=y*(sh-sl);
Theta=Para.Theta;
theta_11=Theta(1,1);
theta_21=Theta(2,1);


if (c<y-Delta && c>0)
% Terminal Period 
%% This section computes the multiplier associated with PK and the value function in the terminal period corresponding to guessed bar_vstar. Note that the envelope condition links lambdastar=Qstar_v(vstar,z)
        [lambdastar_1 Qstar_1 cstar_1]=LambdaStar(bar_vstar,1,Para,1);
        [lambdastar_2 Qstar_2 cstar_2]=LambdaStar(bar_vstar,2,Para,1);
            lambdastar=[lambdastar_1 lambdastar_2];
            Qstar=[Qstar_1 Qstar_2];
%% Promisekeeping for Agent 2

% exp(-(u+delta Q*)/theta) for both the agents
ExpU11=exp(-(u(c,ra)+delta*Qstar(1))/theta_11);
ExpU12=exp(-(u(c+Delta,ra)+delta*Qstar(2))/theta_11);
ExpU21=exp(-(u(y-c,ra)+delta*bar_vstar)/theta_21);
ExpU22=exp(-(u(y-c-Delta,ra)+delta*bar_vstar)/theta_21);


% Mean of the exponentiated utility
MeanExp1=P(z_,1)*(ExpU11)+P(z_,2)*(ExpU12);
MeanExp2=P(z_,1)*(ExpU21)+P(z_,2)*(ExpU22);

% Now we compute the disrtoted distribution for the computing the ex ante
% utilities for both agents
tilde_p0_agent_1(1)=P(z_,1)*exp(ExpU11);
tilde_p0_agent_1(2)=P(z_,2)*exp(ExpU12);
tilde_p0_agent_1=tilde_p0_agent_1./sum(tilde_p0_agent_1);


tilde_p0_agent_2(1)=P(z_,1)*exp(ExpU21);
tilde_p0_agent_2(2)=P(z_,2)*exp(ExpU22);
tilde_p0_agent_2=tilde_p0_agent_2./sum(tilde_p0_agent_2);        


% Lastly we compute the gradient of the value function with each of the
% control variable - c1,c2,v*_1(1),v*_1(2), v*_2(1) v*_2(2)





%% Promisekeeping for Agent 2

CEQ=-theta_21*log(MeanExp2)-v0;

LHS=[der_u(c,ra) der_u(c+Delta,ra)]*[tilde_p0_agent_1'];
RHS=([der_u(y-c,ra) der_u(y-c-Delta,ra)]*[tilde_p0_agent_2'])*(lambdastar*tilde_p0_agent_2');
res=[CEQ LHS-RHS];
else
    
 res=[abs(c-y+Delta) abs(bar_vstar)]*1000;   
end



