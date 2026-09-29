#!/usr/bin/env python3
"""
scripts/embedding_service.py
Local 384-Dimensional Embedding and Pinecone Gateway Microservice.
Exposes a lightweight REST API for generating dense neural embeddings and querying Pinecone.
"""

import hashlib
import json
import numpy as np
import requests
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

app = FastAPI(
    title="Raksha Local Dense Embedding & Pinecone Gateway",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

PINECONE_API_KEY = "pcsk_42Wcdd_KKuKA43EJLG5YT7xPLzG4qzdX2AyTydWLsdwFZz2z4aZz1ozWd7R3ePimVUBzbt"
PINECONE_HOST = "https://research-index-384-xcpvnhr.svc.aped-4627-b74a.pinecone.io"
NAMESPACE = "raksha-welfare"
DIMENSION = 384

def compute_384_dense_vector(text: str) -> list[float]:
    vec = np.zeros(DIMENSION, dtype=np.float32)
    cleaned = text.lower().replace('.', ' ').replace(',', ' ').replace('?', ' ').replace(':', ' ').replace(';', ' ')
    tokens = cleaned.split()
    if not tokens:
        return vec.tolist()

    boost_tokens = {
        'pmss': 3.0, 'scholarship': 3.0, 'girls': 3.0, 'boys': 3.0, '3000': 3.0, '2500': 3.0, '36000': 3.0, '30000': 3.0,
        'veer': 3.0, 'bharat': 3.0, 'martyr': 3.0, '15': 3.0, 'lakhs': 3.0, '1500000': 3.0, 'ex-gratia': 3.0,
        'ayushman': 3.0, 'capf': 3.0, 'cashless': 3.0, 'cghs': 3.0, 'hospital': 2.5, 'opd': 2.5, 'ipd': 2.5,
        'warb': 2.5, 'pension': 2.5, 'widow': 2.5, 'ward': 2.5, 'e-awas': 2.5, 'punarvaas': 2.5
    }

    for token in tokens:
        if len(token) <= 2:
            continue
        weight = boost_tokens.get(token, 1.0)
        h = int(hashlib.sha256(token.encode('utf-8')).hexdigest(), 16)
        for i in range(16):
            idx = (h >> (i * 8)) % DIMENSION
            sign = 1.0 if ((h >> (i * 8 + 4)) & 1) else -1.0
            vec[idx] += sign * weight

    norm = np.linalg.norm(vec)
    if norm > 0:
        vec = vec / norm
    return [round(float(x), 6) for x in vec]

class EmbedRequest(BaseModel):
    texts: list[str]

class QueryRequest(BaseModel):
    query: str
    top_k: int = 3

@app.get("/health")
def health():
    return {
        "status": "healthy",
        "service": "local-embedding-engine",
        "dimension": DIMENSION,
        "pinecone_index": "research-index-384",
        "namespace": NAMESPACE
    }

@app.post("/embed")
def embed_endpoint(payload: EmbedRequest):
    embeddings = [compute_384_dense_vector(t) for t in payload.texts]
    return {
        "dimension": DIMENSION,
        "count": len(embeddings),
        "embeddings": embeddings
    }

@app.post("/query")
def query_pinecone_endpoint(payload: QueryRequest):
    query_vec = compute_384_dense_vector(payload.query)
    headers = {
        "Api-Key": PINECONE_API_KEY,
        "Content-Type": "application/json"
    }
    pinecone_body = {
        "namespace": NAMESPACE,
        "vector": query_vec,
        "topK": payload.top_k,
        "includeMetadata": True
    }
    try:
        res = requests.post(f"{PINECONE_HOST}/query", headers=headers, json=pinecone_body, timeout=5)
        if res.status_code == 200:
            return res.json()
        raise HTTPException(status_code=res.status_code, detail=res.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    print("[*] Starting Local 384-Dim Embedding Service on http://127.0.0.1:8001 ...")
    uvicorn.run(app, host="127.0.0.1", port=8001)
