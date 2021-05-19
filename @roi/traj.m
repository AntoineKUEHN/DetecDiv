function h=traj(obj,classistr,varargin)

% trajectory 

% classistr represents the strid of the classifier to be displayed

% option is the particular class id to be be represented as probability;
% default : 1

idclas=1;
hidefig=0;
comment='';
for i=1:numel(varargin)
    %hide
    if strcmp(varargin{i},'Hide')
        hidefig=varargin{i+1};
    end

    if strcmp(varargin{i},'Comment')
        comment=varargin{i+1};
    end
    
    if strcmp(varargin{i},'option')
        idclas=varargin{i+1};
    end
end

if numel(obj.results)==0
    disp('There is no result available for this position');
    return;
end

if ~isfield(obj.results,classistr)
    disp('There is no result available for this classification id');
    return;
end

if numel(obj.image)==0
   obj.load; 
end

% find class names
classes={};
cc=1;
for i=1:max(obj.results.(classistr).id)
    pix=find(obj.results.(classistr).id==i,1,'first');
    classes{cc}=char(obj.results.(classistr).labels(pix));
    cc=cc+1;
end
    
if hidefig==1
h=figure('Tag',['Traj' num2str(obj.id)],'Color','w','Units', 'Normalized', 'Position',[0 0 1 1],'Visible','off');
else
h=figure('Tag',['Traj' num2str(obj.id)],'Color','w','Units', 'Normalized', 'Position',[0 0 1 1]);
end

acla=subplot(2,1,1);
set(gca,'FontSize',20);

% if roi was used for user training, display the training data first

str={};

if numel(obj.train)~=0
    x=1:numel(obj.train.(classistr).id);
    y=obj.train.(classistr).id;
    
    plot(x,y,'Color','k','LineWidth',3); hold on;
    str{1}= 'Groundtruth';
end

% then display the results 

xr=1:numel(obj.results.(classistr).id);
yr=obj.results.(classistr).id;
plot(xr,yr,'Color','r','LineWidth',2); hold on;

% ============compute accuracy================
acc= 100*sum(yr==y)./length(y);
 str{end+1}=['Classification results; ' num2str(acc) '% accurate'];
 
% CNN results
if isfield(obj.results.(classistr),'idCNN')
    xrCNN=1:numel(obj.results.(classistr).idCNN);
    yrCNN=obj.results.(classistr).idCNN;
    plot(xrCNN,yrCNN,'Color','g','LineWidth',1); hold on;
    accCNN= 100*sum(yrCNN==y)./length(y);
    str{end+1}=['Classification results CNN; ' num2str(accCNN) '% accurate'];
end

str2=str;

pix=find(x==obj.display.frame);
line([x(pix) x(pix)],[1 max(obj.results.(classistr).id)],'Color',[0.5 0.5 0.5],'LineWidth',2,'Tag','track');
str{end+1}='Cursor position';

legend(str);

 hl=findobj(h,'Tag','track');
 
ylim([0 max(obj.results.(classistr).id)+1]);
set(acla,'YTick',1:max(obj.results.(classistr).id),'YTickLabel',classes,'Fontsize',14);

title([comment ' - ' classistr ' - classification results for ROI ' obj.id],'Interpreter','none');
ylabel('Classes');

aprob=subplot(2,1,2);

    
if numel(obj.train)~=0
    x=1:numel(obj.train.(classistr).id);
    y=obj.train.(classistr).id==idclas;
    plot(x,y,'Color','k','LineWidth',3); hold on;
end

% then display the results

if isfield(obj.results.(classistr),'prob')
prob=obj.results.(classistr).prob;

  if   numel(obj.results.(classistr).classes)~=size(obj.results.(classistr).prob,1)
      prob=prob';
  end
    
xr=1:numel(prob(idclas,:));
yr=prob(idclas,:);

plot(xr,yr,'Color','r','LineWidth',1,'LineStyle','-','Marker','.','MarkerSize',15); hold on;

% if isfield(obj.results.(classistr),'probCNN')
% probCNN=obj.results.(classistr).probCNN;
% 
%   if   numel(obj.results.(classistr).classes)~=size(obj.results.(classistr).probCNN,1)
%       probCNN=probCNN';
%   end
%     
% xr=1:numel(probCNN(idclas,:));
% yr=probCNN(idclas,:);
% 
% plot(xr,yr,'Color','g','LineWidth',1,'LineStyle','-','Marker','.','MarkerSize',15); hold on;
% end

% displays the result prab after lstm surclassification

if isfield(obj.results.(classistr),'probcorr')
    
    probcorr=obj.results.(classistr).probcorr;

  %if   numel(obj.results.(classistr).classes)~=size(obj.results.(classistr).prob,1)
  %    prob=prob';
  %end
    
xr=1:numel(probcorr(idclas,:));
yr=probcorr(idclas,:);

plot(xr,yr,'Color','g','LineWidth',2,'LineStyle','-','Marker','.','MarkerSize',5); hold on;
str2{end+1}='Reclassification LSTM';
end

legend(str2);

ylim([0 1]);

xlabel('Time (frames)');
ylabel(['P( class =  '  obj.results.(classistr).classes{1} ')']);

set(gca,'FontSize',16);

%ylabel('Budding state');
%set(gca,'YTick',[0 1 2],'YTickLabel',{'unbbuded','small b','large b'})

 %hp(2)=subplot(2,1,2);
 
 %obj.plotrls('plot','handle',hp(2));
 %xlim([0 x(end)])
 


%set(h,'WindowButtonDownFcn',{@wbdcb,xdiff,fluodiff,obj.div.raw,obj.div.classi});

h.KeyPressFcn={@changeframe2,obj,h};
end

function changeframe2(handle,event,obj,h)

% if strcmp(event.Key,'uparrow')
% val=str2num(handle.Tag(5:end));
% han=findobj(0,'tag','movi')
% han.trap(val-1).view;
% delete(handle);
% end

if strcmp(event.Key,'rightarrow')
    if obj.display.frame+1>size(obj.image,4)
    return;
    end
obj.display.frame=obj.display.frame+1;

    obj.view;
   
    hl=findobj(h,'Tag','track');
    if numel(hl)>0
    hl.XData=[obj.display.frame obj.display.frame];
    end
   % ok=1;
   
end

if strcmp(event.Key,'leftarrow')
    if obj.display.frame-1<1
    return;
    end
obj.display.frame=obj.display.frame-1;
obj.view;
   % obj.view(obj.frame-1);
    hl=findobj(h,'Tag','track');
    if numel(hl)>0
    hl.XData=[obj.display.frame obj.display.frame];
    end
    %ok=1;
end
hf=findobj('Tag',['Traj' num2str(obj.id)]);
figure(hf);







