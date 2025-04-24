import cv2
import random
from paho.mqtt import client as mqtt_client

# Load Haarcascade for cat face detection
face_cascade = cv2.CascadeClassifier('haarcascade_frontalcatface.xml')

# Configure video capture
cap = cv2.VideoCapture(0)

# MQTT configuration
broker = 'broker.emqx.io'
port = 1883
topic = "detect/kocheng"
client_id = f'mqttx_{random.randint(0, 10000)}'
username = 'kocheng'
password = 'kucing123'

# Connect to MQTT broker
def connect_mqtt():
    def on_connect(client, userdata, flags, rc, properties=None):
        if rc == 0:
            print("Connected to MQTT Broker!")
        else:
            print(f"Failed to connect, return code {rc}")

    # Create MQTT client instance
    client = mqtt_client.Client(client_id=client_id, callback_api_version=mqtt_client.CallbackAPIVersion.VERSION2)
    client.username_pw_set(username, password)
    client.on_connect = on_connect
    client.connect(broker, port)
    return client

# Main loop
client = connect_mqtt()
client.loop_start()

while True:
    ret, img = cap.read()

    if not ret:
        break

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)

    for (x, y, w, h) in faces:
        cv2.rectangle(img, (x, y), (x + w, y + h), (255, 0, 0), 2)
        # Publish message when a cat is detected
        client.publish(topic, "1")
        print("Cat detected! Message sent.")

    cv2.imshow('Cat Face Detection', img)

    if cv2.waitKey(1) & 0xFF == 27:
        break

cap.release()
cv2.destroyAllWindows()
client.loop_stop()
client.disconnect()