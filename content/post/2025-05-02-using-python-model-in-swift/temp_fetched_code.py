"""Example model training solution."""

from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
from sklearn.model_selection import train_test_split

# Load data
iris = load_iris()

X, y = iris.data, iris.target
