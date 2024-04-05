import torch
import torch.nn as nn
from torchvision import models

class PretrainedVisionTransformer(nn.Module):
    def __init__(self, num_classes):
        super(PretrainedVisionTransformer, self).__init__()

        # Load pre-trained ViT model from torchvision
        self.vit_model = models.vit_base_patch16_224(pretrained=True)
        
        # Modify the classifier to match the desired number of classes
        self.vit_model.head = nn.Linear(self.vit_model.head.in_features, num_classes)

    def forward(self, x):
        return self.vit_model(x)
