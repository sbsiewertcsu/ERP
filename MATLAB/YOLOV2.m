%% Train YOLO v2 Network for Vehicle Detection
% Load the training data for vehicle detection into the workspace.

data = load('vehicleTrainingData.mat');
trainingData = data.vehicleTrainingData;
%% 
% Specify the directory in which training samples are stored. Add full path 
% to the file names in training data. 

dataDir = fullfile(toolboxdir('vision'),'visiondata');
trainingData.imageFilename = fullfile(dataDir,trainingData.imageFilename);
%% 
% Randomly shuffle data for training.

rng(0);
shuffledIdx = randperm(height(trainingData));
trainingData = trainingData(shuffledIdx,:);
%% 
% Create an imageDatastore using the files from the table.

imds = imageDatastore(trainingData.imageFilename);
%% 
% Create a boxLabelDatastore using the label columns from the table.

blds = boxLabelDatastore(trainingData(:,2:end));
%% 
% Combine the datastores.

ds = combine(imds, blds);
%% 
% Load a preinitialized YOLO v2 object detection network.

net = load('yolov2VehicleDetector.mat');
lgraph = net.lgraph
%% 
% Inspect the layers in the YOLO v2 network and their properties. You can also 
% create the YOLO v2 network by following the steps given in <docid:vision_examples#mw_4f6ea50f-8a93-4102-81a3-b2ba83bf7d58 
% Create YOLO v2 Object Detection Network>. 

lgraph.Layers
%% 
% Configure the network training options.

options = trainingOptions('sgdm',...
          'InitialLearnRate',0.001,...
          'Verbose',true,...
          'MiniBatchSize',16,...
          'MaxEpochs',30,...
          'Shuffle','never',...
          'VerboseFrequency',30,...
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

img = imread('detectcars.png');
%% 
% Run the trained YOLO v2 object detector on the test image for vehicle detection.

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