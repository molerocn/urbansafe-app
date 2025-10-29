"""Servicio FastAPI de predicción de nivel de riesgo.

Endpoints
- POST /predict

Seguridad
- Espera un Firebase ID token en el header Authorization: Bearer <token>. El token se verifica con firebase-admin.

Carga del modelo
- Intenta cargar el modelo desde la ruta indicada en la variable de entorno MODEL_PATH (por defecto: model.pkl).
    Si no existe, se usa un modelo dummy liviano para desarrollo.
"""
from fastapi import FastAPI, Header, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import logging

import firebase_admin
from firebase_admin import auth, credentials
from google.cloud import firestore

logger = logging.getLogger("ml_service")
logging.basicConfig(level=logging.INFO)

# Inicializar Firebase Admin
if not firebase_admin._apps:
    # Preferir una cuenta de servicio explícita mediante la variable de entorno
    # GOOGLE_APPLICATION_CREDENTIALS
    if os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
        cred = credentials.Certificate(os.environ["GOOGLE_APPLICATION_CREDENTIALS"])  # type: ignore
        firebase_admin.initialize_app(cred)
    else:
            # Credenciales por defecto de la aplicación (Application Default
            # Credentials), p.ej. al ejecutar en GCP
        try:
            firebase_admin.initialize_app()
        except Exception:
                # Si se ejecuta localmente sin ADC, la inicialización puede fallar;
                # permitimos que la app arranque para desarrollo pero la verificación
                # de tokens fallará si no hay credenciales válidas.
                logger.warning("firebase_admin.initialize_app() falló; la verificación de tokens fallará sin credenciales")

# Cliente de Firestore (usa ADC o la cuenta de servicio configurada arriba)
db = firestore.Client()

MODEL_PATH = os.environ.get("MODEL_PATH", "ml_service/model.pkl")

class PredictRequest(BaseModel):
    lat: float
    lng: float
    measurement_doc_path: str | None = None

def load_model(path: str):
    try:
        import joblib

        m = joblib.load(path)
        logger.info(f"Modelo cargado desde {path}")
        return m
    except Exception as e:
        logger.warning(f"No se pudo cargar el modelo en {path}: {e}; usando DummyModel")

        class DummyModel:
            def predict(self, X):
                # devolver un valor numérico en [0,1]
                return [0.5 for _ in X]

        return DummyModel()

model = load_model(MODEL_PATH)

def map_score_to_label(score: float) -> str:
    try:
        s = float(score)
    except Exception:
        return "unknown"
    if s < 0.33:
        return "low"
    if s < 0.66:
        return "medium"
    return "high"

app = FastAPI(title="Urbansafe ML predict")

# Permitir CORS para desarrollo; en producción restringir orígenes.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def verify_token(auth_header: str | None):
    if not auth_header:
        raise HTTPException(status_code=401, detail="Missing Authorization header")
    token = auth_header.split("Bearer ")[-1].strip()
    if not token:
        raise HTTPException(status_code=401, detail="Invalid Authorization header")
    try:
        decoded = auth.verify_id_token(token)
        return decoded
    except Exception as e:
        logger.exception("Fallo verificando token")
        raise HTTPException(status_code=401, detail=f"Token inválido: {e}")


@app.post("/predict")
async def predict(payload: PredictRequest, authorization: str | None = Header(None)):
    # Verificar el llamador (Firebase ID token)
    user = verify_token(authorization)
    uid = user.get("uid")
    logger.info(f"Predict solicitado por uid={uid} lat={payload.lat} lng={payload.lng}")

    # Construir características (para demo usamos [lat, lng])
    features = [payload.lat, payload.lng]

    try:
        score = float(model.predict([features])[0])
    except Exception as e:
        logger.exception("Model prediction failed")
        raise HTTPException(status_code=500, detail=f"Model error: {e}")

    label = map_score_to_label(score)
    result = {"score": score, "label": label}

    # Opcional: escribir el resultado de vuelta en el documento de Firestore
    # cuya ruta puede proporcionar el cliente
    if payload.measurement_doc_path:
        try:
            db.document(payload.measurement_doc_path).update({
                "nivel_riesgo": score,
                "nivel_riesgo_text": label,
                "risk_computed_by": "fastapi_predict"
            })
        except Exception as e:
            logger.exception("Fallo escribiendo la predicción en Firestore")
            raise HTTPException(status_code=500, detail=f"Error escribiendo en Firestore: {e}")

    return result


@app.post("/predict/risk")
async def predict_risk(payload: PredictRequest, authorization: str | None = Header(None)):
    """Alias que mantiene compatibilidad con clientes que llaman /predict/risk.
    Reutiliza la misma lógica que `/predict`.
    """
    return await predict(payload, authorization)
