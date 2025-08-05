import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load Data

@st.cache_data
def load_data():
    df = pd.read_csv("cleaned_agriculture_data.csv")  # Change to your dataset
    return df

df = load_data()

# Title
st.title("🌾 AgriData Explorer: Understanding Indian Agriculture")

# Sidebar - Choose Visualization
st.sidebar.header("Visualization Options")
selected_crop = st.sidebar.selectbox("Select Crop", ["Rice", "Wheat", "Maize"])
selected_state = st.sidebar.selectbox("Select State", df["state_name"].unique())

# Filter Data
crop_area_column = f"{selected_crop.lower()}_area_1000_ha"
crop_production_column = f"{selected_crop.lower()}_production_1000_tons"

filtered_data = df[df["state_name"] == selected_state]

# Display Data Summary
st.subheader("📊 Data Overview")
st.write(filtered_data.describe())

# Area vs. Production Plot
st.subheader(f"🌱 {selected_crop} Production Analysis in {selected_state}")
fig, ax = plt.subplots()
sns.lineplot(data=filtered_data, x="year", y=crop_area_column, label="Crop Area", marker="o", ax=ax)
sns.lineplot(data=filtered_data, x="year", y=crop_production_column, label="Crop Production", marker="s", ax=ax)
ax.set_xlabel("Year")
ax.set_ylabel("Production (1000 tons) & Area (1000 ha)")
ax.legend()
st.pyplot(fig)

# Correlation Analysis
st.subheader("📈 Crop Production Correlation")
corr = df[[crop_area_column, crop_production_column]].corr()
st.write(corr)

# Interactive Table
st.subheader("📝 View Detailed Data")
st.dataframe(filtered_data)

# Conclusion
st.markdown("📌 This dashboard helps visualize Indian agricultural trends over time. Explore different crops and states for deeper insights!")
