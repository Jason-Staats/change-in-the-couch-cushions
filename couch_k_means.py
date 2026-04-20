import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
from collections import Counter
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap  # <-- missing import

# Load pre-aggregated data from SQL export
cluster_df = pd.read_csv(
    'C:/Portfolio Projects/Exercise Dataset/activity_healthcare_agg.csv',
    index_col='state_abbr'
)

# Standardize the data
scaler = StandardScaler()
data_scaled = pd.DataFrame(
    scaler.fit_transform(cluster_df),
    columns=cluster_df.columns,
    index=cluster_df.index
)

# Inertia plot
inertia_values = []
for k in range(2, 11):
    kmeans = KMeans(n_clusters=k, n_init='auto', random_state=42)
    kmeans.fit(data_scaled)
    inertia_values.append(kmeans.inertia_)

pd.Series(inertia_values, index=range(2, 11)).plot(marker='o')
plt.xlabel("Number of Clusters (k)")
plt.ylabel("Inertia")
plt.title("Number of Clusters vs. Inertia")
plt.show()

# Silhouette score plot
silhouette_scores = []
for k in range(2, 11):
    kmeans = KMeans(n_clusters=k, n_init='auto', random_state=42)
    kmeans.fit(data_scaled)
    silhouette_scores.append(silhouette_score(data_scaled, kmeans.labels_))

pd.Series(silhouette_scores, index=range(2, 11)).plot(marker='o')
plt.xlabel("Number of Clusters (k)")
plt.ylabel("Silhouette Score")
plt.title("Number of Clusters vs. Silhouette Score")
plt.show()

# Fit final model with k=3
kmeans3 = KMeans(n_clusters=3, n_init='auto', random_state=42)
kmeans3.fit(data_scaled)

# View cluster distribution
print(Counter(kmeans3.labels_))

# Create dataframe from cluster centers
cluster_centers3 = pd.DataFrame(
    kmeans3.cluster_centers_,
    columns=data_scaled.columns
)

# Rename columns with line breaks for readability
cluster_centers3.columns = [
    'Muscle\nStrengthening',
    'No Leisure\nActivity',
    'Healthcare\nSpending'
]

# Custom blue palette
custom_blues = LinearSegmentedColormap.from_list(
    "custom_blues",
    ["#c6dbef", "#4292c6", "#08306b"]
)

# Plot heatmap
plt.figure(figsize=(8, 6))

ax = sns.heatmap(
    cluster_centers3,
    cmap=custom_blues,
    annot=True,
    annot_kws={"size": 16},
    center=0,
    fmt=".2f",
    linewidths=0.5
)

# Colorbar formatting
cbar = ax.collections[0].colorbar
cbar.ax.tick_params(labelsize=12)
cbar.set_label("Standardized Value", fontsize=16)

# Axis formatting
plt.xticks(rotation=0, fontsize=16)
plt.yticks(rotation=0, fontsize=16)

plt.tight_layout()

# Export BEFORE show
plt.savefig("heatmap.png", dpi=300, bbox_inches='tight', facecolor='white')

plt.show()