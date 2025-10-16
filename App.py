import os
import joblib
import numpy as np
import pandas as pd
import requests
import datetime
from flask import Flask, request, jsonify

# ===================================================================
# Initialize Flask App and Load Models
# ===================================================================
app = Flask(__name__)

# Load the trained model and scalers when the app starts
# This is more efficient than loading them for every request
try:
    model = joblib.load("seattle_model.pkl")
    scaler_x = joblib.load("seattle_scaler_x.pkl")
    scaler_y = joblib.load("seattle_scaler_y.pkl")
except FileNotFoundError:
    print("Model files not found! Make sure they are in the same directory.")
    exit()

# Your OpenWeatherMap API Key
API_KEY = "92a24d2e7f25f11ca36f13af4e4f9359" # It's better to use an environment variable for this

# ===================================================================
# Helper Functions (Your logic, adapted for the API)
# ===================================================================

def fetch_historical_weather(lat=47.6062, lon=-122.3321, days=14):
    """Fetches the last 14 days of weather data from OpenWeatherMap."""
    all_data = []
    base_url = "https://api.openweathermap.org/data/2.5/onecall/timemachine"
    
    for i in range(days, 0, -1):
        # Go back `i` days from now
        past_date = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(days=i)
        timestamp = int(past_date.timestamp())
        
        # API request
        url = f"{base_url}?lat={lat}&lon={lon}&dt={timestamp}&appid={API_KEY}&units=metric"
        response = requests.get(url)
        
        if response.status_code == 200:
            r = response.json()
            # We need to handle cases where 'current' or other keys might be missing
            current_data = r.get('current', {})
            temp = current_data.get('temp', 10) # Default value if missing
            humidity = current_data.get('humidity', 50)
            
            # The 'timemachine' API often doesn't give precipitation for the past, so we'll default to 0
            precipitation = 0 
            
            all_data.append([past_date, temp, temp, humidity, 0, precipitation])
        else:
            # If API fails for a day, append some default data
            all_data.append([past_date, 10, 10, 50, 0, 0]) # Default values

    # Create a DataFrame
    df = pd.DataFrame(all_data, columns=['date', 'temp_max', 'temp_min', 'humidity', 'wind', 'precipitation'])
    return df

def create_prediction_from_api():
    """Main function to get data, create features, and predict."""
    
    # 1. Fetch the last 14 days of data
    df_history = fetch_historical_weather(days=14)

    # 2. Create lag features for the prediction
    # The input for our model requires 14 days of lag features for 4 variables (temp_max, temp_min, humidity, wind)
    # Total features = 14 lags * 4 variables = 56 features
    
    latest_features = []
    for lag in range(1, 15):
        latest_features.extend([
            df_history['temp_max'].iloc[-lag],
            df_history['temp_min'].iloc[-lag],
            df_history['humidity'].iloc[-lag],
            df_history['wind'].iloc[-lag],
        ])

    # 3. Predict the next 7 days iteratively
    predictions = []
    current_input_features = np.array(latest_features).reshape(1, -1)

    for _ in range(7):
        # Scale the input
        scaled_input = scaler_x.transform(current_input_features)
        
        # Predict
        scaled_pred = model.predict(scaled_input)
        
        # Inverse transform the prediction to get actual values
        prediction = scaler_y.inverse_transform(scaled_pred)
        predictions.append(prediction[0])
        
        # Update the input features for the next day's prediction
        # The new prediction becomes the lag_1 feature for the next iteration
        new_features = prediction[0] # [temp_max, temp_min, humidity, wind]
        current_input_features = np.roll(current_input_features, -4) # Shift features left
        current_input_features[0, -4:] = new_features # Add new prediction at the end

    return predictions

# ===================================================================
# API Endpoint
# ===================================================================
@app.route('/predict', methods=['GET'])
def predict():
    """
    This is the main endpoint of the API.
    It returns a 7-day weather forecast for Seattle.
    """
    try:
        # Get the 7-day forecast
        forecast_values = create_prediction_from_api()
        
        # Format the response into a nice JSON
        response_data = []
        today = datetime.datetime.now()
        
        for i, values in enumerate(forecast_values):
            day_date = today + datetime.timedelta(days=i + 1)
            temp_max, temp_min, humidity, wind = values
            
            # Simple alert logic
            alert = "Normal weather"
            if temp_max > 30:
                alert = "Heatwave Warning"
            elif temp_min < 5:
                alert = "Cold Weather Alert"

            response_data.append({
                "day": day_date.strftime("%A"),
                "date": day_date.strftime("%Y-%m-%d"),
                "temp_max_c": round(temp_max, 2),
                "temp_min_c": round(temp_min, 2),
                "humidity_percent": round(humidity, 2),
                "wind_speed_ms": round(wind, 2),
                "alert": alert
            })
            
        return jsonify(response_data)

    except Exception as e:
        # Return an error message if something goes wrong
        return jsonify({"error": str(e)}), 500

# To run the app locally
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)