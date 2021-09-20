function stats(classif,varargin)
outputstr='temp';
% compute, displays and stores statististics regarding the selected classification

% roiid is an array of roiid from the object classi


roiid=1:numel(classif.roi);
datasetType='';
thr=[];
plo=[];


for i=1:numel(varargin)
    %Method
    if strcmp(varargin{i},'Rois')
        roiid=varargin{i+1};
    end
    
    if strcmp(varargin{i},'Dataset')
        datasetType=varargin{i+1};
    end
    
    if strcmp(varargin{i},'Threshold') % measures benchmarks for different thresholds used to for classification and segmentation. Use thr=-1 to use a custom thresholding method in the @post function; thr=0 for max proba
        thr=varargin{i+1};
    end
    
    if strcmp(varargin{i},'Plot') % can be {'id',2,'roi','classes','confusion','accuracyrecall',2} to display benchmarks per roi, classes, confusion, or accuracyrecall tradeoff, id plots only the data for specific score values 
        % if accuracyrecall is selected, then
        plo=varargin{i+1};
    end
    
end


if numel(plo)==0 % do not compute if plot is requested
    
    disp(['Stats will be done on the following ROIs: ' num2str(roiid)]);
    
    path=classif.path;
    name=classif.strid;
    strpath=[path '/' outputstr '_' name];
    classistr=classif.strid;
    
    cc=1;
    classif.score=[];
    
    if numel(thr)==0
        neval=1;
    else
        neval=thr;
    end
    
    for i=neval % loop on possible thr values
        
        % apply postprocessing with given threshold
        if  classif.typeid==2 ||  classif.typeid==8 % does a postprocessing to create segmented image with given threshold
            for j=roiid
                switch i
                    case 0
                        classif.roi(j).postprocessing(classif,'OutputFun',@post,'OutputArg',{'maxproba'},'NoSave');
                    case -1
                        classif.roi(j).postprocessing(classif,'OutputFun',@post,'OutputArg',{'adaptivethreshold'},'NoSave');
                    otherwise
                        classif.roi(j).postprocessing(classif,'OutputFun',@post,'OutputArg',{'threshold',i},'NoSave');
                end
            end
        end
        
        data=collectROIData(classif,roiid);  % collect prediction and ground truth data
        
        if data.reg==1 % regression 
            figure('Color','w'); 
            plot(data.gt,data.pred,'Marker','.','Markersize',10,'LineStyle','none'); hold on;
            plot([0 max(max(data.gt),max(data.pred))],[0 max(max(data.gt),max(data.pred))],'LineStyle','--','LineWidth',2,'Color','k');
            c=corrcoef(data.gt,data.pred);
            xlim([0 max(max(data.gt),max(data.pred))]);
            ylim([0 max(max(data.gt),max(data.pred))]);
            
            xlabel('SEP Groundtruth');
            ylabel('SEP Prediction');
            text(2,2,['R^2= ' num2str(c(1,2))]);  
        else %  classification
            
        if cc==1
            classif.score= measureAccuracyRecall(classif,data.gt, data.pred, data.roi);  % score for given classification
            classif.score.comments='Classification benchmarks using main classifier';
            classif.score.thr=i;
        else
            classif.score(cc)= measureAccuracyRecall(classif,data.gt, data.pred, data.roi);  % score for given classification
            classif.score(cc).comments='Classification benchmarks using main classifier';
            classif.score(cc).thr=i;
        end
        
        if classif.typeid==4 % for LSTM classification, compute CNN benchmarks
            cc=cc+1;
            classif.score(cc)= measureAccuracyRecall(classif,data.gt, data.CNNpred, data.roi);  % score for given classification
            classif.score(cc).comments='Classification benchmarks using CNN classifier for LSTM architecture';
            classif.score(cc).thr=i;
        end
        end
        
        cc=cc+1;
    end
    
