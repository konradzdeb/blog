---
title: Bring your Python ML model to your iOS App in Three Minutes
author: Konrad Zdeb
date: '2025-05-02'
slug: python-models-ape
categories:
  - how-to
tags:
  - swift
  - ML
  - Python
---





Arrival of CoreML Framework in June 2017 open up an exciting possibility of productionings models on Apple devices. This is particularly attractive in the context of deploying ML-reliant applications on mobile devices, offering access to a significant market. In order to introduce a ML solution into a Swift-based software product `.mlmodel` file would need to be produced. The two common mechanisms facilitating that process are:
1. Leveraging Apple's Create ML App or Create ML framework (for programmatic model creation)
2. Leveraging `coremltools` Python package and preparing model elsewhere to be imported into the production


## Model Development

For the purpose of demonstration we will create basic modelling solution in Python. As I'm looking to classify some images, I will create a simple Convolutional Neural Network (CNN) using PyTorch. The model will be trained on Fashion-MNIST dataset, which is a collection of 70,000 grayscale images of fashion items (clothing, shoes, etc.) in 10 categories. I will start from sourcing a standard set of packages required for the model development.

```python
 """Train a classifier on Fashion-MNIST and print performance summary."""

import torch
import torch.mps
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
import coremltools as ct

import numpy as np
import pandas as pd

from sklearn.metrics import classification_report
from torch.utils.data import Dataset
from torchvision import datasets, transforms
 
```

The model represents a fairly unsophisticated approach to handle imaghe classification task. Naturally, in a producting setting you will want to utilise more sophisticated solution, handling complex data and scenarios where you could be dealing with distorted images data (low lighting, different angles, etc.). The provided CNN implementation is fairly basic but sufficient for the purpose of this demonstration. It consists of a few convolutional layers, followed by fully connected layers, and uses ReLU activation functions. The model is trained using the Adam optimizer and cross-entropy loss function.

```python
 
# Load Fashion-MNIST
transform = transforms.ToTensor()
train_set = datasets.FashionMNIST(
    root="./data", train=True, download=True, transform=transform,
)
test_set = datasets.FashionMNIST(
    root="./data", train=False, download=True, transform=transform,
)

# Use the class labels from the dataset
FASHION_LABELS = train_set.classes


class SimpleCNN(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv = nn.Sequential(
            nn.Conv2d(1, 32, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2),
            nn.Conv2d(32, 64, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2)
        )
        self.fc = nn.Sequential(
            nn.Flatten(),
            nn.Linear(64 * 7 * 7, 128),
            nn.ReLU(),
            nn.Linear(128, 10)
        )

    def forward(self, x):
        x = self.conv(x)
        return self.fc(x)


train_loader = DataLoader(train_set, batch_size=64, shuffle=True)
val_loader = DataLoader(test_set, batch_size=64, shuffle=False)

device = torch.device("mps")
model = SimpleCNN().to(device)
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.001)

for epoch in range(5):
    model.train()
    for images, labels in train_loader:
        images, labels = images.to(device), labels.to(device)
        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()

model.eval()
all_preds = []
all_labels = []
with torch.no_grad():
    for images, labels in val_loader:
        images = images.to(device)
        outputs = model(images)
        preds = outputs.argmax(dim=1).cpu().numpy()
        all_preds.extend(preds)
        all_labels.extend(labels.numpy())
print(classification_report(all_labels, all_preds, 
```
### Testing the Model
In addittion to testing the model for performance, we also tet model's ability to handle images passed as flat files. For that purpose, I will build trivial ficture in PyTest to feed a few images to the model and check if the model is able to predict the label of the image. The test will be run against a few images sourced from public domain.

```python
 """Test model on a few sample images."""

import os
import pytest
import numpy as np
from PIL import Image, ImageOps
import coremltools as ct
from tabulate import tabulate

@pytest.fixture(scope="module")
def model():
    model_path = os.path.join(os.path.dirname(__file__), "../FashionMNISTClassifier.mlpackage")
    return ct.models.MLModel(model_path)

def preprocess_image(image_path):
    with Image.open(image_path) as img:
        if img.mode != "L":
            img = img.convert("L")
        img = ImageOps.invert(img)
        img = img.resize((28, 28))
        return img

results = []

# Create parametrized test for different image files
@pytest.mark.parametrize("filename", ["t-shirt.jpeg", "pullover.jpg"])
def test_model_prediction(filename, model):
    fixtures_dir = os.path.join(os.path.dirname(__file__), "fixtures")
    img_path = os.path.join(fixtures_dir, filename)
    arr = preprocess_image(img_path)
    input_data = {"image": arr}
    expected_label = os.path.splitext(filename)[0]
    output = model.predict(input_data)
    predicted_label = str(output["classLabel"])
    match = expected_label.lower() in predicted_label.lower()

    results.append((filename, expected_label, predicted_label, "✅" if match else "❌"))
    assert match, f"{filename}: expected {expected_label}, got {predicted_label}"

def pytest_sessionfinish(session, exitstatus):
    if results:
        print("\n\nModel Prediction Results:\n")
        print(tabulate(results, headers=["Filename", "Expected", "Predicted", "Match"])) 
```

### Convert to Core ML

The key challenge would be brining the model into the  Swift and incorporating the modelling solution in the iOS application. We will export model to the `.mlpackage` format using avilable converters. The key element we want to take care of ensuring that our model will be able to handle the required input format. In this case images, we accomplish that objective by defining the `inpute_features` and `output_features`.

The point that deserves most attention relates to how the `input_features` list is being created. This object is critical when converting a scikit-learn model to Core ML format using `coremltools`. In this example, the input features are defined as `input_features = [("image", ct.models.datatypes.Array(1, 28, 28))]`, which means the Core ML model expects a single-channel (grayscale) image of size 28x28 as input. This matches the shape of Fashion-MNIST images and ensures the model can process image data correctly in your iOS application. 

Why this is important? When you convert a scikit-learn model to Core ML, the input features must match the expected input shape of the model. If the input features are not defined correctly, the conversion will fail or the resulting Core ML model will not work as intended in your iOS application.

```python
                             target_names=FASHION_LABELS))

example_input = torch.rand(1, 1, 28, 28).to(device)
traced = torch.jit.trace(model, example_input)
classifier_config = ct.ClassifierConfig(class_labels=FASHION_LABELS)
mlmodel = ct.convert(
    traced,
    inputs=[ct.ImageType(name="image",
                         shape=(1, 1, 28, 28), 
                         scale=1/255.0,
                         color_layout=ct.colorlayout.GRAYSCALE)],
    classifier_config=classifier_config
)
mlmodel.save("FashionMNISTClassifier.mlpackage")
print("Exported CoreML model to FashionMNISTClassifier.mlpackage") 
```

## Use in Swift

Initially we will need to import the model to XCode project. This can be done by dragging and dropping the `.mlpackage` file into the Xcode project navigator. Once the model is imported, we can use it in our Swift code. Upon the import the model will be available as a class with the same name as the `.mlpackage` file. In this case, it will be `FashionMNISTClassifier`.

