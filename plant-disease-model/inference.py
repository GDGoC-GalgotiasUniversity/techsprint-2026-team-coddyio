import torch
import torchvision.transforms.functional as TF
from PIL import Image
import numpy as np
import CNN  # Ensure this is the same CNN module you used in your app.py

# Load your model
model = CNN.CNN(39)  # Replace with your model class
model.load_state_dict(torch.load("plant_disease_model_1_latest.pt", map_location=torch.device('cpu')))
model.eval()

def predict(image: Image.Image):
    # Preprocess the image
    image = image.resize((224, 224))
    input_data = TF.to_tensor(image).unsqueeze(0)  # Add batch dimension

    # Model inference
    with torch.no_grad():
        output = model(input_data)
    
    # Postprocess the output
    output = output.numpy()
    index = np.argmax(output)
    return int(index)

# Example usage (uncomment the following lines to test locally)
# if __name__ == "__main__":
#     image_path = "path_to_test_image.jpg"
#     image = Image.open(image_path)
#     prediction_index = predict(image)
#     print(f"Predicted class index: {prediction_index}")