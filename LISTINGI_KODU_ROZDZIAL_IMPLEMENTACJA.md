# LISTINGI KODU - ROZDZIAŁ "IMPLEMENTACJA"

## 1. GŁÓWNA PĘTLA DETEKCJI

**Plik:** `camera_controller.py`  
**Linie:** 638-750

```python
ret, frame = self.camera.read()

# Walidacja klatki
if not ret or frame is None:
    continue

# Frame skipping - przetwarzanie co N-tą klatkę
self.frame_counter += 1
if self.frame_counter % self.process_every_n_frame != 0:
    continue

# Detekcja YOLOv8
if self.model is not None:
    enhanced_frame = self._enhance_frame_for_detection(frame)
    results = self.model(enhanced_frame, verbose=False)
    frame_height, frame_width = frame.shape[:2]
    
    for result in results:
        if result.boxes is None:
            continue
        boxes = result.boxes
        for box in boxes:
            class_id = int(box.cls[0])
            confidence = float(box.conf[0])
            
            # Filtrowanie: tylko telefony (class_id=67) powyżej progu
            if class_id == self.phone_class_id and confidence >= self.settings['confidence_threshold']:
                bx1, by1, bx2, by2 = map(float, box.xyxy[0])
                center_x = (bx1 + bx2) / 2.0
                center_y = (by1 + by2) / 2.0
                
                matched_zone = self.find_matching_zone(center_x, center_y, frame_width, frame_height)
                
                if matched_zone or len(self.roi_zones) == 0:
                    frame_copy = frame.copy()
                    self._handle_detection(frame_copy, confidence, matched_zone)
```

---

## 2. ZAPIS DETEKCJI DO PLIKU

**Plik:** `camera_controller.py`  
**Linie:** 512-544

```python
def _handle_detection(self, frame, confidence, zone_name=None):
    """Obsługuje wykrycie telefonu: zapisuje oryginalną klatkę i dodaje do kolejki"""
    try:
        os.makedirs('detections', exist_ok=True)
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f'phone_{timestamp}.jpg'
        filepath = os.path.join('detections', filename)
        
        # Zapis ORYGINALNEJ klatki (przed anonimizacją)
        success = cv2.imwrite(filepath, frame)
        if not success:
            raise Exception("Failed to save detection image")
        
        should_blur = self.settings.get('blur_faces', True)
        
        # Dodanie zadania do kolejki dla worker thread
        detection_data = {
            'filepath': filepath,
            'confidence': confidence,
            'should_blur': should_blur,
            'zone_name': zone_name
        }
        self.detection_queue.put(detection_data)
        
    except Exception as e:
        logging.error(f"Error saving detection: {e}")
```

---

## 3. ANONIMIZACJA GŁÓW (RODO)

**Plik:** `camera_controller.py`  
**Linie:** 1613-1672

```python
def _anonymize_faces(self, image_path):
    """Anonimizuje wykryte głowy używając modelu Roboflow i Gaussian blur"""
    image = cv2.imread(image_path)
    img_h, img_w = image.shape[:2]
    
    # Wykrywanie głów przez Roboflow API
    prediction = self.model.predict(image_path, confidence=40, overlap=30)
    results = prediction.json()
    
    heads_found = 0
    
    for det in results.get('predictions', []):
        confidence = det.get('confidence', 0)
        
        if confidence >= 0.4:
            heads_found += 1
            
            # Konwersja współrzędnych (Roboflow: środek + wymiary)
            center_x = int(det['x'])
            center_y = int(det['y'])
            width = int(det['width'])
            height = int(det['height'])
            
            x1 = center_x - width // 2
            y1 = center_y - height // 2
            x2 = center_x + width // 2
            y2 = center_y + height // 2
            
            # Walidacja granic obrazu
            x1, y1 = max(0, x1), max(0, y1)
            x2, y2 = min(img_w, x2), min(img_h, y2)
            
            if x2 <= x1 or y2 <= y1:
                continue
            
            # Wycięcie ROI i zastosowanie Gaussian blur
            roi = image[y1:y2, x1:x2]
            
            if roi.size > 0:
                blur = cv2.GaussianBlur(roi, (99, 99), 30)
                image[y1:y2, x1:x2] = blur
    
    # Nadpisanie pliku zanonimizowaną wersją
    success = cv2.imwrite(image_path, image)
    return success
```

