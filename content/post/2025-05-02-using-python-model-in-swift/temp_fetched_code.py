"""Example model training solution."""

from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from yellowbrick.classifier import ClassificationReport

# Load data
iris = load_iris()
X, y = iris.data, iris.target

# Load data
X, y = load_iris(return_X_y=True)

# Split data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Train model
model = RandomForestClassifier(random_state=42)
model.fit(X_train, y_train)

# Visualise model results
viz = ClassificationReport(model, support=True, classes=iris.target_names)
viz.score(X_test, y_test)
viz.show()
