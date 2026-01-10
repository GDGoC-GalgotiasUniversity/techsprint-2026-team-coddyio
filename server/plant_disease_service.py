#!/usr/bin/env python3
"""
Plant Disease Detection Service
Integrates the Plant Disease Detection model with the Node.js server
"""

import torch
import torchvision.transforms.functional as TF
from PIL import Image
import numpy as np
import sys
import json
import base64
from io import BytesIO
import os

# Add plant-disease-model to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'plant-disease-model'))

try:
    import CNN
except ImportError:
    print("Error: Could not import CNN module. Make sure plant-disease-model is in the correct location.")
    sys.exit(1)

# Disease class mapping
DISEASE_CLASSES = {
    0: 'Apple___Apple_scab',
    1: 'Apple___Black_rot',
    2: 'Apple___Cedar_apple_rust',
    3: 'Apple___healthy',
    4: 'Background_without_leaves',
    5: 'Blueberry___healthy',
    6: 'Cherry___Powdery_mildew',
    7: 'Cherry___healthy',
    8: 'Corn___Cercospora_leaf_spot Gray_leaf_spot',
    9: 'Corn___Common_rust',
    10: 'Corn___Northern_Leaf_Blight',
    11: 'Corn___healthy',
    12: 'Grape___Black_rot',
    13: 'Grape___Esca_(Black_Measles)',
    14: 'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
    15: 'Grape___healthy',
    16: 'Orange___Haunglongbing_(Citrus_greening)',
    17: 'Peach___Bacterial_spot',
    18: 'Peach___healthy',
    19: 'Pepper,_bell___Bacterial_spot',
    20: 'Pepper,_bell___healthy',
    21: 'Potato___Early_blight',
    22: 'Potato___Late_blight',
    23: 'Potato___healthy',
    24: 'Raspberry___healthy',
    25: 'Soybean___healthy',
    26: 'Squash___Powdery_mildew',
    27: 'Strawberry___Leaf_scorch',
    28: 'Strawberry___healthy',
    29: 'Tomato___Bacterial_spot',
    30: 'Tomato___Early_blight',
    31: 'Tomato___Late_blight',
    32: 'Tomato___Leaf_Mold',
    33: 'Tomato___Septoria_leaf_spot',
    34: 'Tomato___Spider_mites Two-spotted_spider_mite',
    35: 'Tomato___Target_Spot',
    36: 'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
    37: 'Tomato___Tomato_mosaic_virus',
    38: 'Tomato___healthy'
}

class PlantDiseaseDetector:
    def __init__(self, model_path='../plant-disease-model/plant_disease_model_1_latest.pt'):
        """Initialize the plant disease detection model"""
        try:
            print("🌱 Initializing Plant Disease Detection Model...")
            
            # Load model
            self.model = CNN.CNN(39)  # 39 classes
            
            # Check if model file exists
            if not os.path.exists(model_path):
                raise FileNotFoundError(f"Model file not found: {model_path}")
            
            # Load weights
            self.model.load_state_dict(torch.load(model_path, map_location=torch.device('cpu')))
            self.model.eval()
            
            print("✅ Model loaded successfully")
            print(f"📊 Classes: {len(DISEASE_CLASSES)}")
            print("🎯 Ready for inference")
            
        except Exception as e:
            print(f"❌ Error initializing model: {e}")
            raise

    def predict(self, image_input):
        """
        Predict plant disease from image
        
        Args:
            image_input: PIL Image or base64 string
            
        Returns:
            dict with prediction results
        """
        try:
            # Convert base64 to PIL Image if needed
            if isinstance(image_input, str):
                image_data = base64.b64decode(image_input)
                image = Image.open(BytesIO(image_data))
            else:
                image = image_input
            
            # Ensure RGB
            if image.mode != 'RGB':
                image = image.convert('RGB')
            
            # Preprocess
            image = image.resize((224, 224))
            input_data = TF.to_tensor(image).unsqueeze(0)
            
            # Inference
            with torch.no_grad():
                output = self.model(input_data)
            
            # Get predictions
            probabilities = torch.nn.functional.softmax(output, dim=1)
            confidence, predicted_idx = torch.max(probabilities, 1)
            
            predicted_idx = predicted_idx.item()
            confidence = confidence.item()
            disease_name = DISEASE_CLASSES.get(predicted_idx, 'Unknown')
            
            # Get top 3 predictions
            top_probs, top_indices = torch.topk(probabilities, 3, dim=1)
            top_predictions = [
                {
                    'class': DISEASE_CLASSES.get(idx.item(), 'Unknown'),
                    'confidence': prob.item()
                }
                for prob, idx in zip(top_probs[0], top_indices[0])
            ]
            
            return {
                'success': True,
                'prediction': disease_name,
                'confidence': confidence,
                'class_index': predicted_idx,
                'top_predictions': top_predictions,
                'is_healthy': 'healthy' in disease_name.lower()
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }

def main():
    """Main function for testing"""
    if len(sys.argv) < 2:
        print("Usage: python plant_disease_service.py <image_path>")
        sys.exit(1)
    
    image_path = sys.argv[1]
    
    try:
        detector = PlantDiseaseDetector()
        image = Image.open(image_path)
        result = detector.predict(image)
        print(json.dumps(result, indent=2))
    except Exception as e:
        print(json.dumps({'success': False, 'error': str(e)}))
        sys.exit(1)

if __name__ == '__main__':
    main()
