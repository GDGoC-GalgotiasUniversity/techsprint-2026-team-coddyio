#include <DHT.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>          // use WiFiClientSecure for HTTPS

// ----- Wi‑Fi & API -----
const char* WIFI_SSID = "Airtel_wireless fidility";
const char* WIFI_PASS = "jatingarg";
const char* POST_URL  = "http://172.22.48.1:3000/api/ingest"; // e.g., http://IP:PORT/path

// ----- Pins & sensor type (your wiring) -----
#define DHTPIN 2                 // NodeMCU D4 = GPIO2 (keeps code portable even if D4 alias missing)
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// ----- Calibration (replace after measuring) -----
int SOIL_DRY_ADC = 800;          // read in air and set
int SOIL_WET_ADC = 300;          // read fully wet and set

float adcToPercent(int adc) {
  int lo = min(SOIL_WET_ADC, SOIL_DRY_ADC);
  int hi = max(SOIL_WET_ADC, SOIL_DRY_ADC);
  adc = constrain(adc, lo, hi);
  float pct = 100.0f * (hi - adc) / float(hi - lo);
  return constrain(pct, 0.0f, 100.0f);
}

void waitForWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.print("WiFi: ");
  int tries = 0;
  while (WiFi.status() != WL_CONNECTED && tries < 60) { // ~30s
    delay(500); Serial.print(".");
    tries++;
  }
  Serial.println();
  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("WiFi OK, IP: "); Serial.println(WiFi.localIP());
  } else {
    Serial.println("WiFi not connected (timeout). Will retry later.");
  }
}

void setup() {
  Serial.begin(115200);
  delay(400);
  dht.begin();
  Serial.println("NodeMCU + DHT11 + Soil(A0) + HTTP POST");
  WiFi.persistent(false);        // avoid flash wear
  waitForWiFi();
}

void loop() {
  // Read sensors
  float h = dht.readHumidity();
  float t = dht.readTemperature();    // Celsius
  int soilRaw = analogRead(A0);       // 0..1023 on NodeMCU devkit

  if (isnan(h) || isnan(t)) {
    Serial.println("DHT read failed (check wiring/pull-up/sensor type)");
    delay(2000);
    return;
  }

  float soilPct = adcToPercent(soilRaw);

  // Print to Serial
  Serial.print("Temp(C): ");  Serial.print(t, 1);
  Serial.print(" | Hum(%): "); Serial.print(h, 1);
  Serial.print(" | SoilRaw: "); Serial.print(soilRaw);
  Serial.print(" | Soil(%): "); Serial.println(soilPct, 1);

  // POST JSON if Wi‑Fi is up
  if (WiFi.status() != WL_CONNECTED) {
    waitForWiFi(); // try to reconnect
  }
  if (WiFi.status() == WL_CONNECTED) {
    WiFiClient client;          // switch to WiFiClientSecure for HTTPS (see note)
    HTTPClient http;
    if (http.begin(client, POST_URL)) {
      http.addHeader("Content-Type", "application/json");

      // Build compact JSON
      String payload = String("{\"temperature\":") + String(t,1) +
                       ",\"humidity\":" + String(h,1) +
                       ",\"soil_raw\":" + String(soilRaw) +
                       ",\"soil_pct\":" + String(soilPct,1) + "}";

      int code = http.POST(payload);
      Serial.print("HTTP POST -> code: "); Serial.println(code);
      if (code > 0) {
        String body = http.getString();
        Serial.print("Response: "); Serial.println(body);
      }
      http.end();
    } else {
      Serial.println("HTTP begin() failed (bad URL?)");
    }
  } else {
    Serial.println("Skip POST (Wi‑Fi down).");
  }

  delay(2000); // DHT11 timing
}
