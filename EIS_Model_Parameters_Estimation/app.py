import streamlit as st
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

from scipy.optimize import least_squares

from sklearn.preprocessing import StandardScaler
from sklearn.neural_network import MLPRegressor

# ============================================================
# PAGE
# ============================================================

st.set_page_config(
    page_title="Hybrid EIS Digital Twin",
    layout="wide"
)

st.title("🔋 Hybrid EIS Digital Twin")

st.markdown("""
AI-assisted Electrochemical Impedance Spectroscopy
with physics-based Levenberg–Marquardt refinement.
""")

# ============================================================
# FREQUENCY
# ============================================================

freq = np.logspace(-3, 4, 200)

# ============================================================
# PARALLEL
# ============================================================

def parallel(a, b):
    return 1 / (1/a + 1/b)

# ============================================================
# EIS MODEL
# ============================================================

def eis_model(freq, Rb, L, Rsei, Qsei, Rct, Qel, sigma):

    w = 2*np.pi*freq
    jw = 1j*w

    ZL = jw * L

    Zsei = parallel(
        Rsei,
        1 / (Qsei * jw)
    )

    Zw = (1 - 1j) * sigma / np.sqrt(w + 1e-20)

    Zct = Rct + Zw

    Zel = parallel(
        Zct,
        1 / (Qel * jw)
    )

    return Rb + ZL + Zsei + Zel

# ============================================================
# RANDOM PARAMETERS
# ============================================================

def random_params():

    return np.array([

        np.random.uniform(0.01, 0.06),      # Rb
        np.random.uniform(1e-8, 1e-6),      # L
        np.random.uniform(0.001, 0.02),     # Rsei
        np.random.uniform(0.05, 1.0),       # Qsei
        np.random.uniform(0.001, 0.02),     # Rct
        np.random.uniform(0.5, 3.0),        # Qel
        np.random.uniform(0.0001, 0.01)     # sigma

    ])

# ============================================================
# DATASET
# ============================================================

@st.cache_data
def make_dataset(N=3000):

    X = []
    Y = []

    for _ in range(N):

        p = random_params()

        Z = eis_model(freq, *p)

        x = np.concatenate([
            Z.real,
            Z.imag
        ])

        x += np.random.normal(
            0,
            1e-4,
            size=x.shape
        )

        X.append(x)
        Y.append(p)

    return np.array(X), np.array(Y)

# ============================================================
# TRAIN AI
# ============================================================

@st.cache_resource
def train_model():

    X, Y = make_dataset()

    sx = StandardScaler()
    sy = StandardScaler()

    Xs = sx.fit_transform(X)
    Ys = sy.fit_transform(Y)

    model = MLPRegressor(

        hidden_layer_sizes=(256,256,128),

        activation="relu",

        max_iter=500,

        verbose=False

    )

    model.fit(Xs, Ys)

    return model, sx, sy

model, sx, sy = train_model()

# ============================================================
# AI PREDICTION
# ============================================================

def ai_predict(x):

    xs = sx.transform([x])

    y = model.predict(xs)

    return sy.inverse_transform(y)[0]

# ============================================================
# LM
# ============================================================

def forward(params):

    Z = eis_model(freq, *params)

    return np.concatenate([
        Z.real,
        Z.imag
    ])

def residual(params, y):

    return forward(params) - y

def LM(y, x0):

    result = least_squares(

        residual,

        x0,

        args=(y,),

        method="lm"

    )

    return result.x

# ============================================================
# SIDEBAR
# ============================================================

st.sidebar.header("Battery Parameters")

Rb = st.sidebar.slider(
    "Rb [Ω]",
    0.01, 0.06, 0.03, 0.001
)

L = st.sidebar.slider(
    "L [H]",
    1e-8, 1e-6, 4e-7, 1e-8,
    format="%.1e"
)

Rsei = st.sidebar.slider(
    "Rsei [Ω]",
    0.001, 0.02, 0.003, 0.0001
)

Qsei = st.sidebar.slider(
    "Qsei",
    0.05, 1.0, 0.2, 0.01
)

Rct = st.sidebar.slider(
    "Rct [Ω]",
    0.001, 0.02, 0.005, 0.0001
)

Qel = st.sidebar.slider(
    "Qel",
    0.5, 3.0, 1.7, 0.01
)

sigma = st.sidebar.slider(
    "Sigma",
    0.0001, 0.01, 0.001, 0.0001
)

noise = st.sidebar.slider(
    "Noise",
    0.0, 0.001, 0.0001, 0.00001
)

# ============================================================
# TRUE PARAMETERS
# ============================================================

true_params = np.array([

    Rb,
    L,
    Rsei,
    Qsei,
    Rct,
    Qel,
    sigma

])

# ============================================================
# TRUE EIS
# ============================================================

Z_true = eis_model(freq, *true_params)

# ============================================================
# NOISE
# ============================================================

Z_meas = Z_true + (

    np.random.randn(len(Z_true))
    + 1j*np.random.randn(len(Z_true))

) * noise

# ============================================================
# FEATURE VECTOR
# ============================================================

x = np.concatenate([

    Z_meas.real,
    Z_meas.imag

])

# ============================================================
# AI
# ============================================================

ai_params = ai_predict(x)

# ============================================================
# LM
# ============================================================

lm_params = LM(x, ai_params)

# ============================================================
# RECONSTRUCTION
# ============================================================

Z_ai = eis_model(freq, *ai_params)

Z_lm = eis_model(freq, *lm_params)

# ============================================================
# PLOT
# ============================================================

fig, ax = plt.subplots(figsize=(7,6))

ax.plot(

    Z_true.real,
    -Z_true.imag,

    color="black",

    linewidth=3,

    label="True"

)

ax.plot(

    Z_ai.real,
    -Z_ai.imag,

    "--",

    color="red",

    linewidth=2,

    label="AI"

)

ax.plot(

    Z_lm.real,
    -Z_lm.imag,

    ":",

    color="blue",

    linewidth=2,

    label="AI + LM"

)

ax.set_xlabel("Z'")

ax.set_ylabel("-Z''")

ax.grid(True, alpha=0.3)

ax.axis("equal")

ax.legend()

st.pyplot(fig)

# ============================================================
# TABLE
# ============================================================

names = [

    "Rb",
    "L",
    "Rsei",
    "Qsei",
    "Rct",
    "Qel",
    "sigma"

]

df = pd.DataFrame({

    "Parameter": names,

    "True": true_params,

    "AI": ai_params,

    "AI+LM": lm_params,

    "AI Error %":

        100*np.abs(

            (ai_params - true_params)

            / (true_params + 1e-20)

        ),

    "LM Error %":

        100*np.abs(

            (lm_params - true_params)

            / (true_params + 1e-20)

        )

})

st.dataframe(df, use_container_width=True)

# ============================================================
# FOOTER
# ============================================================

st.markdown("---")

st.markdown("""

Hybrid AI + Physics-based EIS parameter estimation.

""")
