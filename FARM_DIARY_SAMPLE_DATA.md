# Farm Diary - Sample Documents

## How to Insert Sample Data

### Option 1: Via Flutter App UI
1. Navigate to **Diary** tab in bottom navigation
2. Click **New Entry** button
3. Fill in the form with sample data below
4. Click **Save Entry**

### Option 2: Via API (cURL)
```bash
curl -X POST http://localhost:5000/api/farm-diary/entries \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{JSON_BODY_FROM_SAMPLES_BELOW}'
```

### Option 3: Via MongoDB Direct Insert
```javascript
db.farmdiary.insertMany([...documents from below])
```

---

## Sample Documents

### Sample 1: Morning Watering Session
```json
{
  "title": "Morning Watering Session",
  "description": "Watered all pepper plants in the morning before heat. Used drip irrigation system.",
  "activityType": "watering",
  "diaryDate": "2024-02-24T06:30:00Z",
  "farmPlotId": "YOUR_FARM_PLOT_ID",
  "weather": {
    "condition": "sunny",
    "temperature": 22.5,
    "humidity": 65,
    "rainfall": 0
  },
  "observations": {
    "plantHealth": "good",
    "diseaseSymptoms": null,
    "pestPresence": null,
    "yieldEstimate": "Looking good so far"
  },
  "actions": "Applied water evenly to all plants",
  "inputs": {
    "fertilizer": null,
    "pesticide": null,
    "waterQuantity": 150,
    "otherInputs": "Used drip irrigation"
  },
  "notes": "Plants looking healthy after morning watering. No visible stress.",
  "tags": ["morning", "routine", "irrigation"],
  "location": {
    "latitude": 6.9271,
    "longitude": 80.7789,
    "altitude": 250
  }
}
```

### Sample 2: Fertilizer Application
```json
{
  "title": "NPK Fertilizer Application",
  "description": "Applied NPK 16:16:16 fertilizer to boost plant growth. Mixed with water for even distribution.",
  "activityType": "fertilizing",
  "diaryDate": "2024-02-23T08:00:00Z",
  "farmPlotId": "YOUR_FARM_PLOT_ID",
  "weather": {
    "condition": "cloudy",
    "temperature": 26.0,
    "humidity": 70,
    "rainfall": 0
  },
  "observations": {
    "plantHealth": "good",
    "diseaseSymptoms": null,
    "pestPresence": null,
    "yieldEstimate": null
  },
  "actions": "Mixed 5kg NPK fertilizer with 50L water and sprayed evenly",
  "inputs": {
    "fertilizer": "NPK 16:16:16 - 5kg",
    "pesticide": null,
    "waterQuantity": 50,
    "otherInputs": "Sprayer equipment used"
  },
  "notes": "Applied during cloudy morning for better absorption. Plants well-watered before application.",
  "tags": ["fertilizer", "nutrients", "growth"],
  "location": {
    "latitude": 6.9271,
    "longitude": 80.7789,
    "altitude": 250
  }
}
```

### Sample 3: Pest Control Treatment
```json
{
  "title": "Pest Control - Mite Infestation",
  "description": "Treated red spider mites found on lower leaves. Applied organic pesticide.",
  "activityType": "pest_control",
  "diaryDate": "2024-02-22T14:30:00Z",
  "farmPlotId": "YOUR_FARM_PLOT_ID",
  "weather": {
    "condition": "sunny",
    "temperature": 31.0,
    "humidity": 55,
    "rainfall": 0
  },
  "observations": {
    "plantHealth": "fair",
    "diseaseSymptoms": "Red spider mites on lower leaves",
    "pestPresence": "Red spider mites - moderate infestation on 30% of plants",
    "yieldEstimate": "Potential yield impact if not controlled"
  },
  "actions": "Sprayed with neem oil-based pesticide on affected areas",
  "inputs": {
    "fertilizer": null,
    "pesticide": "Neem oil (5% concentration) - 2L",
    "waterQuantity": 40,
    "otherInputs": "Spray bottle with 1mm nozzle"
  },
  "notes": "Applied in late afternoon to minimize sun damage. Recommend follow-up treatment in 7 days.",
  "tags": ["pest-control", "mites", "organic"],
  "location": {
    "latitude": 6.9271,
    "longitude": 80.7789,
    "altitude": 250
  }
}
```

### Sample 4: Plant Inspection & Health Check
```json
{
  "title": "Weekly Health Inspection",
  "description": "Conducted routine inspection of all plants. Checked for diseases, pests, and overall health.",
  "activityType": "inspection",
  "diaryDate": "2024-02-21T09:00:00Z",
  "farmPlotId": "YOUR_FARM_PLOT_ID",
  "weather": {
    "condition": "cloudy",
    "temperature": 24.5,
    "humidity": 72,
    "rainfall": 5
  },
  "observations": {
    "plantHealth": "excellent",
    "diseaseSymptoms": "None observed",
    "pestPresence": "None observed",
    "yieldEstimate": "Plants developing well, flowers starting to appear"
  },
  "actions": "Examined 100 plants systematically, checked soil moisture, pruned dead leaves",
  "inputs": {
    "fertilizer": null,
    "pesticide": null,
    "waterQuantity": null,
    "otherInputs": "Magnifying glass for detailed inspection"
  },
  "notes": "All plants looking healthy. Flowers appearing on 60% of plants. Recommend light pruning of lower branches.",
  "tags": ["inspection", "routine", "health-check"],
  "location": {
    "latitude": 6.9271,
    "longitude": 80.7789,
    "altitude": 250
  }
}
```

