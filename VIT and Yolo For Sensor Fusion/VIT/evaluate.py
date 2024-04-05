import torch
from torch.utils.data import DataLoader
from torchvision.datasets import CIFAR10
from model import PretrainedVisionTransformer
from preprocess import get_transforms

def evaluate():
    # Model
    model = PretrainedVisionTransformer(num_classes=10)
    model.load_state_dict(torch.load('pretrained_vit_model.pth'))
    model.eval()

    # Data
    transform = get_transforms(img_size=224)
    test_dataset = CIFAR10(root='./data', train=False, download=True, transform=transform)
    test_loader = DataLoader(test_dataset, batch_size=32, shuffle=False, num_workers=4)

    correct = 0
    total = 0

    with torch.no_grad():
        for images, labels in test_loader:
            outputs = model(images)
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()

    accuracy = correct / total
    print(f"Accuracy on the test set: {accuracy * 100:.2f}%")

if __name__ == "__main__":
    evaluate()
