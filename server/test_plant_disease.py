#!/usr/bin/env python3
"""
Test script for plant disease detection service
"""

import sys
import os
import json

# Test if we can import the service
try:
    from plant_disease_service import PlantDiseaseDetector
    print("✅ Successfully imported PlantDiseaseDetector")
except Exception as e:
    print(f"❌ Failed to import: {e}")
    sys.exit(1)

# Test if we can initialize the model
try:
    detector = PlantDiseaseDetector()
    print("✅ Successfully initialized detector")
except Exception as e:
    print(f"❌ Failed to initialize detector: {e}")
    sys.exit(1)

# Test with a sample image if provided
if len(sys.argv) > 1:
    image_path = sys.argv[1]
    if os.path.exists(image_path):
        try:
            result = detector.predict(image_path)
            print("✅ Prediction successful:")
            print(json.dumps(result, indent=2))
        except Exception as e:
            print(f"❌ Prediction failed: {e}")
            sys.exit(1)
    else:
        print(f"❌ Image file not found: {image_path}")
        sys.exit(1)
else:
    print("ℹ️ No image provided. Service is ready.")
    print("Usage: python test_plant_disease.py <image_path>")
