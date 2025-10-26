Servicio de predicción FastAPI para Urbansafe

Esta carpeta contiene una pequeña aplicación FastAPI que implementa un endpoint `/predict` para calcular un "nivel de riesgo" a partir de latitud/longitud.

Descripción general
- `app/main.py`: aplicación FastAPI. Verifica tokens de ID de Firebase, carga un modelo de ML (joblib), expone `POST /predict` y opcionalmente escribe el resultado de vuelta en Firestore.
- `requirements.txt`: dependencias de Python para pruebas locales y despliegue.
- `Dockerfile`: imagen lista para desplegar en Cloud Run.

Cómo ejecutar localmente (desarrollo)
1. Instala las dependencias en un entorno Python 3.11+:

```powershell
python -m pip install -r ml_service/requirements.txt
```

2. Proporciona las credenciales para acceder a Firestore (establece `GOOGLE_APPLICATION_CREDENTIALS` apuntando al JSON de la cuenta de servicio) o usa las credenciales predeterminadas de la aplicación (ADC) cuando se ejecute en GCP.

3. Ejecuta la aplicación:

```powershell
uvicorn ml_service.app.main:app --reload --port 8080
```

API
- POST /predict
  - body: { lat: number, lng: number, measurement_doc_path?: string }
  - header: Authorization: Bearer <Firebase ID token>
  - response: { score: number, label: string }

Despliegue
- Construye y sube la imagen Docker y despliega en Cloud Run. Revisa los comentarios en `Dockerfile` para detalles.

Notas
- El servicio intentará cargar la ruta indicada por la variable de entorno `MODEL_PATH` (por defecto `ml_service/model.pkl`). Si no existe un modelo, se usa un modelo dummy (ficticio) para desarrollo.
- En producción, el equipo de ML debe proporcionar el artefacto del modelo entrenado; la ruta del modelo se puede pasar mediante `MODEL_PATH` o montarse dentro del contenedor.
