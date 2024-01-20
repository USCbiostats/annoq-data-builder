import pickle
import json

# Step 1: Load the pickle file
with open('./resources/sample_data/annoq_tree.pkl', 'rb') as file:
    data = pickle.load(file)

# Step 2: Optionally, process the data if needed to make it JSON-serializable

# Step 3: Save the data in JSON format
with open('output_file.json', 'w') as json_file:
    json.dump(data, json_file, indent=4)