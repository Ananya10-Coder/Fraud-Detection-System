import pandas as pd
import numpy as np
def preprocess_data(df, is_train=True, feature_columns=None):
    """
    Cleans the raw dataframe. 
    In the new pipeline approach, we don't handle scaling or encoding here;
    the Scikit-Learn Pipeline handles that internally.
    """
    # 1. Ensure we are working with a copy to avoid SettingWithCopy warnings
    X = df.copy()

    # 2. Drop Target if it exists and we are in training mode
    y = None
    if is_train and "isFraud" in X.columns:
        y = X["isFraud"]
        X = X.drop(columns=["isFraud"])

    # 3. Drop Identifiers
    if "TransactionID" in X.columns:
        X = X.drop(columns=["TransactionID"])

    # 4. Feature Alignment (CRITICAL)
    # This ensures that the columns going into the model are exactly the ones
    # the model was trained on, in the exact same order.
    if feature_columns is not None:
        # Add missing columns with NaN (the pipeline's Imputer will handle them)
        for col in feature_columns:
            if col not in X.columns:
                X[col] = np.nan
        
        # Select and reorder columns to match the training set
        X = X[feature_columns]

    return X, y