### Sample 5: Pruning & Maintenance
```json
{
  "title": "Plant Pruning and Dead Leaf Removal",
  "description": "Removed dead leaves and pruned branches for better air circulation and shape.",
  "activityType": "pruning",
  "diaryDate": "2024-02-20T10:15:00Z",
  "farmPlotId": "YOUR_FARM_PLOT_ID",
  "weather": {
    "condition": "sunny",
    "temperature": 27.0,
    "humidity": 60,
    "rainfall": 0
  },
  "observations": {
    "plantHealth": "good",
    "diseaseSymptoms": null,
    "pestPresence": null,
    "yieldEstimate": null
  },
  "actions": "Pruned 15% of branches, removed dead leaves, improved canopy shape",
  "inputs": {
    "fertilizer": null,
    "pesticide": null,
    "waterQuantity": null,
    "otherInputs": "Pruning shears, secateurs"
  },
  "notes": "Better air circulation will help prevent fungal diseases. Plants responded well to last pruning.",
  "tags": ["pruning", "maintenance", "canopy"],
  "location": {
    "latitude": 6.9271,
    "longitude": 80.7789,
    "altitude": 250
  }
}
```

### Sample 6: Weeding
```json
{
  "title": "Weeding and Soil Preparation",
  "description": "Removed weeds around plants and loosened soil for better water infiltration.",
  "activityType": "weeding",
  "diaryDate": "2024-02-19T07:00:00Z",
  "farmPlotId": "YOUR_FARM_PLOT_ID",
  "weather": {
    "condition": "cloudy",
    "temperature": 23.0,
    "humidity": 75,
    "rainfall": 0
  },
  "observations": {
    "plantHealth": "good",
    "diseaseSymptoms": null,
    "pestPresence": null,
    "yieldEstimate": null
  },
  "actions": "Manual weeding of area, soil aeriation with hoe",
  "inputs": {
    "fertilizer": null,
    "pesticide": null,
    "waterQuantity": null,
    "otherInputs": "Hand tools, hoe"
  },
  "notes": "Removed approximately 20kg of weeds. Soil is well-structured after loosening.",
  "tags": ["weeding", "soil-prep", "maintenance"],
  "location": {
    "latitude": 6.9271,
    "longitude": 80.7789,
    "altitude": 250
  }
}
```

### Sample 7: Disease Treatment
```json
{
  "title": "Fungal Disease Treatment",
  "description": "Started preventive treatment for early signs of powdery mildew on leaf surfaces.",
  "activityType": "disease_treatment",
  "diaryDate": "2024-02-18T15:45:00Z",
  "farmPlotId": "YOUR_FARM_PLOT_ID",
  "weather": {
    "condition": "rainy",
    "temperature": 20.0,
    "humidity": 85,
    "rainfall": 12
  },
  "observations": {
    "plantHealth": "fair",
    "diseaseSymptoms": "White powdery coating on 15% of leaves, early stage",
    "pestPresence": null,
    "yieldEstimate": "Early intervention should prevent yield loss"
  },
  "actions": "Applied fungicide spray to affected areas and susceptible plants",
  "inputs": {
    "fertilizer": null,
    "pesticide": "Sulfur-based fungicide (3% concentration) - 3L",
    "waterQuantity": 30,
    "otherInputs": "Sprayer with fine mist nozzle"
  },
  "notes": "Treated early before spread. Humidity levels high due to rain. Improve ventilation. Plan follow-up in 10 days.",
  "tags": ["disease", "fungal", "preventive"],
  "location": {
    "latitude": 6.9271,
    "longitude": 80.7789,
    "altitude": 250
  }
}
```

### Sample 8: Harvesting
```json
{
  "title": "First Harvest - Green Peppers",
  "description": "Harvested first batch of mature green peppers. Quality excellent.",
  "activityType": "harvesting",
  "diaryDate": "2024-02-17T08:30:00Z",
  "farmPlotId": "YOUR_FARM_PLOT_ID",
  "weather": {
    "condition": "sunny",
    "temperature": 28.5,
    "humidity": 58,
    "rainfall": 0
  },
  "observations": {
    "plantHealth": "excellent",
    "diseaseSymptoms": null,
    "pestPresence": null,
    "yieldEstimate": "Harvested 45kg from 500 plants (9kg/100 plants)"
  },
  "actions": "Hand-picked mature green peppers carefully. Sorted by size and quality.",
  "inputs": {
    "fertilizer": null,
    "pesticide": null,
    "waterQuantity": null,
    "otherInputs": "Harvesting baskets, hand gloves"
  },
  "notes": "First harvest successful! Peppers grade A quality - firm, uniform green color, perfect size. Stored in cool shed.",
  "tags": ["harvest", "yield", "quality"],
  "location": {
    "latitude": 6.9271,
    "longitude": 80.7789,
    "altitude": 250
  }
}
```

