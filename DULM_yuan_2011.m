clc
clear
format short
format compact
global Po
global Pc
Po = 0.10;
Pc = 0.01;
nMaster = 25;  % ____ 10000'de tak?l?yor
mMaster = nMaster;
k = 0;
sampleSize = 200;
timeVectorHeuristic =zeros(1,sampleSize);
sizeVectorHeuristic = zeros(1,sampleSize);

for k=1:sampleSize
    
  n = nMaster;
    m = mMaster;
    tic
    fprintf('\n')
    fprintf(' k = %d\n\n', k)
    flag = true;
    
    crossbarGraph = randsrc(n, m, [1 0 -1 ; (1 - Po - Pc) Po Pc]);
    if Pc>0
        [row,col] = find(crossbarGraph == -1);
        row = unique(row);
        col = unique(col);
        crossbarGraph(row,:) =[];
        crossbarGraph(:,col) =[];   
        [m,n] = size(crossbarGraph);
    end
    
    crossbarGraphC = double(~crossbarGraph);
    Udeg = sum(crossbarGraphC);
    Vdeg = sum(crossbarGraphC,2);
    U = 1:n;
    V = (1:m)';
    Ub = zeros(1,n);
    Vb = zeros(1,m)';
    
    
    while (any(U>0)) && (any(V>0))
        
        Ub(1,find(Udeg == 0)) = 1;
        Vb(find(Vdeg == 0),1) = 1;
        U(:,find(Udeg == 0)) = 0;
        V(find(Vdeg == 0),:) = 0;
        Udeg(Udeg==0) = NaN;
        Vdeg(Vdeg==0) = NaN;
        
        if flag
            
            [~,v] = min(Vdeg);
            neig = find(crossbarGraphC(v,:) == 1);
            neigDeg = Udeg(1,neig);
            [~,pos] = max(neigDeg);
            u = neig(1,pos);
            Udeg(:,u) = NaN;
            U(:,u) = 0;
            temp = find(crossbarGraphC(:,u) ==1);
            buf =zeros(1,m)';
            buf(temp,1) = 1;
            Vdeg = Vdeg - buf;
            
        else
            
            [~,u] = min(Udeg);
            neig = find(crossbarGraphC(:,u) ==1);
            neigDeg = Vdeg(neig,1);
            [~,pos] = max(neigDeg);
            v = neig(pos,1);
            Vdeg(v,:) = NaN;
            V(v,:) = 0;
            
            temp = find(crossbarGraphC(v,:) ==1);
            buf =zeros(1,n);
            buf(1,temp) = 1;
            Udeg = Udeg - buf;
        end
        
        flag = ~flag;
        
    end
    
    T = toc;
    timeVectorHeuristic(1,k) = T;
    fprintf(' Heuristic Runtime = %0.4f\n',T)
    subcrossbarGraph = crossbarGraph(find(Vb==1), find(Ub==1));
    [mS,nS] = size(subcrossbarGraph);
    sizeVectorHeuristic(1,k) = max(mS,nS);
    fprintf(' Sub-crossbar Size = %d, %d\n\n ',mS,nS)
%     display(subcrossbarGraph)
    fprintf('\n')
    
end

sizeMean = mean(sizeVectorHeuristic);
timeMean = mean(timeVectorHeuristic);
yield = min(mS,nS) / nMaster;
fprintf(' Yield = %f , Runtime = %f and K-value = %f \n',yield^2,timeMean,sizeMean)
