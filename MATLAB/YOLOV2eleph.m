%% Train YOLO v2 Network for Cow Detection

% Make sure GPU is used if machine has one - auto is best, cpu is cpu only, and gpu is gpu only
%executionEnvironment = "auto";
executionEnvironment = "auto";


% used to determine if pre-trained data of any sort is used
doTraining = true;


% Load the training data for eleph detection into the workspace.

data = load('eleDatasetGroundTruth.mat');
trainingData = data.gTruth;
%% 
% Specify the directory in which training samples are stored. Add full path 
% to the file names in training data. 

%dataDir = fullfile(toolboxdir('vision'),'visiondata');
%trainingData.imageFilename = fullfile(dataDir,trainingData.imageFilename);
%% 
% Randomly shuffle data for training.

rng(0);
shuffledIdx = randperm(height(trainingData));
idx = floor(0.6 * length(shuffledIdx));
testData = trainingData(shuffledIdx(idx+1:end),:);
trainingData = trainingData(shuffledIdx(1:idx),:);
%trainingData = trainingData(shuffledIdx,:);

%% 
% Create an imageDatastore using the files from the table.

imds = imageDatastore(trainingData.imageFilename);
imdsTest = imageDatastore(testData.imageFilename);

%% 
% Create a boxLabelDatastore using the label columns from the table.

blds = boxLabelDatastore(trainingData(:,2:end));
bldsTest = boxLabelDatastore(testData(:,2:end));

%% 
% Combine the datastores.

ds = combine(imds, blds);
testData = combine(imdsTest, bldsTest);

if doTraining
    inputSize = [300 300 3]
    numClasses = width(data.gTruth)-1;
    %anchorBoxes = [1 1; 4 6; 5 3;9 6];
    [anchorBoxes,meanIoU] = estimateAnchorBoxes(blds,3);
    net=resnet50();
    %analyzeNetwork(net);
    featureLayer = 'activation_49_relu';
    lgraph = yolov2Layers(inputSize, numClasses,anchorBoxes, net, featureLayer);
    %analyzeNetwork(lgraph);
else
    % Load a preinitialized YOLO v2 object detection network.
    net = load('yolov2VehicleDetector.mat');
    lgraph = net.lgraph
end

%% 
% Inspect the layers in the YOLO v2 network and their properties. You can also 
% create the YOLO v2 network by following the steps given in <docid:vision_examples#mw_4f6ea50f-8a93-4102-81a3-b2ba83bf7d58 
% Create YOLO v2 Object Detection Network>. 

lgraph.Layers
%% 
% Configure the network training options.

% Increase the MaxEpochs
% report every training epoch
% reduce MiniBatchSize from 16 to 8 (GPU memory issue)

options = trainingOptions('sgdm',...
          'InitialLearnRate',0.001,...
          'Verbose',true,...
          'MiniBatchSize',8,...
          'MaxEpochs',30,...
          'Shuffle','never',...
          'VerboseFrequency',1,...
          'CheckpointPath',tempdir);
%% 
% Train the YOLO v2 network.

[detector,info] = trainYOLOv2ObjectDetector(ds,lgraph,options);
%% 
% Inspect the properties of the detector.

detector
%% 
% You can verify the training accuracy by inspecting the training loss for each 
% iteration.

figure
plot(info.TrainingLoss)
grid on
xlabel('Number of Iterations')
ylabel('Training Loss for Each Iteration')
%% 
% Read a test image into the workspace.

img = imread('detecteleph.png');
%% 
% Run the trained YOLO v2 object detector on the test image for eleph detection.

detectionResults = detect(detector, testData, 'Threshold', 0.4);
[ap,recall,precision] = evaluateDetectionPrecision(detectionResults, testData);

figure
plot(recall,precision)
xlabel('Recall')
ylabel('Precision')
grid on
title(sprintf('Average Precision = %.2f',ap))

[bboxes,scores] = detect(detector,img);
%% 
% Display the detection results.

if(~isempty(bboxes))
    img = insertObjectAnnotation(img,'rectangle',bboxes,scores);
end
figure
imshow(img)
%% 
% _Copyright 2018 The MathWorks, Inc._
