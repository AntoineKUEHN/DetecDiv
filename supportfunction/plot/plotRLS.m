function rlstNdivs=plotRLS(rlsfile,varargin)

% plot RLS data for one or several curves

% input : rls :  array of struct that contains all division times for all cells
% divDur.value contains division times, divDur.sep contains the position of the
% SEP; fuo values can be provided in addition to division times

% param: parameters provided as a single object

% findSEP : find SEP to identify the position of the SEP
% align : whether data should be aligned according to SEP or not
% display style : color map : name or custom colormap : limits for
% colormap, color separation , linewidth spacing etc
% time : generation or physical time

%example: plotRLS({[detecdivProj.fov([1:4,9:12]).roi];[detecdivProj.fov([5:8,13:16,17:18]).roi]; [detecdivProj.fov([26:28,30:34]).roi]},'Comment',{'Condition1', 'Condition2','Condition3'})
figExport=0;
dataExport=0;
bootStrapping=0;
confidenceInterval=0;
binning=4;
cuty=10; %stop displaying HR if less than cuty events
sz=5;
Nboot=100;
plotHazardRate=0;
filename='RLS_export';
maxBirth=100; %max frame to be born. After, discard rls.
GT=0;
figName='default';
% load=0;

% comment=cell(szc,1);

% rls=cell(szc,1);

for i=1:numel(varargin)
    %     if strcmp(varargin{i},'Comment')
    %         comment=varargin{i+1};
    %     end
    if strcmp(varargin{i},'ExportPlot')
        figExport=1;
    end
    
    if strcmp(varargin{i},'ExportData')
        dataExport=1;
    end
    
    if strcmp(varargin{i},'ConfidenceInterval')
        confidenceInterval=1;
    end
        
    if strcmp(varargin{i},'HazardRate')
        plotHazardRate=1;
    end
    
    if strcmp(varargin{i},'Bootstrap')
        bootStrapping=1;
    end
    
    if strcmp(varargin{i},'Bootstrap_Steps')
        Nboot=varargin{i+1};
    end
    
    if strcmp(varargin{i},'Binning_HazardRate')
        binning=varargin{i+1};
    end
    
    if strcmp(varargin{i},'MinNumberCell_HazardRate')
        cuty=varargin{i+1};
    end
    
    if strcmp(varargin{i},'Load') %load data
        load=1;
    end
    
    if strcmp(varargin{i},'Filename')
        filename=varargin{i+1};
    end
    
    if strcmp(varargin{i},'FrameInterval')
        timeFactor=varargin{i+1};
    end
    if strcmp(varargin{i},'maxBirth')
        maxBirth=varargin{i+1};
    end
    if strcmp(varargin{i},'figName')
        figName=varargin{i+1};
    end
    
    if strcmp(varargin{i},'GT')
        GT=1;
    end
end

if GT==1
    szc=2;
    comment={'Prediction', 'Groundtruth'};
elseif GT==0
    szc=max([rlsfile.condition]); %number of conditions
end
%%
for c=1:szc %conditions
    if GT==0
        rls{c,1}=rlsfile([rlsfile.condition]==c);
        comment{c}=rls{c,1}(1).conditionComment;
    elseif GT==1
        rls{c,1}=rlsfile([rlsfile.groundtruth]==c-1); %c-1 = 1-1 and 2-1 ie 0 and 1
    end
    
    rlst=rls;
    % selection of RLS
    rlst{c,1}=rlst{c,1}([rlst{c,1}.ndiv]>5);
    rlst{c,1}=rlst{c,1}( ([rlst{c,1}.frameBirth]<=maxBirth) & (~isnan([rlst{c,1}.frameBirth])) );%~isnan probably useless
    rlst{c,1}=rlst{c,1}( ~(strcmp({rlst{c,1}.endType},'Arrest') & [rlst{c,1}.frameEnd]<400)  ); %remove weird cells before frame 300 (stop growing)
    rlst{c,1}=rlst{c,1}( ~(strcmp({rlst{c,1}.endType},'Emptied'))); %remove emptied roi
    rlst{c,1}=rlst{c,1}( ~(strcmp({rlst{c,1}.endType},'Clog')  ));%remove clogged roi
    rlstNdivs{c,1}=[rlst{c,1}.ndiv];
    %
end

if dataExport==1
    writecell(rlstNdivs,[filename '.csv']);
end

