import pandas as pd
import numpy as np
import pickle
import os
from preprocess import preprocess_data

def load_artifacts():
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    models_dir = os.path.join(BASE_DIR, "models")
    with open(os.path.join(models_dir, "full_pipeline.pkl"), "rb") as f:
        pipeline = pickle.load(f)
    with open(os.path.join(models_dir, "feature_names.pkl"), "rb") as f:
        feature_names = pickle.load(f)
    with open(os.path.join(models_dir, "threshold.pkl"), "rb") as f:
        threshold = pickle.load(f)
    return pipeline, feature_names, threshold

def rule_score(input_dict):
    score = 0.0

    # 1. Aggressive Amount Ramp
    try:
        amt = float(input_dict.get("TransactionAmt", 0))
        # Start caring at $500 instead of $1,000
        if amt > 500:
            amt_risk = (amt - 500) / (5000 - 500)
            score += min(amt_risk, 0.6) # Maxes out at 0.6
    except: pass

    # 2. Aggressive Velocity (C1)
    try:
        c1 = float(input_dict.get("C1", 0))
        if c1 > 20: 
            c1_risk = (c1 - 20) / (200 - 20)
            score += min(c1_risk, 0.5)
    except: pass

    # 3. Category Multipliers
    email = str(input_dict.get("P_emaildomain", "")).lower()
    if email == "anonymous.com":
        score += 0.35 
    if input_dict.get("ProductCD") == "C":
        score += 0.30 

    return min(score, 0.98)

def predict(input_dict):
    pipeline, feature_names, threshold = load_artifacts()
    
    # ----------------------------
    # SENSITIVITY OVERRIDE
    # ----------------------------
    # If the tuned threshold is too high (e.g., 0.65), it will NEVER flag fraud.
    # We force a "detection threshold" of 0.40 for high sensitivity.
    effective_threshold = 0.40 

    # 1. Get ML Probability
    input_df = pd.DataFrame([input_dict])
    X_cleaned, _ = preprocess_data(input_df, is_train=False, feature_columns=feature_names)
    X_cleaned = X_cleaned.replace({pd.NA: np.nan}).fillna(np.nan)
    ml_prob = pipeline.predict_proba(X_cleaned)[0][1]

    # 2. Get Gradient Heuristic Score
    h_score = rule_score(input_dict)

    # 3. Combine Logic with Sensitivity Boost
    # We use a 'Max' influence logic: if either signal is strong, the result jumps.
    combined_prob = (0.5 * ml_prob) + (0.5 * h_score)
    
    # The Sensitivity Boost:
    # If probability is over 0.20, we amplify it to help it cross the threshold.
    if combined_prob > 0.20:
        final_prob = combined_prob ** 0.7  # Square root-like curve to pull low values UP
    else:
        final_prob = combined_prob

    # 4. Final Classification
    prediction = 1 if final_prob >= effective_threshold else 0

    return prediction, final_prob