function trainImageGoogleNetFun(classif,setparam,inputnetwork)

path=fullfile(classif.path);
name=classif.strid;

flagCNN=[];

%---------------- parameters setting
if nargin==2 % basic parameter initialization
        
        tip={'Choose the training method',...
            'Choose the CNN',...
            'Choose the size of the mini batch; Higher values require more memory and are prone to errors',...
            'Enter the number of epochs',...
            'Enter the initial learning rate',...
            'Enter the learning rate drop factor',...
            'Choose whether and how training and validation data should be shuffled during training',...
            'Enter fraction of the data to be used for training vs validation during training',...
            'Enter the magnitude of translation for data augmentation (in pixels)',...
            'Enter the magnitude of rotation for data augmentation (in pixels)',...
            'Specify value for L2 regularization',...
            'Choose execution environment',...
            'Select initial version of network to start training with; Default: ImageNet'};
        
        classif.trainingParam=struct('CNN_training_method',{{'adam','sgdm','adam'}},...
            'CNN_network',{{'googlenet','inceptionresnetv2','inceptionv3','resnet18','resnet50','resnet101','nasnetlarge','inceptionresnetv2', 'efficientnetb0','googlenet'}},...
            'CNN_mini_batch_size',8,...
            'CNN_max_epochs',6,...
            'CNN_initial_learning_rate',0.0003,...
            'CNN_learn_rate_drop_factor',0.9,...
            'CNN_data_shuffling',{{'once','every-epoch','never','every-epoch'}},...
            'CNN_data_splitting_factor',0.7,...
            'CNN_translation_augmentation',[-5 5],...
            'CNN_rotation_augmentation',[-20 20],...
            'CNN_l2_regularization',0.00001,...
            'execution_environment',{{'auto','parallel','cpu','gpu','multi-gpu','auto'}},...
            'transfer_learning',{{'ImageNet','ImageNet'}},...
            'tip',{tip});
        
        return;
        %   end
    else
        trainingParam=classif.trainingParam;
        
        if numel(trainingParam)==0
            disp('Could not find training parameters : first launch train with an extra argument to force parameter assignment');
            return;
        end
        
        if nargin==3  % input network is provided to be used instad of a virgin network 
            flagCNN=inputnetwork;
        end
        
    end
    %-----------------------------------%

% gather all classification images in each class and performs the training and outputs and saves the trained net 
% load training data 
blockRNG=1;

fprintf('Loading data repository...\n');
fprintf('------\n');

foldername=[path '/trainingdataset/images'];
if ~exist(foldername)
disp('Folder does not  exist; first export images for training; quitting !')
return;
end
imds = imageDatastore(foldername, ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames'); 

classWeights = 1./countcats(imds.Labels);
classWeights = classWeights'/mean(classWeights);

fprintf('------\n');

[imdsTrain,imdsValidation] = splitEachLabel(imds,trainingParam.CNN_data_splitting_factor);

classes = classif.classes;
%numel(categories(imdsTrain.Labels));

if numel(classes)==0
disp('There is no classes defined ; Cannot continue !')
return;
end

fprintf('Loading network...\n');
fprintf('------\n');

if strcmp(trainingParam.transfer_learning{end},'ImageNet')  % creates a new network
disp('Generating new network');
net=eval(trainingParam.CNN_network{end});

fprintf('Reformatting net for transfer learning...\n');
fprintf('------\n');

% formatting the net for transferred learning
% extract the layer graph from the trained network 
if isa(net,'SeriesNetwork') 
  lgraph = layerGraph(net.Layers); 
else
  lgraph = layerGraph(net);
end

[learnableLayer,classLayer] = findLayersToReplace(lgraph);
sz=size(learnableLayer.Weights);
numClasses = numel(categories(imdsTrain.Labels));
cates=categories(imdsTrain.Labels);
%numClasses = numel(classes);

% adjust the final layers of the net
if isa(learnableLayer,'nnet.cnn.layer.FullyConnectedLayer')
    newLearnableLayer = fullyConnectedLayer(numClasses, ...
        'Name','new_fc', ...
        'WeightLearnRateFactor',1, ...
        'BiasLearnRateFactor',1);
 %      'Weights',rand(numClasses,sz(2)),'Bias',zeros(numClasses,1));
    
elseif isa(learnableLayer,'nnet.cnn.layer.Convolution2DLayer')
    newLearnableLayer = convolution2dLayer(1,numClasses, ...
        'Name','new_conv', ...
        'WeightLearnRateFactor',1, ...
        'BiasLearnRateFactor',1);
end

lgraph = replaceLayer(lgraph,learnableLayer.Name,newLearnableLayer);

