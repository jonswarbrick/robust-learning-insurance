function     SimData =RunSimulationsUsingLinearInterpolation(v0,rHist,NumSim,domain,OptimalChoices,Para)

%OptimalChoices=[c1 c2  barv1   barv2   lambda  mu11 mu12   mu21    mu22    tildepagent11   tildepagent12   tildepagent21   tildepagent22]
%                1  2   3       4       5       6    7      8       9       10              11              12              13

vHist(1)=v0;
zHist(1)=1;
MaxInx=length(domain);
for t=1:NumSim
    % Find the optimal conract for t
    
    Inx_=min((find(domain'-vHist(t)<0, 1, 'last' )),MaxInx-1);
     strucOptimalContract=OptimalChoices(Inx_,:)+((OptimalChoices(Inx_+1,:)-OptimalChoices(Inx_,:))/(domain(Inx_+1)-domain(Inx_)))*(vHist(t)-domain(Inx_));
    cHistMenu(t,:)=strucOptimalContract(1:2);
    cHist(t,:)=cHistMenu(t,zHist(t));
    LambdaHist(t)=strucOptimalContract(5);
    MuHist(t,:)=strucOptimalContract(6:9);
    DistortedBeliefsAgent1(t,:)=strucOptimalContract(10:11);
    DistortedBeliefsAgent2(t,:)=strucOptimalContract(12:13);
    
    % Draw z shock
    if rHist(t+1) < Para.pl(1)
    zHist(t+1)=1;
    else
        zHist(t+1)=2;
    end        
   % update the continuation values
  vHist(t+1)=strucOptimalContract(2+zHist(t+1)) ;        
end
SimData.zHist=zHist;
SimData.vHist=vHist;
SimData.cHistMenu=cHistMenu;
SimData.LambdaHist=LambdaHist;
SimData.MuHist=MuHist;
SimData.DistortedBeliefsAgent1=DistortedBeliefsAgent1;
SimData.DistortedBeliefsAgent2=DistortedBeliefsAgent2;
SimData.cHist=cHist;