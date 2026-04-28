import pandas as pd
import numpy as np
import pickle
import os

from sklearn.model_selection import train_test_split
from sklearn.metrics import f1_score, roc_auc_score, classification_report
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer

# Models
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, IsolationForest
from sklearn.tree import DecisionTreeClassifier
from sklearn.neural_network import MLPClassifier
from xgboost import XGBClassifier

# Imbalanced handling
from imblearn.pipeline import Pipeline as ImbPipeline
from imblearn.over_sampling import SMOTE
from imblearn.under_sampling import RandomUnderSampler

def train_model():
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    data_dir = os.path.join(BASE_DIR, "data")
    models_dir = os.path.join(BASE_DIR, "models")
    os.makedirs(models_dir, exist_ok=True)

    # 1. Load & Merge
    print("--- Loading IEEE Dataset ---")
    train_trans = pd.read_csv(os.path.join(data_dir, "train_transaction.csv"))
    train_id = pd.read_csv(os.path.join(data_dir, "train_identity.csv"))
    df = train_trans.merge(train_id, on="TransactionID", how="left")
    
    # 2. Feature Selection (Strategic set)
    core_cols = ['TransactionAmt', 'ProductCD', 'card1', 'card2', 'card3', 'card4', 'card5', 'card6', 
                 'addr1', 'addr2', 'dist1', 'P_emaildomain', 'R_emaildomain', 'DeviceType', 'DeviceInfo', 'TransactionDT']
    v_cols = [c for c in df.columns if c.startswith('V')][:50] 
    c_cols = [c for c in df.columns if c.startswith('C')]
    d_cols = [c for c in df.columns if c.startswith('D')]
    
    features = list(dict.fromkeys([c for c in (core_cols + v_cols + c_cols + d_cols) if c in df.columns]))
    X = df[features]
    y = df['isFraud']

    numeric_features = X.select_dtypes(include=['int64', 'float64']).columns
    categorical_features = X.select_dtypes(include=['object']).columns

    # 3. Split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

    # 4. Preprocessing Transformers
    num_pipe = ImbPipeline([
        ('imputer', SimpleImputer(strategy='constant', fill_value=-999)),
        ('scaler', StandardScaler())
    ])
    cat_pipe = ImbPipeline([
        ('imputer', SimpleImputer(strategy='constant', fill_value='Unknown')),
        ('onehot', OneHotEncoder(handle_unknown='ignore'))
    ])
    preprocessor = ColumnTransformer([
        ('num', num_pipe, numeric_features),
        ('cat', cat_pipe, categorical_features)
    ])

    # 5. Define Models
    models = {
        "Logistic Regression": LogisticRegression(
            max_iter=1000, class_weight='balanced'),

        "Decision Tree": DecisionTreeClassifier(
            max_depth=15, class_weight='balanced'),

        "Random Forest": RandomForestClassifier(
            n_estimators=100, max_depth=12,
            class_weight='balanced', n_jobs=-1),

        "XGBoost": XGBClassifier(
            n_estimators=200, max_depth=10,
            scale_pos_weight=10, tree_method='hist'),

        "Neural Network": MLPClassifier(
            hidden_layer_sizes=(64, 32), max_iter=100,
            early_stopping=True),

        "Isolation Forest": IsolationForest(
            contamination=0.035, random_state=42)
    }

    results = []
    best_f1 = -1
    best_pipeline = None
    best_model_name = ""
    final_best_threshold = 0.5

    print(f"\n{'Model':<20} | {'F1-Score':<10} | {'AUC':<10} | {'Best Thresh':<10}")
    print("-" * 60)

    for name, model in models.items():
        # Build Pipeline
        if name == "Isolation Forest":
            # Isolation Forest is unsupervised; we don't use SMOTE
            pipeline = ImbPipeline([('preprocessor', preprocessor), ('classifier', model)])
            pipeline.fit(X_train) # Only fits on X
            # Convert decision scores to "probabilities" (0 to 1)
            scores = pipeline.decision_function(X_test)
            y_proba = (scores.max() - scores) / (scores.max() - scores.min())
        else:
            pipeline = ImbPipeline([
                ('preprocessor', preprocessor),
                ('undersample', RandomUnderSampler(sampling_strategy=0.1)),
                ('smote', SMOTE(sampling_strategy=0.3)),
                ('classifier', model)
            ])
            pipeline.fit(X_train, y_train)
            y_proba = pipeline.predict_proba(X_test)[:, 1]

        # Tune Threshold
        m_best_f1 = 0
        m_thresh = 0.5
        for t in np.arange(0.1, 0.7, 0.05):
            f1 = f1_score(y_test, (y_proba > t).astype(int))
            if f1 > m_best_f1:
                m_best_f1 = f1
                m_thresh = t
        
        auc = roc_auc_score(y_test, y_proba)
        print(f"{name:<20} | {m_best_f1:<10.4f} | {auc:<10.4f} | {m_thresh:<10.2f}")

        if m_best_f1 > best_f1:
            best_f1 = m_best_f1
            best_pipeline = pipeline
            best_model_name = name
            final_best_threshold = m_thresh
        m_thresh = min(m_thresh, 0.55)

    # 6. Finalize
    print(f"\n Best Model: {best_model_name} with F1: {best_f1:.4f}")
    
    with open(os.path.join(models_dir, "full_pipeline.pkl"), "wb") as f:
        pickle.dump(best_pipeline, f)
    with open(os.path.join(models_dir, "threshold.pkl"), "wb") as f:
        pickle.dump(final_best_threshold, f)
    with open(os.path.join(models_dir, "feature_names.pkl"), "wb") as f:
        pickle.dump(features, f)

    print("All artifacts saved to /models/")

if __name__ == "__main__":
    train_model()