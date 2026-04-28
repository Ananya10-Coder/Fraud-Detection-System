import streamlit as st
import pandas as pd
from predict import predict

# Set page config at the very top
st.set_page_config(page_title="Fraud Detection System", layout="wide", page_icon="💳")

# ----------------------------
# Custom CSS for styling
# ----------------------------
st.markdown("""
    <style>
    .main {
        background-color: #f5f7f9;
    }
    .stButton>button {
        width: 100%;
        border-radius: 5px;
        height: 3em;
        background-color: #ff4b4b;
        color: white;
        font-weight: bold;
    }
    </style>
    """, unsafe_allow_html=True)

# ----------------------------
# Title & Header
# ----------------------------
st.title("💳 Real-Time Fraud Detection System")

# ----------------------------
# Sidebar - Feature Inputs
# ----------------------------
st.sidebar.header("🔧 Transaction Details")

with st.sidebar.expander("Basic Info", expanded=True):
    TransactionAmt = st.number_input("Transaction Amount ($)", min_value=0.0, value=150.0)
    ProductCD = st.selectbox("Product Code", ["W", "C", "R", "H", "S"])
    TransactionDT = st.number_input("Transaction Time Delta", min_value=0, value=86400)

with st.sidebar.expander("Card & Address", expanded=True):
    card1 = st.number_input("Card ID (card1)", min_value=0, value=15000)
    card2 = st.number_input("Card ID (card2)", min_value=0, value=321)
    addr1 = st.number_input("Billing Region (addr1)", min_value=0, value=299)
    dist1 = st.number_input("Distance (dist1)", min_value=0, value=10)

with st.sidebar.expander("Technical & Domain", expanded=False):
    P_emaildomain = st.selectbox("Email Domain", ["gmail.com", "yahoo.com", "anonymous.com", "hotmail.com", "outlook.com"])
    DeviceType = st.selectbox("Device Type", ["desktop", "mobile", "tablet"])
    C1 = st.slider("Count Feature (C1)", 0, 500, 1) 
    V1 = st.slider("Vesta Feature (V1)", 0, 10, 1)

# ----------------------------
# Data Preparation
# ----------------------------
input_data = {
    "TransactionAmt": TransactionAmt,
    "ProductCD": ProductCD,
    "card1": card1,
    "card2": card2,
    "addr1": addr1,
    "dist1": dist1,
    "P_emaildomain": P_emaildomain,
    "DeviceType": DeviceType,
    "TransactionDT": TransactionDT,
    "C1": C1,
    "V1": V1
}

# ----------------------------
# Main Panel
# ----------------------------
col1, col2 = st.columns([2, 1])

with col1:
    st.subheader("📊 Input Data Summary")
    st.dataframe(pd.DataFrame([input_data]), use_container_width=True)

    # All probability logic is contained inside this button block
    if st.button("🚀 Run Fraud Analysis"):
        with st.spinner("Analyzing transaction patterns..."):
            pred, prob = predict(input_data)
        
        st.divider()
        st.subheader("🔍 Prediction Result")
        
        if pred == 1:
            st.error(f"### ⚠️ HIGH RISK: FRAUD DETECTED")
            st.write(f"The model identifies this transaction as highly suspicious.")
        else:
            st.success(f"### ✅ LOW RISK: LEGITIMATE")
            st.write(f"The model identifies this transaction as safe.")

        # Risk Visualization
        st.write(f"**Calculated Fraud Probability:** `{prob:.2%}`")
        
        # Determine color for the bar
        color = "red" if prob > 0.6 else "orange" if prob > 0.3 else "green"
        
        st.markdown(f"""
            <div style="width: 100%; background-color: #ddd; border-radius: 10px;">
                <div style="width: {prob*100}%; background-color: {color}; padding: 10px; color: white; border-radius: 10px; text-align: center; transition: width 0.5s;">
                    {prob:.2%} Risk Score
                </div>
            </div>
            """, unsafe_allow_html=True)

with col2:
    st.subheader("💡 Rule-Based Insights")
    
    risk_found = False
    if TransactionAmt > 5000:
        st.warning("• Exceptional Transaction Amount")
        risk_found = True
    if P_emaildomain == "anonymous.com":
        st.warning("• Non-standard Email Domain")
        risk_found = True
    if C1 > 100:
        st.warning("• High Frequency Count (C1)")
        risk_found = True
    
    if not risk_found:
        st.info("No immediate heuristic red flags detected. Analysis relies on model weights.")

# ----------------------------
# Footer
# ----------------------------
st.markdown("---")
st.caption("Fraud Detection System - Using ML and Custom Heuristics")