---

## 4. STRUMIENIOWANIE WIDEO (MJPEG)

**Plik:** `app.py`  
**Linie:** 597-636

```python
def generate_frames():
    """Generator klatek wideo dla strumienia MJPEG"""
    while True:
        try:
            frame = camera_controller.get_last_frame()
            
            if frame is None:
                frame_bytes = PLACEHOLDER_BYTES
            else:
                # Przetwarzanie: filtr Canny dla prywatności
                gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
                edges = cv2.Canny(gray_frame, 100, 200)
                edges_color = cv2.cvtColor(edges, cv2.COLOR_GRAY2BGR)
                
                ret, buffer = cv2.imencode('.jpg', edges_color)
                if ret:
                    frame_bytes = buffer.tobytes()
                else:
                    frame_bytes = PLACEHOLDER_BYTES
        except Exception as e:
            frame_bytes = PLACEHOLDER_BYTES
        
        # Format MJPEG: multipart boundary
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')
        time.sleep(0.05)  # ~20 FPS

@app.route('/api/camera/video_feed', methods=['GET'])
@login_required
def video_feed():
    """Endpoint strumieniowania wideo jako MJPEG"""
    return Response(generate_frames(), 
                    mimetype='multipart/x-mixed-replace; boundary=frame')
```

---

## 5. MODEL BAZY DANYCH

**Plik:** `models.py`  
**Linie:** 33-40

```python
class Detection(db.Model):
    """Model SQLAlchemy reprezentujący pojedynczą detekcję telefonu"""
    id = db.Column(db.Integer, primary_key=True)
    timestamp = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    location = db.Column(db.String(100))  # Nazwa strefy ROI lub kamery
    confidence = db.Column(db.Float)  # Pewność detekcji (0.0-1.0)
    image_path = db.Column(db.String(200))  # Nazwa pliku obrazu
    status = db.Column(db.String(20))  # Status detekcji
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=True)
```

---

## 6. POBIERANIE DANYCH Z API (Frontend)

**Plik:** `src/services/api.ts`  
**Linie:** 84-90, 131-136

```typescript
// Pobieranie listy detekcji z paginacją
export const detectionAPI = {
  getAll: async (page: number = 1, perPage: number = 20): Promise<PaginatedDetectionsResponse> => {
    const response = await api.get<PaginatedDetectionsResponse>('/api/detections', {
      params: { page, per_page: perPage }
    });
    return response.data;
  }
};

// Pobieranie statystyk dashboardu
export const dashboardAPI = {
  getStats: async (): Promise<DashboardStats> => {
    const response = await api.get<DashboardStats>('/api/dashboard-stats');
    return response.data;
  }
};
```

**Uwaga:** Instancja `api` to skonfigurowany klient Axios z:
- `withCredentials: true` (cookies dla Flask-Login)
- Interceptorami dla autoryzacji i obsługi błędów 401
- Base URL z `process.env.REACT_APP_API_URL` lub proxy

---

## PODSUMOWANIE LISTINGÓW

1. **Główna pętla detekcji** - Przechwytywanie klatek, preprocessing, detekcja YOLOv8, filtrowanie wyników
2. **Zapis detekcji** - Zapis oryginalnej klatki do pliku i dodanie zadania do kolejki
3. **Anonimizacja** - Wykrywanie głów (Roboflow) i zastosowanie Gaussian blur dla RODO
4. **Strumieniowanie wideo** - Generator MJPEG stream z filtrem Canny dla prywatności
5. **Model bazy danych** - Definicja tabeli `Detection` w SQLAlchemy
6. **Pobieranie danych** - Funkcje Axios do komunikacji z REST API