else
    nscore=1:numel(classif.score);
    
      for i=1:numel(plo)
           if strcmp(plo{i},'id') 
               nscore=plo{i+1};
           end
      end
      
    for i=1:numel(plo)
        
        for j=nscore
            
            
            if strcmp(plo{i},'confusion') % plot confusion matrix;
                mate=classif.score(j).confusion;
                cate=categorical(classif.classes);
                h=figure;
                cm=confusionchart(mate,cate,'ColumnSummary','column-normalized','RowSummary','row-normalized');
                xlabel('Predicted class');
                ylabel('Groundtruth');
                
                str=num2str(classif.score(j).thr);
                
                if classif.score(j).thr==0
                    str='max';
                end
                
                if classif.score(j).thr==-1
                    str='mean';
                end
                
                title(['Dataset:' datasetType ' - N=' num2str(classif.score(j).N) ' - thr=' str]);
                set(h,'Color','w','Position',[100+30*j 100+30*j 600 400])
            end
       % end
        
       % for j=1:numel(classif.score)
            if strcmp(plo{i},'roi') % plots accuracy, recall, fscore per roi
                
                roi=classif.score(j).roi;
                
                h=figure;
                recall=[];
                accuracy=[];
                fscore=[];
                str={};
                
                
                for k=1:numel(roi)
                    recall=[recall roi(k).recall];
                    accuracy=[accuracy roi(k).accuracy];
                    fscore=[fscore roi(k).fscore];
                    str{k}=[ 'ROI #' num2str(roi(k).id)  ' (N='  num2str(roi(k).N) ')'];
                end
                
                %  x=[x 2];
                x=1:numel(roi);
                y=[recall;  accuracy ; fscore];
                bar(x,y');
                ylim([0 100]);
                set(gca,'XTickLabel',str)
                legend({'Accuracy','Recall','F-score'});
                title(['Dataset:' datasetType ' - N=' num2str(classif.score(j).N) ' - Benchmark per ROI']);
                set(h,'Color','w','Position',[100+30*j 100+30*j 600 400])
                xlabel('ROI Id');
                ylabel('Benchmark (%)');
            end
        %end
        
        
      %  for j=1:numel(classif.score)
            if strcmp(plo{i},'classes') % plots accuracy, recall, fscore per classes
                
                classes=classif.score(j).classes;
                
                h=figure;
                recall=[];
                accuracy=[];
                fscore=[];
                str={};
                
                for k=1:numel(classes)
                    recall=[recall classes(k).recall];
                    accuracy=[accuracy classes(k).accuracy];
                    fscore=[fscore classes(k).fscore];
                    str{k}=[classif.classes{k} '  (N='  num2str(classes(k).N) ')'];
                end
                
                  str2=num2str(classif.score(j).thr);
                
                if classif.score(j).thr==0
                    str2='max';
                end
                
                if classif.score(j).thr==-1
                    str2='mean';
                end
                
                %  x=[x 2];
                x=1:numel(classes);
                y=[recall;  accuracy ; fscore]';
                bar(x,y);
                ylim([0 100]);
                set(gca,'XTickLabel',str)
                legend({'Accuracy','Recall','F-score'});
                title(['Dataset:' datasetType ' - N=' num2str(classif.score(j).N) ' - Benchmark per class - thr=' str2]);
                set(h,'Color','w','Position',[100+30*j 100+30*j 600 400])
                xlabel('Class');
                ylabel('Benchmark (%)');
            end
        end
        
        
       % for j=1:numel(classif.score)
            if strcmp(plo{i},'accuracyrecall') % plots accuracy, recall, fscore per classes
                
                cl1=[];% table for thr=-1
                cl2=[]; % table for thr=0
                cl3=[]; % table for thr>0
                
                cla=plo{i+1};
                
                
                
                 for j=nscore

                     switch classif.score(j).thr
                         case -1
                             cl1=[-1; classif.score(j).classes(cla).recall ; classif.score(j).classes(cla).accuracy ; classif.score(j).classes(cla).fscore];
                         case 0
                             cl2=[0; classif.score(j).classes(cla).recall ; classif.score(j).classes(cla).accuracy ; classif.score(j).classes(cla).fscore];
                         otherwise
                             cl3=[cl3 , [ classif.score(j).thr ; classif.score(j).classes(cla).recall ; classif.score(j).classes(cla).accuracy ; classif.score(j).classes(cla).fscore]];
                     end
                 end
                 
              
                str={};
                
                h=figure;
                ax1=subplot(2,1,1);
         
                if numel(cl3)
                %  x=[x 2];
                x=cl3(2,:);
                y=cl3(3,:);
                
                
                plot(x,y,'LineWidth',3,'Color','b'); hold on
                str=[str, {'Varying prediction threshold'}];
                
                [pix id]=max(cl3(4,:));
                xmax=cl3(2,id);
                ymax=cl3(3,id);
                
                plot(xmax,ymax,'LineWidth',3,'Color','b','Marker','.','MarkerSize',30); hold on
                str=[str, {'Max Fscore'}];
                end
                
                if numel(cl2)
                     xmax=cl2(2,1);
                    ymax=cl2(3,1);
                   plot(xmax,ymax,'LineWidth',3,'Color','r','Marker','.','MarkerSize',30); hold on
                   str=[str, {'Max proba'}];
                end
                
                if numel(cl1)
                     xmax=cl1(2,1);
                    ymax=cl1(3,1);
                   plot(xmax,ymax,'LineWidth',3,'Color','m','Marker','.','MarkerSize',30); hold on
                   str=[str, {'Mean threshold'}];
                end
                
                
                ylim([0 100]);
                xlim([0 100]);
 
                legend(str);
                title(['Dataset:' datasetType ' Recall/Accuracy plot for class ' classif.classes{cla}]);
                set(h,'Color','w','Position',[200 200 600 400])
                xlabel('Recall (%)');
                ylabel('Accuracy (%)');
                
                ax2=subplot(2,1,2);
                      
                if numel(cl3)
                %  x=[x 2];
                x=cl3(1,:);
                y=cl3(4,:);
                
               
                
                
                plot(x,y,'LineWidth',3,'Color','b'); hold on
                
                  [pix id]=max(cl3(4,:));
                xmax=cl3(1,id);
                ymax=cl3(4,id);
                
                
                
                plot(xmax,ymax,'LineWidth',3,'Color','b','Marker','.','MarkerSize',30); hold on
                
                str=[str, {'Varying prediction threshold'}];
                 xlabel('Predition threshold');
                 ylabel('F-score (%)');
                  ylim([0 100]);
                 xlim([0 1]);
                 
                 disp(['Score id at max: ' num2str(id)]);
                 disp(['Threshold max: ' num2str(xmax)]);
                 disp(['Accuracy at max: ' num2str(cl3(3,id))]);
                  disp(['Recall at max: ' num2str(cl3(2,id))]);
                    disp(['Fscore at max: ' num2str(cl3(4,id))]);
                    
                  end
                
                  
                  
            end
        end
end


function score=measureAccuracyRecall(classif, groundtruth, predictions, roi)


data=[];
data.gt=groundtruth;
data.pred=predictions;
data.roi=roi;

% ===== accuracy & recall per class ====

score=[];
score.classes=[];
score.thr=[];
score.comments='';
score.classes.accuracy=[];
score.classes.recall=[];
score.classes.fscore=[];
score.classes.N=[];

for i=1:numel(classif.classes)
    
    pred=data.pred==i;
    gt=   data.gt==i;
    
    accuracy= 100*sum(pred & gt)./sum(pred);
    recall=       100*sum(pred & gt)./sum(gt);
    
    score.classes(i).accuracy=accuracy;
    score.classes(i).recall=recall;
    score.classes(i).fscore=2*recall*accuracy/(accuracy+recall);
    score.classes(i).N=sum(pred);
end

% ======= confusion matrix ======
mate=confusionmat(data.gt,data.pred);
score.confusion=mate; % matrix coeff must match acc and recall values computed above

% ===== accuracy & recall & fscore per ROI =====

score.roi=[];
score.roi.accuracy=[];
score.roi.recall=[];
score.roi.fscore=[];
score.roi.N=[];

score.roi.classes=[];
score.roi.classes.accuracy=[];
score.roi.classes.recall=[];
score.roi.classes.fscore=[];
score.roi.classes.N=[];
score.roi.id=[];

roiid=unique(data.roi);

cc=1;
for i=roiid
    
    pred=data.pred(data.roi==i);
    gt=data.gt(data.roi==i);
    
    for j=1:numel(classif.classes)
        
        predtmp=pred==j;
        gttmp=   gt==j;
        
        accuracy= 100*sum(predtmp & gttmp)./sum(predtmp);
        recall=       100*sum(predtmp & gttmp)./sum(gttmp);
        
        score.roi(cc).classes(j).accuracy=accuracy;
        score.roi(cc).classes(j).recall=recall;
        score.roi(cc).classes(j).fscore=2*recall*accuracy/(accuracy+recall);
        score.roi(cc).classes(j).N=sum(predtmp);
    end
    score.roi(cc).id=i;
    
    acc=[score.roi(cc).classes(:).accuracy];
    rec=[score.roi(cc).classes(:).recall];
    csw=@(x) sum(pred==x);
    weights=arrayfun(csw,1:numel(classif.classes));
    
    % remove classes of 0 weights / NaN accuracy
    pix=~isnan(acc);
    acc=acc(pix);
    rec=rec(pix);
    weights=weights(pix);
    
    score.roi(cc).accuracy=  sum(weights.*acc)./sum(weights);
    score.roi(cc).recall    =  sum(weights.*rec)./sum(weights);
    score.roi(cc).fscore=2*score.roi(cc).accuracy* score.roi(cc).recall  ./(score.roi(cc).accuracy+ score.roi(cc).recall  );
    score.roi(cc).N=sum(pred);
    cc=cc+1;
end

% ===== weighted mean  accuracy & recall & fscore ======

acc=[score.classes(:).accuracy];
rec=[score.classes(:).recall];
csw=@(x) sum(data.pred==x);
weights=arrayfun(csw,1:numel(classif.classes));

% remove classes of 0 weights / NaN accuracy
pix=~isnan(acc);
acc=acc(pix);
rec=rec(pix);
weights=weights(pix);

accuracy=  sum(weights.*acc)./sum(weights);
recall     =  sum(weights.*rec)./sum(weights);

score.accuracy=accuracy;
score.recall=recall;
score.fscore=2*accuracy*recall./(accuracy+recall);
score.N=sum([score.classes(:).N]);


function data=collectROIData(classif,roiid)

disp('Collecting data in ROIs - first checking the existence of both GT and predictions....');

data=[];
data.roi=[];
data.gt=[];
data.pred=[];
data.CNNpred=[];
classistr=classif.strid;

for j=roiid
    obj=classif.roi(j);
    disp([num2str(j) ' - '  obj.id ' - checking data']);
    
    % classiid represents the strid of the classifier to be displayed
    
    resok=0;
    ground=0;
    
    gt=[];
    pred=[];
    CNNpred=[];
    
    reg=0;
    
    switch classif.typeid
        case {2,8} % pixel classification
            
            chgt=obj.findChannelID(classif.strid);
            chpred=obj.findChannelID(['results_' classif.strid]);
            
            if numel(obj.image)==0 % loads the image
                obj.load;
            end
            im=obj.image;
            
            if numel(chgt)>0 % groundtruth channel exists
                % checks if at least one image has been annotated  first!
                
                imgt=im(:,:,chgt,:);
                if sum(imgt(:))>0 % at least one image was annotated
                    disp('GT data are available!');
                    ground=1;
                else
                    disp('there is no GT data !')
                end
            else
                disp('there is no GT channel ')
            end
            
            
            if numel(chpred)>0
                impred=im(:,:,chpred,:);
                if sum(impred(:))>0 % at least one image was annotated
                    disp('Predictions data are available!');
                    resok=1;
                else
                    disp('there is no pred data !')
                end
            else
                disp('There is no prediction channel available for this roi');
            end
            
            if ground && resok
                %  for gt, if at least one pixel on the image is annotated, then
                %  take the whole image as annotated and fill in with
                %  default class
                for k=1:size(imgt,4)
                    bw=imgt(:,:,1,k);
                    if sum(bw(:))>0
                        bw= imgt(:,:,1,k);
                        bw(imgt(:,:,1,k)==0)=1;
                        imgt(:,:,1,k) = bw;
                    end
                end
                
                pix= imgt & impred;
                
                if numel(pix)==0
                    disp('There is no coincidence for ground truth and prediction : skipping roi !');
                    continue
                else
                    disp('GT and prediction pixels match!');
                end
                
                gt= imgt(pix); gt=gt(:); gt=gt';
                pred=impred(pix); pred=pred(:); pred=pred';
                
            end
         
            case {13} % timeseries classification or regression 
                
                  if numel(obj.results)>0 % check is there are results available
                if isfield(obj.results,classistr)
                    if isfield(obj.results.(classistr),'id') % it's a classification
                        
                           if numel(obj.results.(classistr).id) > 0
                      %  if sum(obj.results.(classistr).id)>0 % training exists for this ROI !
                            resok=1;
                    %    end
                           end
                    
                    else % it s a regression
                      
                    if numel(obj.results.(classistr).prob) > 0
                      %  if sum(obj.results.(classistr).id)>0 % training exists for this ROI !
                            resok=1;
                            reg=1;
                    %    end
                    end
                    end
                else
                    disp('There is no result available for this classification id');
                end
            else
                disp('There is no result available for this roi');
            end
            
            % if roi was used for user training, display the training data first
            if numel(obj.train)~=0
                if isfield(obj.train,classistr)
                    if numel(obj.train.(classistr).id) > 0
                       % if sum(obj.train.(classistr).id)>0 % training exists for this ROI !
                            ground=1;
                      %  end
                    end
                else
                    disp('There is no GT available for this classification id');
                end
            else
                disp('There is no GT available for this roi');
            end
            
            if ground && resok
                
                 if isfield(obj.results.(classistr),'id') % it's a classification
                pred=double(obj.results.(classistr).id);
                 else
                      pred=double(obj.results.(classistr).prob);
                 end
                gt=double(obj.train.(classistr).id);
            end
                
        otherwise % image classification
            % first check if somm post processing is to be done, ie
            % threshold >0 , otherwise , use image classification as is
            %             if threshold>0
            %                 if numel(obj.results)>0 % check is there are results available
            %                     if isfield(obj.results,classistr)
            %                         if numel(obj.results.(classistr).prob) > 0 % proba exist
            %                             proba= obj.results.(classistr).prob;
            %
            %                         end
            %                     end
            %                 end
            %             end
            
            
            if numel(obj.results)>0 % check is there are results available
                if isfield(obj.results,classistr)
                    if numel(obj.results.(classistr).id) > 0
                        if sum(obj.results.(classistr).id)>0 % training exists for this ROI !
                            resok=1;
                        end
                    end
                else
                    disp('There is no result available for this classification id');
                end
            else
                disp('There is no result available for this roi');
            end
            
            % if roi was used for user training, display the training data first
            if numel(obj.train)~=0
                if isfield(obj.train,classistr)
                    if numel(obj.train.(classistr).id) > 0
                        if sum(obj.train.(classistr).id)>0 % training exists for this ROI !
                            ground=1;
                        end
                    end
                else
                    disp('There is no GT available for this classification id');
                end
            else
                disp('There is no GT available for this roi');
            end
            
            if ground && resok
                
                pred=obj.results.(classistr).id;
                gt=obj.train.(classistr).id;
                
                if isfield(obj.results.(classistr),'idCNN')
                    if numel(obj.results.(classistr).idCNN)>0
                        CNNpred=obj.results.(classistr).idCNN;
                    end
                end
                
                pix= pred & gt;
                
                if numel(pix)==0
                    disp('There is no coincidence for ground truth and prediction : skipping roi !');
                    continue
                end
                
                gt=gt(pix);
                pred=pred(pix);
                
                if numel(CNNpred)>=numel(pix)
                    CNNpred=CNNpred(pix);
                end
            end
    end
    % then display the results
    
    % if ground ==1 && resok==1 % list of rois used to compute stats
    data.gt=[data.gt gt];
    data.pred=[data.pred pred];
    data.CNNpred=[data.CNNpred CNNpred];
    data.roi=[data.roi j*ones(1,numel(gt))];
    data.reg=reg;
    %end
    
end

