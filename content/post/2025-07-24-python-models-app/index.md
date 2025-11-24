---
title: Bring your Python ML Model to iOS App in under Three Minutes
author: Konrad Zdeb
date: '2025-07-24'
slug: python-models-app
categories:
  - how-to
tags:
  - Swift
  - ML
  - Python
---





![Phone Model Demo](images/phonedemo.gif)

Integrating Python-based machine learning models into iOS applications can be challenging, particularly when converting models into a Swift-compatible format. This example will demonstrate a simple image classification task using the Fashion-MNIST dataset and CoreML conversion tools. The goal is to illustrate the effort required to deploy small-to-medium complexity ML models within iOS applications. The demonstration is based on a Convolutional Neural Network (CNN) built with PyTorch, but the concepts apply broadly to other Python-based models as well.

## Model Development

For demonstration purposes, we'll create a basic machine learning model in Python. To classify images, I'll build a simple Convolutional Neural Network (CNN) using PyTorch. The model will be trained on the Fashion-MNIST dataset, comprising 70,000 grayscale images of fashion items in 10 categories. We'll begin by sourcing a standard set of Python packages required for model development.

```python
 """Train a classifier on Fashion-MNIST and print performance summary."""

import torch
import torch.mps
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
import coremltools as ct

from sklearn.metrics import classification_report
from torchvision import datasets, transforms

 
```

The model represents a fairly unsophisticated approach to handle image classification task. Naturally, in a production setting you will want to utilise more sophisticated solution, handling complex data and scenarios where you could be dealing with distorted images data (low lighting, different angles, etc.). The provided CNN implementation is fairly basic but sufficient for the purpose of this demonstration. It consists of a few convolutional layers, followed by fully connected layers, and uses ReLU activation functions. The model is trained using the Adam optimizer and cross-entropy loss function.

```python
     root="./data", train=True, download=True, transform=transform,
)
test_set = datasets.FashionMNIST(
    root="./data", train=False, download=True, transform=transform,
)

## Use the class labels from the dataset
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
                            target_names=FASHION_LABELS)) 
```

## Additional Testing

In addition to evaluating model performance, we'll also test its ability to handle images provided as flat files. The tests will run against several publicly available images.

```python
 """Test model on a few sample images."""

import os
import pytest
from PIL import Image, ImageOps
import coremltools as ct
from tabulate import tabulate

@pytest.fixture(scope="module")
def model():
    model_path = os.path.join(os.path.dirname(__file__),
                              "../FashionMNISTClassifier.mlpackage")
    return ct.models.MLModel(model_path)

def preprocess_image(image_path):
    with Image.open(image_path) as img:
        if img.mode != "L":
            img = img.convert("L")
        img = ImageOps.invert(img)
        img = img.resize((28, 28))
        return img

results = []

## Create parametrized test for different image files
@pytest.mark.parametrize("filename", ["t-shirt.jpeg", "pullover.jpg", "bag.jpeg"])
def test_model_prediction(filename, model):
    fixtures_dir = os.path.join(os.path.dirname(__file__), "fixtures")
    img_path = os.path.join(fixtures_dir, filename)
    arr = preprocess_image(img_path)
    input_data = {"image": arr}
    expected_label = os.path.splitext(filename)[0]
    output = model.predict(input_data)
    predicted_label = str(output["classLabel"])
    match = expected_label.lower() in predicted_label.lower()

    results.append((filename, expected_label, predicted_label,
                    "✅" if match else "❌"))
    assert match, f"{filename}: expected {expected_label}, got {predicted_label}"

def pytest_sessionfinish(session, exitstatus):
    if results:
        print("\n\nModel Prediction Results:\n")
        print(tabulate(results, headers=["Filename", "Expected",
                                         "Predicted", "Match"])) 
```

## Converting to Core ML

A key challenge is converting and integrating the model into the Swift-based iOS application. We'll export the model into the `.mlpackage` format using available conversion tools. It's critical to ensure our model can correctly handle the required input format—in this case, images—by defining the `input_features` and `output_features`.

Proper definition of these objects is crucial when converting models (including scikit-learn) to Core ML format using `coremltools`. In this example, the input features are defined as `input_features = [("image", ct.models.datatypes.Array(1, 28, 28))]`. This configuration means the Core ML model expects a single-channel (grayscale) image of size 28x28 as input, matching the Fashion-MNIST images. This alignment ensures correct image processing within your iOS application.

Why is this important? If input features do not match the expected model shape, conversion will fail, or the resulting Core ML model may not function correctly in your app.

```python
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

First, we need to import the model into our Xcode project by dragging and dropping the `.mlpackage` file into the Xcode project navigator. After importing, the model becomes available as a Swift class sharing its `.mlpackage` file name—`FashionMNISTClassifier` in this example. Inference is performed using the straightforward `predict` method, with most heavy lifting managed by the `FashionMNISTClassifierInput` class.

```swift
 //  Created by Konrad on 30/06/2025.
//

import CoreML
import Foundation
import UIKit

class ModelViewModel: ObservableObject {
    @Published var predictedLabel: String = "No prediction yet"

    private let model: FashionMNISTClassifier

    init?() {
        guard let model = try? FashionMNISTClassifier(
            configuration: .init()) else {
            return nil
        }
        self.model = model
    }

    func predict(from image: UIImage) {
        guard let resized = ImagePreprocessor.preprocess(image) else {
            predictedLabel = "Preprocessing failed"
            return
        }

        let input = FashionMNISTClassifierInput(image: resized)

        guard let result = try? model.prediction(input: input) else {
            predictedLabel = "Prediction failed"
            return
        }

        predictedLabel = result.classLabel
    }
} 
```

## Image Pre-processing

The Swift `ImagePreprocessor` struct provides a static method to convert a `UIImage` into a 28×28 grayscale-formatted `CVPixelBuffer`. The method resizes the image, converts it to grayscale, and produces a pixel buffer ready for inference with Core ML.

```swift
 //  Created by Konrad on 30/06/2025.
//

import UIKit
import CoreImage
import CoreML

struct ImagePreprocessor {
    static func preprocess(_ image: UIImage,
                        size: CGSize = CGSize(width: 28, height: 28)) -> CVPixelBuffer? {
        let width = Int(size.width)
        let height = Int(size.height)
        
        var pixelBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_OneComponent8,
            attrs,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
            return nil
        }
        
        guard let cgImage = image.cgImage else {
            CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0,
                     width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
        
        return buffer
    }
} 
```

## Final Considerations

I've used a recent version of PyTorch to leverage Metal Performance Shaders (MPS)—Apple’s framework enabling GPU acceleration on Apple Silicon and Intel Macs. Although my chosen PyTorch version wasn't officially tested with Core ML Tools, it functioned without issue. However, for robustness, ensure compatibility between PyTorch and Core ML library versions.

If your use case involves image classification, consider exploring Apple’s Vision Foundation Models. These models are optimized for on-device performance and simplify common image classification tasks significantly. Alternatively, if sticking with PyTorch is important, consider using **PyTorch Mobile**. PyTorch Mobile lets you run PyTorch models natively on-device, offering enhanced control with minimal translation between training and inference environments.

The entire project, including training scriptts, conversion logic, and Swift application code, is available through the GitHub repository: [https://github.com/konradzdeb/SwiftPythonML](https://github.com/konradzdeb/SwiftPythonML).
