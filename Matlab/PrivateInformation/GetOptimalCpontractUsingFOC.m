function optContract=GetOptimalCpontractUsingFOC(v0,z_,Para,InitContract)
global flagcons
flagcons=1;
global PPara  vv0 zz_;
PPara=Para;
vv0=v0;
zz_=z_;
xInit=[InitContract 0 0 -1];
 [x, fvec, user, ifail] =	c05qb(@resFOC, xInit );
 
 
if ~isempty(find(x(5:6) <0 , 1))
 flagcons=find(x(5:6)<0);
 [x, fvec, user, ifail] =	c05qb(@resFOC, x);
end
       switch ifail
             case {0}
              exitflag=1;
            case {2, 3, 4}
            exitflag=-2;
       end

optContract.Contract=x(1:4);
optContract.mu=x(5:6);
optContract.lambda=x(7);
optContract.exitflag=exitflag;
end

% [OptContract,fval,exitflag,output,Mu]  =ktrlink(@(x) QRU(x,z_,Para),InitContract,[],[],[],[],lb,ub,@(x) DynamicConstraintsRU(x,v0,z_,Para),opts);
% toc
% [x(1:4);OptContract]
% 
% a = [];
% bl = [0 0 0 0 0 -Inf -Inf -Inf -Inf] ;
% bu = [Inf Inf Inf Inf 0 0 0 0 0];
% x = OptContract;
% istate = zeros(9, 1, 'int64');
% cjac = zeros(5, 4);
% clamda = zeros(9, 1);
% r = zeros(4, 4);
% [cwsav,lwsav,iwsav,rwsav,ifail] = nag_opt_init('nag_opt_nlp1_solve');
% tic
% [iter, istate, c, cjac, clamda, objf, objgrd, r, x] = ...
%      nag_opt_nlp1_solve(a, bl, bu, @DynamicConstraintsRUNAG, @QRUNAG, istate, cjac, clamda, r, x, lwsav, iwsav, rwsav)
% toc
% 
% tic
% [OptContract,fval,exitflag,output,Mu]  =ktrlink(@(x) QRU(x,z_,Para),x,[],[],[],[],lb,ub,@(x) DynamicConstraintsRU(x,v0,z_,Para),opts);
% toc
% 
% 
% [mode, Cons, GradCons, user]=DynamicConstraintsRUNAG([], [], [], [], [], OptContract, [], [], [])
% [mode, Q, gradQ, user] = QRUNAG([], [], OptContract, [], [], [])
% [Q,gradQ]=QRU(OptContract,z_,Para)
% 
% tic
% [OptContract,fval,exitflag,output,Mu]  =ktrlink(@(x) QRU(x,z_,Para),x,[],[],[],[],lb,ub,@(x) DynamicConstraintsRU(x,v0,z_,Para),opts);
% toc
%  [CINQ, CEQ,  gradCINQ, gradCEQ ] = DynamicConstraintsRU(OptContract,v0,z_,Para)