### Sample 9: Other Activity - Trellis Support
```json
{
  "title": "Added Support Trellis for Climbing Peppers",
  "description": "Installed bamboo trellis support system for plants that need it.",
  "activityType": "other",
  "diaryDate": "2024-02-16T11:00:00Z",
  "farmPlotId": "YOUR_FARM_PLOT_ID",
  "weather": {
    "condition": "sunny",
    "temperature": 25.0,
    "humidity": 62,
    "rainfall": 0
  },
  "observations": {
    "plantHealth": "good",
    "diseaseSymptoms": null,
    "pestPresence": null,
    "yieldEstimate": null
  },
  "actions": "Built and installed bamboo trellis infrastructure for 200 plants",
  "inputs": {
    "fertilizer": null,
    "pesticide": null,
    "waterQuantity": null,
    "otherInputs": "Bamboo poles (100 pieces), jute twine (50m), labor"
  },
  "notes": "Trellis system will improve air circulation and fruit quality. Cost-effective support solution.",
  "tags": ["infrastructure", "support", "quality"],
  "location": {
    "latitude": 6.9271,
    "longitude": 80.7789,
    "altitude": 250
  }
}
```

---

## How to Use These Samples

### Step 1: Get Your Farm Plot ID
1. Go to "My Farm" tab
2. Note the farm plot ID (from the plot object in the API response)

### Step 2: Replace Farm Plot ID
Replace `"YOUR_FARM_PLOT_ID"` with your actual plot ID in all samples

### Step 3: Insert via Flutter App
For easiest testing:
1. Navigate to **Diary** tab
2. Click **New Entry**
3. Manually enter each sample (takes 2-3 minutes per entry)
4. Or copy the data field by field

### Step 4: Insert via API (Faster)
```bash
# Set your variables
TOKEN="your_firebase_token"
PLOT_ID="your_farm_plot_id"
BASE_URL="http://10.0.2.2:5000"

# Create entry from Sample 1
curl -X POST $BASE_URL/api/farm-diary/entries \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "farmPlotId": "'$PLOT_ID'",
    "title": "Morning Watering Session",
    "description": "Watered all pepper plants in the morning before heat.",
    "activityType": "watering",
    "diaryDate": "2024-02-24T06:30:00Z",
    "weather": {"condition": "sunny", "temperature": 22.5, "humidity": 65, "rainfall": 0},
    "observations": {"plantHealth": "good"},
    "inputs": {"waterQuantity": 150},
    "notes": "Plants looking healthy after morning watering."
  }'
```

---

## Testing Checklist

After inserting samples:
- [ ] All 9 entries appear in the Diary list
- [ ] Search finds entries by title
- [ ] Filter by activity type works
- [ ] Filter by date range shows correct entries
- [ ] Click on entries to view full details
- [ ] Weather data displays correctly
- [ ] Plant health status shows
- [ ] Sync status indicators work
- [ ] Edit functionality works
- [ ] Delete functionality works

## Data Points Demonstrated

These 9 samples cover:

| Sample | Activity | Weather | Observations | Inputs | Notes |
|--------|----------|---------|--------------|--------|-------|
| 1 | Watering | Sunny, 22°C | Good health | 150L water | Routine |
| 2 | Fertilizing | Cloudy, 26°C | Good health | NPK 5kg | Nutrients |
| 3 | Pest Control | Sunny, 31°C | Fair, mites | Neem oil 2L | Treatment |
| 4 | Inspection | Cloudy, 24°C | Excellent | None | Routine |
| 5 | Pruning | Sunny, 27°C | Good | Pruning tools | Maintenance |
| 6 | Weeding | Cloudy, 23°C | Good | Hand tools | Maintenance |
| 7 | Disease Treatment | Rainy, 20°C | Fair, fungal | Fungicide 3L | Preventive |
| 8 | Harvesting | Sunny, 28°C | Excellent | Harvest tools | Yield |
| 9 | Other | Sunny, 25°C | Good | Trellis/labor | Infrastructure |

---

## Recommended Insert Order
1. Inspection (to establish baseline)
2. Fertilizing (early stage)
3. Watering (routine)
4. Weeding (maintenance)
5. Pest Control (issue found)
6. Disease Treatment (prevention)
7. Pruning (maintenance)
8. Harvesting (result)
9. Other (infrastructure)

This order shows a realistic farm management timeline!

---

## Tips for Best Results

1. **Stagger Dates**: Insert with dates spread across 7-10 days for realistic data
2. **Use Real Coordinates**: Update latitude/longitude to your actual farm location
3. **Weather Patterns**: Make sure weather conditions make sense for the dates
4. **Activity Sequence**: Follow the recommended insert order for logical flow
5. **Test Both**: Try both API insertion and manual app entry for comprehensive testing

## Next Steps

After testing with samples:
- [ ] Verify all API CRUD operations work
- [ ] Test offline creation & sync
- [ ] Export/backup your test data
- [ ] Plan production data strategy
- [ ] Train users with real scenarios
