"""Train a classifier on Fashion-MNIST and print performance summary."""

import joblib

import numpy as np

from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split
from torch.utils.data import Dataset
from torchvision import datasets, transforms

# Load Fashion-MNIST
transform = transforms.ToTensor()
train_set = datasets.FashionMNIST(
    root="./data", train=True, download=True, transform=transform,
)
test_set = datasets.FashionMNIST(
    root="./data", train=False, download=True, transform=transform,
)


def dataset_to_numpy(dataset: Dataset) -> tuple[np.ndarray, np.ndarray]:
    """Convert dataset to numpy arrays.

    Args:
        dataset (Dataset): The dataset to convert.

    Returns:
        tuple: A tuple containing the features and labels as numpy arrays.

    """
    x = dataset.data.numpy().reshape(len(dataset), -1)
    y = dataset.targets.numpy()
    return x, y


X_train_full, y_train_full = dataset_to_numpy(train_set)
X_test, y_test = dataset_to_numpy(test_set)

# Train/val split
X_train, X_val, y_train, y_val = train_test_split(
    X_train_full, y_train_full, test_size=0.2, random_state=42, stratify=y_train_full
)

# Train classifier
model = RandomForestClassifier(n_estimators=100, random_state=42, n_jobs=-1)
model.fit(X_train, y_train)

# Predict and evaluate
y_pred = model.predict(X_val)

print(f"Model Accuracy: {accuracy_score(y_val, y_pred):.3f}")

# Export model
joblib.dump(model, "fashion_mnist_rf_model.joblib")
print("Model exported to: fashion_mnist_rf_model.joblib")
