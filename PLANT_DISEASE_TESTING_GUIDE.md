# Plant Disease Detection - Testing Guide

## Overview
The plant disease detection feature is now fully integrated with:
- Photo capture from camera
- Photo selection from gallery
- Image compression (max 800x800, JPEG quality 85%)
- Disease detection via Python ML model
- Disease information retrieval
- AI-powered treatment recommendations via Gemini

## Testing Checklist

### 1. Setup Verification
- [ ] Server running on `http://10.10.180.11:3000`
- [ ] MongoDB connected and accessible
- [ ] Python service available at `server/plant_disease_service.py`
- [ ] Gemini API key configured in `server/.env`
- [ ] Cartesia API key configured (optional, for voice features)

### 2. Photo Capture Flow
- [ ] Open Plant Disease Detection screen
- [ ] Click "Camera" button
- [ ] Take a photo of a plant leaf
- [ ] Verify image appears in preview
- [ ] Verify "Image selected. Ready to analyze." message appears

### 3. Photo Gallery Flow
- [ ] Open Plant Disease Detection screen
- [ ] Click "Gallery" button
- [ ] Select an image from device gallery
- [ ] Verify image appears in preview
- [ ] Verify "Image selected. Ready to analyze." message appears

### 4. Image Compression
- [ ] Observe console logs for compression info
- [ ] Expected: "📦 Image compressed: [original_size] → [compressed_size] bytes"
- [ ] Compressed size should be significantly smaller than original
- [ ] Verify upload completes within reasonable time

### 5. Disease Detection
- [ ] After image selection, detection should start automatically
- [ ] Verify "Analyzing plant image..." loading indicator appears
- [ ] Wait for analysis to complete (typically 5-15 seconds)
- [ ] Verify detection result card appears with:
  - [ ] Status (Healthy or Disease Detected)
  - [ ] Disease name (formatted)
  - [ ] Confidence percentage
  - [ ] Confidence progress bar
  - [ ] Top predictions list

### 6. Disease Information
- [ ] After detection, disease information card should appear
- [ ] Verify plant name is displayed
- [ ] Verify condition is displayed
- [ ] Information should load without errors

### 7. Treatment Recommendations
- [ ] After detection, "Getting treatment recommendations..." should appear
- [ ] Wait for Gemini AI to generate recommendations
- [ ] Verify treatment card appears with:
  - [ ] Disease description
  - [ ] Home remedies (5-7 solutions)
  - [ ] Prevention tips
  - [ ] Professional help guidance

### 8. Clear Image
- [ ] After detection, click the X button in app bar
- [ ] Verify all results are cleared
- [ ] Verify image preview is removed
- [ ] Verify screen returns to initial state

### 9. Error Handling
- [ ] Test with invalid/corrupted image
- [ ] Test with network disconnected
- [ ] Test with server unavailable
- [ ] Verify error dialogs appear with helpful messages

### 10. Performance
- [ ] Image compression should complete in < 2 seconds
- [ ] Upload should complete in < 10 seconds
- [ ] Detection should complete in < 20 seconds
- [ ] Remedies generation should complete in < 15 seconds

## Test Images
Recommended test images:
- Healthy plant leaves
- Diseased tomato leaves (early/late blight)
- Diseased apple leaves (scab/black rot)
- Diseased potato leaves
- Diseased corn leaves

## Expected Disease Classes
The model supports 39 plant disease classes including:
- Apple: Scab, Black Rot, Cedar Apple Rust, Healthy
- Tomato: Early Blight, Late Blight, Septoria Leaf Spot, Healthy
- Potato: Early Blight, Late Blight, Healthy
- Corn: Cercospora Leaf Spot, Common Rust, Northern Leaf Blight, Healthy
- And many more...

## Troubleshooting

### Image not uploading
- Check server is running: `node server/server.js`
- Verify API endpoint: `POST /api/plant-disease/detect`
- Check network connectivity
- Verify image size is reasonable (< 5MB)

### Detection failing
- Verify Python service is available
- Check Python dependencies: `pip install -r requirements.txt`
- Verify model file exists: `plant-disease-model/model.h5`
- Check server logs for Python errors

### Remedies not generating
- Verify Gemini API key is set in `.env`
- Check Gemini service initialization
- Verify internet connectivity
- Check Gemini API quota

### Slow performance
- Verify image compression is working
- Check server CPU/memory usage
- Verify network latency
- Consider reducing image quality further if needed

## Files Modified
- `mobile/lib/screens/plant_disease_screen.dart` - Integrated improved version
- `mobile/lib/services/plant_disease_service.dart` - Disease detection service
- `mobile/lib/services/api_service.dart` - API communication
- `server/server.js` - Backend endpoints
- `server/plant_disease_service.py` - Python inference service

## Next Steps
- [ ] Test on actual device with camera
- [ ] Test with various plant diseases
- [ ] Optimize image compression settings if needed
- [ ] Add detection history persistence (SQLite/Hive)
- [ ] Add image cropper for manual image adjustment
- [ ] Add batch detection for multiple images
