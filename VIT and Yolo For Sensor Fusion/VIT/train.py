import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from torchvision.datasets import CIFAR10
from torch.optim import Adam
from model import PretrainedVisionTransformer
from preprocess import get_transforms

def train():
    # Hyperparameters
    num_classes = 10
    lr = 3e-4
    epochs = 10

    # Model, optimizer, loss
    model = PretrainedVisionTransformer(num_classes)
    optimizer = Adam(model.parameters(), lr=lr)
    criterion = nn.CrossEntropyLoss()

    # Data
    transform = get_transforms(img_size=224)
    train_dataset = CIFAR10(root='./data', train=True, download=True, transform=transform)
    train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True, num_workers=4)

    # Training loop
    for epoch in range(epochs):
        model.train()
        for images, labels in train_loader:
            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()

        print(f"Epoch {epoch+1}/{epochs}, Loss: {loss.item()}")

    # Save the trained model
    torch.save(model.state_dict(), 'pretrained_vit_model.pth')

if __name__ == "__main__":
    train()