%% plot

if figExport==1
    lw=0.5;
    fz=8;
else
    lw=1;
    fz=16;
end


%set(gcf,'Color','w','Units', 'Normalized', 'Position',[0.1 0.1 0.45 0.45]);
rlsFig=figure('Color','w','Units', 'Normalized', 'Position',[0.1 0.1 0.45 0.45],'Name',figName);
ax=gca;
colmap=lines;
leg='';
hold on

lcc=1;
for c=1:szc
    col=colmap(c,:);
    [yt,xt,flo,fup]=ecdf(rlstNdivs{c,1});
    xt(1)=0;
    plot(xt,1-yt,'LineWidth',lw,'color',col)
    leg{lcc,1}=[comment{c}, ': Median=' num2str(median(rlstNdivs{c,1})) ' (N=' num2str(length(rlstNdivs{c,1})) ')'];
    lcc=lcc+1;
    %     ax.Children(1).LineWidth=lw;
    %     col=ax.Children(1).Color;
    if confidenceInterval==1
        fup(1)=0;
        fup(end)=1;
        flo(1)=0;
        flo(end)=1;
        closedxt = [xt', fliplr(xt')];
        inBetween = [1-fup', fliplr(1-flo')];
        ptch=patch(closedxt, inBetween,col);
        ptch.EdgeColor=col;
        ptch.FaceAlpha=0.15;
        ptch.EdgeAlpha=0.3;
        ptch.LineWidth=lw;
        leg{lcc,1}='';
        lcc=lcc+1;
    end
    
    
    
    if plotHazardRate==1
        %BOOTSTRAPPING
        if bootStrapping==1
            rlst=rlstNdivs{c,1};
            [y x]=ecdf(rlst);
            
            %cuttof numcell remaining            
            RemainingCells=size(rlst,2)-y*size(rlst,2);
            cutx=find(RemainingCells<=cuty,1,'first');
            cutx=x(cutx);
            %
            dlog=[];
            dt=[];
            deathRate=[];
            meanDR=[];
            stdDR=[];
            meanBDR=[];
            stdBDR=[];
            semBDR=[];
            semDR=[];
            rlsb=[];
            
            [rlsb] = bootstrp(Nboot,@(x)x,rlst);
            rlsb=[rlst; rlsb ]; %add the real one in addition to the bootstrap
            Mx=max(rlstNdivs{c,1}(:));
            mx=min(rlstNdivs{c,1}(:));
            %need to have a stepsize of 1
            Yb=[NaN(Nboot+1,Mx)];
            Xb=[0:Mx-1];
            
            for b=1:Nboot+1
                [yb, xb]=ecdf(rlsb(b,:));
                xb(1)=1;
                for i=1:numel(yb)                    
                    Yb(b,xb(i))=yb(i);                    
                end
                
                %fill NaN with neighbour value
                for i=2:Mx
                    if isnan(Yb(b,i))
                        Yb(b,i)=Yb(b,i-1);
                    end
                end

                
                dlog(b,:)=gradient(log(1-Yb(b,:)));
                dlog(dlog==-Inf)=0;
                dt(b,:)=gradient(Xb);
                deathRate(b,:)=-dlog(b,:)./dt(b,:);
                %                 deathRate(b,:)=diff(Yb(b,:))./(1-Yb(b,2:end));
                %deathRate(deathRate==Inf)=NaN;
                
                %binning
