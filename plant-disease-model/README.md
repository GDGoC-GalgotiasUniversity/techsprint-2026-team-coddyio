# Plant Disease Detection Model

This repository contains a PyTorch model trained to detect plant diseases from leaf images. Using the Mendeley Plant Disease Dataset, the model identifies 39 different classes of plant diseases, including healthy plants and background images. This model can be used to assist farmers and agricultural experts in early disease detection and proactive treatment.

## Model Details

- **Framework**: PyTorch
- **Dataset**: [Mendeley Plant Disease Dataset](https://data.mendeley.com/)  
- **Classes**: 39 (Various plant diseases and background images)
- **Parameters**:
  - Total: 52,595,399
  - Trainable: 52,595,399
  - Non-trainable: 0
- **Model Size**: 345.17 MB

## Dataset

This model was trained on the **Mendeley Plant Disease Dataset**, which contains **61,486 images** spread across 39 classes. Each class represents a specific plant disease or a healthy plant leaf. Data augmentation techniques were applied to increase the dataset size and improve model robustness.

### Data Augmentation Techniques

To make the model more resilient and enhance its accuracy, the following data augmentation techniques were used:
1. **Image Flipping**
2. **Gamma Correction**
3. **Noise Injection**
4. **PCA Color Augmentation**
5. **Rotation**
6. **Scaling**

These augmentations help the model generalize better to new and varied images, reducing the risk of overfitting.

## Model Architecture

The model architecture is built using convolutional layers with batch normalization and ReLU activations, followed by pooling and dropout layers for better feature extraction and generalization. The architecture concludes with fully connected (linear) layers for classification.

| Layer (Type)       | Output Shape         | Parameters |
|--------------------|----------------------|------------|
| Conv2d-1           | [-1, 32, 224, 224]   | 896        |
| ReLU-2             | [-1, 32, 224, 224]   | 0          |
| BatchNorm2d-3      | [-1, 32, 224, 224]   | 64         |
| Conv2d-4           | [-1, 32, 224, 224]   | 9,248      |
| ReLU-5             | [-1, 32, 224, 224]   | 0          |
| BatchNorm2d-6      | [-1, 32, 224, 224]   | 64         |
| MaxPool2d-7        | [-1, 32, 112, 112]   | 0          |
| Conv2d-8           | [-1, 64, 112, 112]   | 18,496     |
| ReLU-9             | [-1, 64, 112, 112]   | 0          |
| BatchNorm2d-10     | [-1, 64, 112, 112]   | 128        |
| Conv2d-11          | [-1, 64, 112, 112]   | 36,928     |
| ReLU-12            | [-1, 64, 112, 112]   | 0          |
| BatchNorm2d-13     | [-1, 64, 112, 112]   | 128        |
| MaxPool2d-14       | [-1, 64, 56, 56]     | 0          |
| Conv2d-15          | [-1, 128, 56, 56]    | 73,856     |
| ReLU-16            | [-1, 128, 56, 56]    | 0          |
| BatchNorm2d-17     | [-1, 128, 56, 56]    | 256        |
| Conv2d-18          | [-1, 128, 56, 56]    | 147,584    |
| ReLU-19            | [-1, 128, 56, 56]    | 0          |
| BatchNorm2d-20     | [-1, 128, 56, 56]    | 256        |
| MaxPool2d-21       | [-1, 128, 28, 28]    | 0          |
| Conv2d-22          | [-1, 256, 28, 28]    | 295,168    |
| ReLU-23            | [-1, 256, 28, 28]    | 0          |
| BatchNorm2d-24     | [-1, 256, 28, 28]    | 512        |
| Conv2d-25          | [-1, 256, 28, 28]    | 590,080    |
| ReLU-26            | [-1, 256, 28, 28]    | 0          |
| BatchNorm2d-27     | [-1, 256, 28, 28]    | 512        |
| MaxPool2d-28       | [-1, 256, 14, 14]    | 0          |
| Dropout-29         | [-1, 50176]          | 0          |
| Linear-30          | [-1, 1024]           | 51,381,248 |
| ReLU-31            | [-1, 1024]           | 0          |
| Dropout-32         | [-1, 1024]           | 0          |
| Linear-33          | [-1, 39]             | 39,975     |

### Key Parameters

- **Input Size**: 0.57 MB
- **Forward/Backward Pass Size**: 143.96 MB
- **Parameter Size**: 200.64 MB
- **Total Estimated Model Size**: 345.17 MB

## Model Usage

To use the model for plant disease detection, follow the steps below:

```python
import torch

# Load the model (assuming the model file is `plant_disease_model.pth`)
model = torch.load('plant_disease_model.pth')
model.eval()

# Example usage with a sample image
from PIL import Image
from torchvision import transforms

# Preprocess the image
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

image = Image.open('sample_leaf.jpg')
input_tensor = transform(image).unsqueeze(0)  # Add batch dimension

# Make prediction
with torch.no_grad():
    output = model(input_tensor)
    predicted_class = output.argmax(dim=1).item()

print(f"Predicted Class: {predicted_class}")


**Web**: [Link](https://plant-dd-co9k.onrender.com)   
