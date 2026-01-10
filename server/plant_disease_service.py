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
import os

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
    def __init__(self):
        """Initialize the plant disease detection model"""
        try:
            # Add plant-disease-model to path
            model_dir = os.path.join(os.path.dirname(__file__), '..', 'plant-disease-model')
            sys.path.insert(0, model_dir)
            
            # Import CNN
            import CNN
            
            # Model path
            model_path = os.path.join(model_dir, 'plant_disease_model_1_latest.pt')
            
            if not os.path.exists(model_path):
                raise FileNotFoundError(f"Model file not found: {model_path}")
            
            # Load model
            self.model = CNN.CNN(39)  # 39 classes
            self.model.load_state_dict(torch.load(model_path, map_location=torch.device('cpu')))
            self.model.eval()
            
        except Exception as e:
            raise Exception(f"Failed to initialize model: {str(e)}")

    def predict(self, image_path):
        """
        Predict plant disease from image file
        
        Args:
            image_path: Path to image file
            
        Returns:
            dict with prediction results
        """
        try:
            # Load image
            if not os.path.exists(image_path):
                raise FileNotFoundError(f"Image file not found: {image_path}")
            
            image = Image.open(image_path)
            
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
                    'confidence': float(prob.item())
                }
                for prob, idx in zip(top_probs[0], top_indices[0])
            ]
            
            return {
                'success': True,
                'prediction': disease_name,
                'confidence': float(confidence),
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
    """Main function"""
    if len(sys.argv) < 2:
        result = {'success': False, 'error': 'Usage: python plant_disease_service.py <image_path>'}
        print(json.dumps(result))
        sys.exit(1)
    
    image_path = sys.argv[1]
    
    try:
        detector = PlantDiseaseDetector()
        result = detector.predict(image_path)
        print(json.dumps(result))
        sys.exit(0 if result.get('success') else 1)
    except Exception as e:
        result = {'success': False, 'error': str(e)}
        print(json.dumps(result))
        sys.exit(1)

if __name__ == '__main__':
    main()