%                 cb=1;
%                 binning=3;
                %                 for i=1:binning:size(deathRate,2)-1
                %                     binnedDeathRate(b,cb)=nanmean([deathRate(b,i),deathRate(b,i+1)]);
                %                     cb=cb+1;
                %                 end
            end
            
            %cutx stop displaying if less than x events
            deathRate(:,cutx:end)=[];
            Xb(:,cutx:end)=[];
            
            meanDR=nanmean(deathRate,1);
            stdDR=nanstd(deathRate,1);
            semDR=stdDR./sqrt(Nboot+1); %N= number of bootstrappings
            
            cb=1;
           % binning
            for i=1:binning:size(deathRate,2)-(binning-1)
                meanBDR(cb)=mean([meanDR(i:i+binning-1)]);%nanmean(binnedDeathRate,1);
                stdBDR(cb)=mean([stdDR(i:i+binning-1)]);%(binnedDeathRate,1);
                semBDR(cb)=stdBDR(cb)/sqrt(Nboot+1); %N= number of bootstrappings
                cb=cb+1;
            end
            
            
            %             lineProps.width=lw;
            %             lineProps.col{:}=col;
            %             %mseb(Xb(2:end),meanDR,stdDR,lineProps);
            %             mseb(Xb(2:2:end-1),meanBDR,stdBDR,lineProps);
            
            %remove nans for polygon, normally useless
            Xb=Xb(~isnan(Xb));
            stdBDR=stdBDR(~isnan(stdBDR));
            semBDR=semBDR(~isnan(semBDR));
            meanBDR=meanBDR(~isnan(meanBDR));
            %plot

            t=1:binning:numel(Xb)-mod(numel(Xb),binning);

            plot(Xb(t),meanBDR,'LineWidth',lw,'color',col,'LineStyle','--')
            closedxb=[];
            shadedstd=[];
            closedxb = [Xb(t), fliplr(Xb(t))];
            shadedstd = [meanBDR-stdBDR, fliplr(meanBDR+stdBDR)];
            ptch=patch(closedxb, shadedstd,col);
            ptch.FaceAlpha=0.15;
            ptch.EdgeAlpha=0.3;
            ptch.LineStyle='--';
            ptch.LineWidth=lw;
            ptch.EdgeColor=col;
            
            leg{lcc,1}=[comment{c}, ': Hazard rate '];
            leg{lcc+1,1}='';
            lcc=lcc+2;
        else
            xtB=[];
            dlog=gradient(log(1-yt));
            dt=gradient(xt);
            deathRate=-dlog./dt;
            
            %binning
            cb=1;
            for i=1:binning:size(deathRate)-(binning-1)
                meanBDR(cb)=mean([deathRate(i:i+binning-1)]);
                xtB(cb)=i;%mean([xt(i:i+binning-1)]); %sloppy but ecdf doesnt give step of 1
                cb=cb+1;
            end
            %t=1:binning:numel(xtB)-mod(numel(xtB),binning);
            
            plot(xtB,meanBDR,'--','LineWidth',lw,'Color',col)
            leg{lcc,1}=[comment{c}, ': Hazard rate '];
            lcc=lcc+1;
        end
    end
end

%p-value
textPvalue='';
if szc>1
    pairs=nchoosek(1:szc,2);
    szp=size(pairs,1);
    for pp=1:szp
        [~,p(pp)]=kstest2(rlstNdivs{pairs(pp,1),1},rlstNdivs{pairs(pp,2),1});
        textPvalue=[textPvalue newline comment{pairs(pp,1)} ' vs ' comment{pairs(pp,2)} ': ' num2str(p(pp))];
    end
end

legend(leg)
text(2,0.25,[textPvalue],'FontSize',fz,'FontWeight','bold');




box on
xlabel('Divisions');
ylabel('Survival');
if plotHazardRate==1
    ylabel(['Survival' newline 'and hazard rate (div^-1)']);
end

M=max([rlstNdivs{:,1}]);
p=0;%ranksum(rlstNdivs,rlsgNdivs);
%title(['Replicative lifespan']);
set(gca,'FontSize',fz, 'FontName','Myriad Pro','LineWidth',2*lw,'FontWeight','bold','XTick',[0:10:M],'TickLength',[0.02 0.02]);
xlim([0 M])
ylim([0 1.02]);


if figExport==1
    ax=gca;
    xf_width=1.8*sz; yf_width=sz;
    set(gcf, 'PaperPositionMode', 'auto', 'PaperType','a4','PaperUnits','centimeters');
    %set(gcf,'Units','centimeters','Position', [5 5 xf_width yf_width]);
    set(ax,'Units','centimeters', 'InnerPosition', [5 5 xf_width yf_width]) %0.8 if .svg is used
    rlsFig.Renderer='painters';
    %saveas(rlsFig,'\\space2.igbmc.u-strasbg.fr\charvin\Theo\Projects\RAMM\Figures\Fig1\RLS\RLS_sir2_fob1.svg')
    exportgraphics(rlsFig,[filename '.pdf']);
    %print(rlsFig,'\\space2.igbmc.u-strasbg.fr\charvin\Theo\Projects\RAMM\Figures\Fig1\RLS\RLS_sir2_fob1','-dpdf')%,'BackgroundColor','none','ContentType','vector')
    %export_fig RLS_sir2_fob1.pdf
end

