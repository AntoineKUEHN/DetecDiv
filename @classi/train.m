function train(obj)
% open a training window for a dedicated classification task

%classlist= table([1; 2; 3; 4; 5; 6;],{'Deep Image classification';'Deep Pixel classification';'Deep Object Classification';'Deep Image sequence classification';'ML Pixel classification';'ML single cell tracking'}, ...
 %       {'Googlenet Deep learning' ; 'Deeplab v3+'; 'YOLO v2'; 'LSTM + Googlenet' ; 'Machine learning decision tree'; 'Machine learning decision tree'},{'Image';'Pixel';'Object';'Image';'Pixel';'Tracking'},...
  %      {'NA'; 'NA'; 'NA'; 'NA'; 'NA'; 'NA'},...
  %      {'NA'; 'NA'; 'NA'; 'NA'; 'NA'; 'NA'},...
  %          'VariableNames',{'ID','Name','Description','Category','TrainingFun','ClassificationFun'});
  
  
  obj.view
  
  % change the way view function behaves in order to allow pixel painting
  % and image classification !!!!
