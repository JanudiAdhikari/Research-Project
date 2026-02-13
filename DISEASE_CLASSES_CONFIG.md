# Disease Classes Configuration Guide

## Overview
The disease detection system supports customizable disease classes. Update these files to match your CNN model's output.

## Step 1: Identify Your Model's Output Classes

First, check your CNN model's output layer to determine:
- Number of output classes
- Class names (in order)
- Class indices

Example:
```python
import tensorflow as tf
model = tf.keras.models.load_model('pepper_disease_classifier_final.keras')
print(model.summary())
# Look for the output layer shape: (None, 4) means 4 classes
```

## Step 2: Get Class Information

For each disease class, gather:
- Class name
- Disease description
- Treatment recommendations
- Severity level (None/Low/Medium/High)
- Prevention tips (optional)

## Step 3: Update Backend (app.py)

Edit `components/feature-disease detection/app.py`:

```python
DISEASE_CLASSES = {
    0: {
        'name': 'Healthy',
        'description': 'The leaf appears healthy with no visible signs of disease.',
        'treatment': 'Continue with regular maintenance and monitoring.',
        'severity': 'None'
    },
    1: {
        'name': 'Bacterial Spot',
        'description': 'Dark, greasy spots on leaves caused by Xanthomonas bacteria.',
        'treatment': 'Remove infected leaves, apply copper-based fungicides, ensure good air circulation.',
        'severity': 'High',
        'prevention': 'Avoid overhead watering, practice crop rotation, use disease-free seeds.'
    },
    2: {
        'name': 'Bell Pepper Blight',
        'description': 'Fungal disease (Phytophthora) causing brown spots and leaf wilt.',
        'treatment': 'Remove affected plant parts, apply fungicide, improve soil drainage.',
        'severity': 'High',
        'prevention': 'Ensure proper spacing for air circulation, avoid wet leaves.'
    },
    3: {
        'name': 'Target Spot',
        'description': 'Fungal disease (Corynespora) with circular spots and concentric rings.',
        'treatment': 'Apply fungicide, remove infected leaves, maintain proper humidity levels.',
        'severity': 'Medium',
        'prevention': 'Reduce humidity, avoid overhead irrigation, improve ventilation.'
    }
}
```

## Step 4: Update Flutter Service (Local Inference)

If using local inference, update `disease_detection_service.dart`:

```dart
static const Map<int, Map<String, String>> DISEASE_CLASSES = {
  0: {
    'name': 'Healthy',
    'description': 'The leaf appears healthy with no visible signs of disease.',
    'treatment': 'Continue with regular maintenance and monitoring.',
    'severity': 'None'
  },
  1: {
    'name': 'Bacterial Spot',
    'description': 'Dark, greasy spots on leaves caused by Xanthomonas bacteria.',
    'treatment': 'Remove infected leaves, apply copper-based fungicides, ensure good air circulation.',
    'severity': 'High',
    'prevention': 'Avoid overhead watering, practice crop rotation, use disease-free seeds.'
  },
  // Add more classes...
};
```

## Step 5: Verify Model Output Order

**Important:** The class index MUST match the model's output order!

Example: If your model outputs 4 probabilities:
- Index 0: First class (e.g., Healthy)
- Index 1: Second class (e.g., Bacterial Spot)
- Index 2: Third class (e.g., Bell Pepper Blight)
- Index 3: Fourth class (e.g., Target Spot)

To verify:
```python
import numpy as np
from tensorflow import keras

model = keras.models.load_model('pepper_disease_classifier_final.keras')
# Load a test image and make prediction
test_output = model.predict(test_image)
# test_output shape will be (1, num_classes)
# The order of indices matches your mapping
```

## Disease Template

Use this template for each disease:

```python
{
    'id': 0,  # Model output index
    'name': 'Disease Name',
    'description': 'Clear description of what the disease is, its symptoms, and characteristics.',
    'treatment': 'Step-by-step treatment recommendations. Include fungicides, organic solutions, and best practices.',
    'severity': 'High/Medium/Low/None',  # Critical for UI color coding
    'prevention': 'Prevention tips to avoid this disease in future crops.'
}
```

## Complete Example: 4-Class Model

```python
DISEASE_CLASSES = {
    0: {
        'name': 'Healthy',
        'description': 'The leaf appears completely healthy with no visible signs of disease or damage.',
        'treatment': 'Continue with regular maintenance and monitoring. No intervention needed.',
        'severity': 'None',
        'prevention': 'Maintain good farm hygiene and regular monitoring practices.'
    },
    1: {
        'name': 'Bacterial Spot',
        'description': 'Small, dark brown spots with oily appearance caused by Xanthomonas campestris. Spreads in wet conditions.',
        'treatment': '1. Remove affected leaves immediately. 2. Apply copper-based fungicides weekly. 3. Improve air circulation. 4. Avoid overhead watering. 5. Disinfect tools after each plant.',
        'severity': 'High',
        'prevention': 'Use disease-resistant varieties, practice 3-year crop rotation, sanitize seeds, avoid overhead irrigation.'
    },
    2: {
        'name': 'Bell Pepper Blight (Phytophthora)',
        'description': 'Water mold disease causing brown spots, stem rot, and fruit decay. Thrives in high humidity.',
        'treatment': '1. Remove infected plant parts. 2. Improve drainage. 3. Reduce humidity. 4. Apply systemic fungicides. 5. Increase plant spacing for air flow.',
        'severity': 'High',
        'prevention': 'Ensure well-drained soil, avoid waterlogging, use mulch to prevent soil splash, practice crop rotation.'
    },
    3: {
        'name': 'Target Spot (Corynespora)',
        'description': 'Fungal disease producing circular spots with concentric rings on leaves. Brown spots with dark borders.',
        'treatment': '1. Apply fungicides every 7-10 days. 2. Remove infected leaves. 3. Maintain optimal humidity (50-60%). 4. Improve ventilation. 5. Avoid overhead watering.',
        'severity': 'Medium',
        'prevention': 'Maintain proper plant spacing, avoid overhead irrigation, reduce leaf wetness duration, monitor regularly.'
    }
}
```

