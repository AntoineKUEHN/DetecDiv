function [results,image]=classifyImageRegressionLSTMFun(roiobj,classif,classifier,varargin)

%load([path '/netCNN.mat']); % load the googlenet to get the input size of image

% now load and read video
fprintf('Load videos...\n');

%inputSize = netCNN.Layers(1).InputSize(1:2);

for i=1:numel(classifier.Layers)
    if strcmp(class(classifier.Layers(i)), 'nnet.cnn.layer.SequenceInputLayer')
inputSize = classifier.Layers(i).InputSize(1:2);
break
    end
end

channel=classif.channelName;

for i=1:numel(varargin)
    if strcmp(varargin{i},'classifierCNN')
    net=classifierCNN;
    inputSizeCNN = net.Layers(1).InputSize;
    classNamesCNN = net.Layers(end).ClassNames;
    numClassesCNN = numel(classNamesCNN);
    end
      if strcmp(varargin{i},'Frames')
          % not yet implemented
      end
        if strcmp(varargin{i},'Channel')
           channel=varargin{i+1};
       end
end

% if nargin==4 % standard classification is requested 
% net=classifierCNN;
% %inputSizeCNN = net.Layers(1).InputSize;
% %classNamesCNN = net.Layers(end).ClassNames;
% %numClassesCNN = numel(classNamesCNN);
% end

%return;
% x y size of the input movie (140th layer)


%for i=id
%fprintf(['Processing video:' num2str(i) '...\n']);
%load([mov.path '/labeled_video_' mov.trap(i).id '.mat']); % loads deep, vid, lab (categories of labels)

if numel(roiobj.image)==0
    roiobj.load;
end

pix=roiobj.findChannelID(channel);

    if iscell(pix)
            pix=cell2mat(pix);
    end
    
%pix=find(roiobj.channelid==classif.channel(1)); % find channels corresponding to trained data
im=roiobj.image(:,:,pix,:); 

disp('Formatting video before classification....');
%size(im)

vid=uint8(zeros(size(im,1),size(im,2),3,size(im,4)));

for j=1:size(im,4)
    param=[];
    tmp=roiobj.preProcessROIData(pix,j,param);
    im(:,:,:,j)=uint8(256*tmp);
    vid(:,:,:,j)=uint8(256*tmp);
end


%vid=vid(:,:,:,1:388);

%inputSize
%size(vid)

gfp = imresize(vid,inputSize(1:2));
video = centerCrop(vid,inputSize);


%size(video)
%aa=classifier.Layers

% nframes=inputSize(1);
% narr=floor(size(im,4)/nframes);
% nrem=mod(size(im,4),nframes);
% 
% if nrem>0
%     narr=narr+1;
% end
% 
% videoout={};
% 
% %if size(im,4)>nframes
% for i=1:narr
%     if i==narr
%         ende=(i-1)*nframes+nrem;
%     else
%         ende=i*nframes ;
%     end
%    videoout{i}=video(:,:,:,(i-1)*nframes+1:ende);
% end
% %else
% %   videoout{1}=video;
% %end
% 
% %size(videoout)
% %size(videoout{1})
% %size(videoout{3})

disp('Starting video classification...');

% this function predict  is used instead of 'classify' function which causes an error
% on R2019b

try
    
prob=predict(classifier,video); 
%probCNN=predict(classifierCNN,video);
probCNN =predict(classifierCNN,gfp);
catch 
    
disp('Error with predict function  : likely out of memory issue with GPU, trying CPU computing...');
prob=predict(classifier,video,'ExecutionEnvironment', 'cpu');
%probCNN=predict(classifierCNN,video,'ExecutionEnvironment', 'cpu');
if nargin==4
probCNN = predict(classifierCNN,gfp);
end
end
  
% labels = classifier.Layers(end).Classes;
% if size(prob,1) == numel(labels) % adjust matrix depending on matlab version 
%    prob=prob';
% end
%  [~, idx] = max(prob,[],2);
%  label = labels(idx);
 
 %if size(probCNN,1) == numel(labels) % adjust matrix depending on matlab version 
 %  probCNN=probCNN';
%end
 %[~, idx] = max(probCNN,[],2);
 %labelCNN = labels(idx);
 
%  [~, idx] = max(prob,[],2);
%  label = labels(idx);
% %label = classify(classifier,video,'ExecutionEnvironment', 'cpu'); % in case the gpu crashes because of out of memory
% % prob=activations(classifier,video,'softmax','OutputAs','channels','ExecutionEnvironment', 'cpu');
% end

%label=[];

% lab=[];
% %if size(im,4)>nframes
% for i=1:narr
%    lab = [lab label{i}];
% end
%else
   %label=label{1}; 
%end

%label=lab(1:size(im,4));

results=roiobj.results;

    results.(classif.strid)=[];
    results.(classif.strid).id=prob; %zeros(1,size(im,4));
    %results.(classif.strid).labels=label';
   % results.(classif.strid).classes=classif.classes;
   % results.(classif.strid).prob=prob';
    
%     for i=1:numel(classif.classes)
%    pix=label==classif.classes{i};
%    results.(classif.strid).id(pix)=i;
%     end
    
    if nargin==4
    results.(classif.strid).idCNN=probCNN'; %zeros(1,size(im,4));
%     results.(classif.strid).labelsCNN=labelCNN';
%     results.(classif.strid).classesCNN=classif.classes;
%     
%     results.(classif.strid).probCNN=flipud(probCNN'); % fix orientation of array here !!!!
    
%     for i=1:numel(classif.classes)
%    pix=labelCNN==classif.classes{i};
%    results.(classif.strid).idCNN(pix)=i;
%     end
     end
    
    
image=roiobj.image;
%roiobj.results=results; 

%roiobj.save;
%roiobj.clear;

%roiout=roiobj;

%roiobj.clear;    

% results.id=roiobj.id;
% results.path=roiobj.path;
% results.parent=roiobj.parent;
% 
% % stores results locally during classification
% 
% if exist([classif.path '/' classif.strid '_results.mat']) % this filles needs to be removed when classification starts ? 
%     load([classif.path '/' classif.strid '_results.mat']) % load res variable
%     n=length(res);
%     res(n+1)={results};
% else
%     
%    res={results}; 
% end
% save([classif.path '/' classif.strid '_results.mat'],'res');
% pix=label=='largebudded';
% mov.trap(i).div.deepLSTM(pix)=2;
%
% pix=label=='smallbudded';
% mov.trap(i).div.deepLSTM(pix)=1;
%
% pix=label=='unbudded';
% mov.trap(i).div.deepLSTM(pix)=0;


%mov.trap(i).div.deepLSTM=YPred;



function videoResized = centerCrop(video,inputSize)

sz = size(video);

if sz(1) < sz(2)
    % Video is landscape
    idx = floor((sz(2) - sz(1))/2);
    video(:,1:(idx-1),:,:) = [];
    video(:,(sz(1)+1):end,:,:) = [];
    
elseif sz(2) < sz(1)
    % Video is portrait
    idx = floor((sz(1) - sz(2))/2);
    video(1:(idx-1),:,:,:) = [];
    video((sz(2)+1):end,:,:,:) = [];
end

videoResized = imresize(video,inputSize(1:2));


%analyzeNetwork(lgraph)




%etc ...