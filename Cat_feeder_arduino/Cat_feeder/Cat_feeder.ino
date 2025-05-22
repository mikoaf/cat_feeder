#include <ESP32Servo.h>
#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "Kamu jelek";
const char* pass = "2801Miko";

const char* mqtt_broker = "broker.emqx.io";
const char* topic = "detect/kocheng";
const int mqtt_port = 1883;
const char* mqtt_username = "kocheng";
const char* mqtt_pass = "kucing123";

WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[50];
int value = 0;

unsigned long last_time = 0;
const unsigned long detect_time = 10000;

Servo myServo;

void callback(char* topic, byte* payload, unsigned int length) {
    Serial.print("Message arrived on topic: ");
    Serial.println(topic);
    Serial.print("Message: ");

    String message;
    for (int i = 0; i < length; i++) {
        message += (char)payload[i];
    }
    Serial.println(message);

    if (String(topic) == "detect/kocheng") {
        Serial.print("Changing output to ");
        if (message == "1") {
          unsigned long current_time = millis();

          if(current_time - last_time >= detect_time){
            Serial.println("Kocheng detect");
            myServo.write(55);
            delay(5000);
            myServo.write(15);
            last_time = current_time; 
          }
          else{
            myServo.write(15);
          }
        } else {
            myServo.write(15);
        }
    }
}

void setup() {
  Serial.begin(115200);
  myServo.attach(13);  
  myServo.write(15);
  WiFi.begin(ssid, pass);
  while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.println("Connecting to WiFi..");
  }
  client.setServer(mqtt_broker, mqtt_port);
  client.setCallback(callback);
  while (!client.connected()) {
      String client_id = "esp32-client-";
      client_id += String(WiFi.macAddress());
      Serial.printf("The client %s connects to the public MQTT broker\n", client_id.c_str());
      if (client.connect(client_id.c_str(), mqtt_username, mqtt_pass)) {
          Serial.println("Public EMQX MQTT broker connected");
          client.subscribe(topic);
      } else {
          Serial.print("failed with state ");
          Serial.print(client.state());
          delay(2000);
      }
  }
}

void loop() {
  client.loop();
}