## Severity Color Coding

The UI uses colors to represent severity:

| Severity | Color | Hex | Icon |
|----------|-------|-----|------|
| None (Healthy) | Green | #4CAF50 | ✅ check_circle |
| Low | Yellow | #FFD700 | ℹ️ info |
| Medium | Orange | #FFA500 | ⚠️ warning |
| High | Red | #FF6B6B | ❌ error |

## Advanced: Multiple Languages

To support multiple languages, structure like this:

```python
DISEASE_CLASSES = {
    0: {
        'name': {
            'en': 'Healthy',
            'si': 'සුස්ථ',
        },
        'description': {
            'en': 'The leaf appears healthy...',
            'si': 'නෙහ එල්ලිම ස්වාස්థ්ය පෙනේ...',
        },
        'treatment': {
            'en': 'Continue monitoring...',
            'si': 'නිරීක්ෂණය চালිয়ে যান...',
        },
        'severity': 'None',
        'prevention': {
            'en': 'Maintain good hygiene...',
            'si': 'හොඳ සනීපාධාර පවත්වා ගන්න...',
        }
    },
    # Add more classes...
}
```

Then access with language parameter:
```python
disease_name = DISEASE_CLASSES[class_id]['name'][language]
```

## Testing Configuration

Verify your configuration:

```python
# Test 1: Check all classes have required fields
for class_id, disease_info in DISEASE_CLASSES.items():
    required_fields = ['name', 'description', 'treatment', 'severity']
    for field in required_fields:
        assert field in disease_info, f"Missing {field} in class {class_id}"

# Test 2: Verify severity values are valid
valid_severities = ['None', 'Low', 'Medium', 'High']
for class_id, disease_info in DISEASE_CLASSES.items():
    assert disease_info['severity'] in valid_severities, f"Invalid severity in class {class_id}"

# Test 3: Check class count matches model output
import tensorflow as tf
model = tf.keras.models.load_model('pepper_disease_classifier_final.keras')
output_shape = model.output_shape
expected_classes = output_shape[-1]  # Last dimension
assert len(DISEASE_CLASSES) == expected_classes, f"Class count mismatch: expected {expected_classes}, got {len(DISEASE_CLASSES)}"

print("✅ Configuration verified!")
```

## Common Mistakes to Avoid

❌ **Wrong:** Class indices don't match model output order
✅ **Correct:** Verify model output order and map accordingly

❌ **Wrong:** Missing required fields (name, description, treatment, severity)
✅ **Correct:** Include all required fields for each disease

❌ **Wrong:** Invalid severity values (e.g., 'Critical' instead of 'High')
✅ **Correct:** Use only: None, Low, Medium, High

❌ **Wrong:** Mismatched class count between model and dictionary
✅ **Correct:** Ensure dictionary has exactly as many entries as model outputs

## Updating Disease Information

To update disease info without changing model:

**Backend approach:**
1. Edit `DISEASE_CLASSES` in `app.py`
2. Restart Flask server
3. App automatically uses new info

**Local inference approach:**
1. Edit `DISEASE_CLASSES` in service
2. Recompile Flutter app
3. Deploy new version

## Example: Different Crop (Tomato)

```python
DISEASE_CLASSES = {
    0: {
        'name': 'Healthy',
        'description': 'Tomato plant is healthy.',
        'treatment': 'Continue regular care.',
        'severity': 'None'
    },
    1: {
        'name': 'Early Blight',
        'description': 'Early blight caused by Alternaria. Circular spots with concentric rings.',
        'treatment': 'Remove lower leaves, apply fungicide, improve air circulation.',
        'severity': 'High',
        'prevention': 'Space plants properly, avoid overhead watering, mulch ground.'
    },
    2: {
        'name': 'Late Blight',
        'description': 'Late blight caused by Phytophthora. Watery spots on leaves and stems.',
        'treatment': 'Remove affected parts, apply copper/mancozeb fungicide.',
        'severity': 'High',
        'prevention': 'Choose resistant varieties, ensure good drainage, avoid crowding.'
    }
}
```

## Support

For issues with disease class configuration:
1. Verify model output order
2. Check all required fields are present
3. Validate severity values
4. Test with sample images
5. Check Flask/Flutter logs for errors