%newClassLayer = classificationLayer('Name','new_classoutput');
newClassLayer = weightedClassificationLayer(classWeights,'new_classoutput');%,cates);

lgraph = replaceLayer(lgraph,classLayer.Name,newClassLayer);

%fprintf('Freezing layers...\n');

% freezing layers
% if strcmp(trainingParam.freeze,'y')
% layers = lgraph.Layers;
% connections = lgraph.Connections;
% 
%  layers(1:10) = freezeWeights(layers(1:10)); % only googlenet
%  lgraph = createLgraphUsingConnections(layers,connections); % onlygooglnet
% end
else
     disp(['Loading previously trained CNN network associated with: ' trainingParam.transfer_learning{end}]);
     
    if numel(flagCNN)
        lgraph = layerGraph(flagCNN)  ;
        net=flagCNN;
    else
         strpth=fullfile(classif.path,  trainingParam.transfer_learning{end});
         if exist(strpth)
             load(strpth); %loads classifier
             lgraph = layerGraph(classifier);
             net=classifier;
         else
             disp(['Unable to load: ' trainingParam.transfer_learning{end}]);
            return;
        end
    end
end

inputSize = net.Layers(1).InputSize;

fprintf('Training network...\n');
fprintf('------\n');

    %=====BLOCKs RNG====
    if blockRNG==1
        stCPU= RandStream('Threefry','Seed',0,'NormalTransform','Inversion');
        stGPU=parallel.gpu.RandStream('Threefry','Seed',0,'NormalTransform','Inversion');
        RandStream.setGlobalStream(stCPU);
        parallel.gpu.RandStream.setGlobalStream(stGPU);
    end
    %===================

pixelRange = trainingParam.CNN_translation_augmentation;
rotation=trainingParam.CNN_rotation_augmentation;
%=trainingParam.CNN_rotation_augmentation;

% below add a scaling factor 
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandYReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange, ...
     'RandRotation',rotation);% , ...

augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
    'DataAugmentation',imageAugmenter);

% here add an outsize 
miniBatchSize = trainingParam.CNN_mini_batch_size; %8
valFrequency = floor(numel(augimdsTrain.Files)/miniBatchSize);

%augimdsTrain = transform(augimdsTrain,@classificationAugmentationPipeline,'IncludeInfo',true);

augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);

if ~isfield(trainingParam,'CNN_learn_rate_drop_factor')
    trainingParam.CNN_learn_rate_drop_factor=0.9;
end

options = trainingOptions(trainingParam.CNN_training_method{end}, ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',trainingParam.CNN_max_epochs, ...
    'InitialLearnRate',trainingParam.CNN_initial_learning_rate, ...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',2,...
    'LearnRateDropFactor',trainingParam.CNN_learn_rate_drop_factor,...
    'GradientThreshold',0.5, ...
    'L2Regularization',trainingParam.CNN_l2_regularization, ...
    'Shuffle',trainingParam.CNN_data_shuffling{end}, ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',valFrequency, ...
    'VerboseFrequency',10,...
    'Plots','training-progress',...
    'ExecutionEnvironment',trainingParam.execution_environment{end});

classifier = trainNetwork(augimdsTrain,lgraph,options);

fprintf('Training is done...\n');
fprintf('Saving image classifier ...\n');
fprintf('------\n');

%[path '/' name '.mat']

save([path '/' name '.mat'],'classifier');
CNNOptions=struct(options);

CNNOptions.ValidationData=[];

if ~exist(fullfile(path,'TrainingValidation'))
    mkdir(path,'TrainingValidation');
end

save([path '/TrainingValidation/' 'CNNOptions' '.mat'],'CNNOptions');
save([path '/TrainingValidation/' 'tmpoptions' '.mat'],'options');

% layers = freezeWeights(layers) sets the learning rates of all the
% parameters of the layers in the layer array |layers| to zero.
% saveTrainingPlot(path,'CNNTraining');
 
function layers = freezeWeights(layers)

for ii = 1:size(layers,1)
    props = properties(layers(ii));
    for p = 1:numel(props)
        propName = props{p};
        if ~isempty(regexp(propName, 'LearnRateFactor$', 'once'))
            layers(ii).(propName) = 0;
        end
    end
end

% lgraph = createLgraphUsingConnections(layers,connections) creates a layer
% graph with the layers in the layer array |layers| connected by the
% connections in |connections|.
        
function lgraph = createLgraphUsingConnections(layers,connections)

lgraph = layerGraph();
for i = 1:numel(layers)
    lgraph = addLayers(lgraph,layers(i));
end

for c = 1:size(connections,1)
    lgraph = connectLayers(lgraph,connections.Source{c},connections.Destination{c});
end


