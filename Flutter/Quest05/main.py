# main.py
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import tensorflow as tf
from tensorflow.keras.applications.vgg16 import VGG16, preprocess_input, decode_predictions
from tensorflow.keras.preprocessing import image
import numpy as np
import io
from PIL import Image
import uvicorn

app = FastAPI()

# CORS 설정 (Flutter 웹앱에서 API 호출 허용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# VGG16 모델 로드
model = VGG16(weights='imagenet')

@app.get("/")
def read_root():
    return {"message": "Jellyfish Classifier API"}

@app.get("/sample")
def sample_prediction():
    """
    샘플 예측 결과를 반환하는 엔드포인트 (테스트용)
    """
    # 원래 예시 값이 아니라 실제 분석 결과와 같은 형태로 반환
    return {
        "predicted_label": "moon_jellyfish",
        "prediction_score": 0.99991536
    }

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """
    이미지를 업로드하고 VGG16 모델로 분류하는 엔드포인트
    """
    try:
        # 업로드된 이미지 처리
        contents = await file.read()
        img = Image.open(io.BytesIO(contents))
        img = img.resize((224, 224))
        
        # 이미지 전처리
        img_array = image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)
        img_array = preprocess_input(img_array)
        
        # 예측
        predictions = model.predict(img_array)
        decoded = decode_predictions(predictions, top=1)[0][0]
        
        # 결과 반환
        label = decoded[1]
        score = float(decoded[2])
        
        return {
            "predicted_label": label,
            "prediction_score": score
        }
    except Exception as e:
        import traceback
        traceback.print_exc()
        return {"error": str(e)}, 500