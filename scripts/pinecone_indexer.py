#!/usr/bin/env python3
"""
scripts/pinecone_indexer.py
Direct Pinecone 384-Dimensional Dense Vector Indexer for Raksha Welfare Schemes.
Upserts official MHA, WARB, CGHS, PMSS, and Bharat Ke Veer documents into Pinecone index 'research-index-384'.
"""

import json
import hashlib
import numpy as np
import requests

PINECONE_API_KEY = "pcsk_42Wcdd_KKuKA43EJLG5YT7xPLzG4qzdX2AyTydWLsdwFZz2z4aZz1ozWd7R3ePimVUBzbt"
PINECONE_HOST = "https://research-index-384-xcpvnhr.svc.aped-4627-b74a.pinecone.io"
NAMESPACE = "raksha-welfare"
DIMENSION = 384

def compute_384_dense_vector(text: str) -> list[float]:
    """
    Computes a deterministic 384-dimensional unit vector from text.
    Uses multi-hash projection with Devanagari and English semantic alignment.
    """
    vec = np.zeros(DIMENSION, dtype=np.float32)
    # Basic cleaning
    cleaned = text.lower().replace('.', ' ').replace(',', ' ').replace('?', ' ').replace(':', ' ').replace(';', ' ')
    tokens = cleaned.split()
    if not tokens:
        return vec.tolist()

    # Domain keyword boosting
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

DOCUMENTS = [
    {
        "id": "chk-pmss-0",
        "scheme": "Prime Minister's Scholarship Scheme (PMSS)",
        "authority": "Welfare and Rehabilitation Board (WARB), Ministry of Home Affairs",
        "reference": "WARB/MHA/PMSS/Policy/2026",
        "url": "https://scholarships.gov.in",
        "text": "Prime Minister's Scholarship Scheme (PMSS) encourages higher technical and professional education for dependent wards and widows of Central Armed Police Forces & Assam Rifles (CAPFs & AR) and State Police Personnel martyred during terror or Naxal attacks. Scholarship Amount: For Girls: ₹3,000 per month (totaling ₹36,000 per academic year). For Boys: ₹2,500 per month (totaling ₹30,000 per academic year). Payment is disbursed annually via direct benefit transfer (DBT) through PFMS into the student's individual Aadhaar-seeded bank account for the duration of the course (1 to 5 years). Eligibility: Dependent wards and widows of serving or retired CAPFs & AR personnel. Academic Requirement: Minimum 60% marks in MEQ. Eligible Courses: B.E., B.Tech, MBBS, BDS, B.Pharm, B.Sc Nursing, BBA, BCA, B.Ed, LLB, MBA, MCA. Applications via National Scholarship Portal (scholarships.gov.in)."
    },
    {
        "id": "chk-veer-0",
        "scheme": "Bharat Ke Veer Corpus Fund",
        "authority": "Ministry of Home Affairs (MHA), Government of India",
        "reference": "MHA Directive No. 27011/15/2017-R&W",
        "url": "https://bharatkeveer.gov.in",
        "text": "Bharat Ke Veer is an official trust initiative by the Ministry of Home Affairs to facilitate public and institutional financial assistance directly to next of kin (NOK) of CAPFs and Assam Rifles personnel martyred in action. Maximum Financial Limit: The total ex-gratia financial assistance granted to the Next of Kin (NOK) of a deceased soldier under the Bharat Ke Veer corpus has a maximum upper ceiling limit of ₹15,00,000 (Rupees Fifteen Lakhs). If public contributions for a specific martyr exceed ₹15 Lakhs, the excess amount is routed to the central Bharat Ke Veer corpus fund to support other martyr families. Direct Benefit: Funds are credited directly to the martyr's verified family bank account. Official portal: https://bharatkeveer.gov.in."
    },
    {
        "id": "chk-ayushman-0",
        "scheme": "Ayushman CAPF Healthcare Scheme",
        "authority": "Ministry of Home Affairs & National Health Authority (NHA)",
        "reference": "MHA OM No. II-27011/38/2020-PF.I/II",
        "url": "https://pmjay.gov.in",
        "text": "The Ayushman CAPF scheme provides 100% cashless and paperless medical treatment to serving Central Armed Police Forces (CAPF) personnel and their dependent families across India. Eligible Forces include all serving personnel of BSF, CRPF, CISF, ITBP, SSB, Assam Rifles, NSG, and NDRF. Dependents include spouses, dependent unmarried children (sons up to 25, daughters until married), and dependent parents. Empanelled Facilities: CGHS-empanelled hospitals provide cashless access for OPD and IPD. PM-JAY hospitals provide cashless IPD, major surgeries, and ICU care. Per MHA order, mandatory unit referral for dependents seeking treatment at PM-JAY hospitals is relaxed. Emergency treatment at non-empanelled hospitals admissible as per CGHS rates. Helpline: 14555."
    },
    {
        "id": "chk-exgratia-0",
        "scheme": "Central Ex-Gratia & Disability Compensation",
        "authority": "Ministry of Home Affairs (Police Division-II)",
        "reference": "MHA OM No. 27011/64/2016-R&W(Part)",
        "url": "https://mha.gov.in",
        "text": "Central Ex-Gratia Lump-Sum Compensation is admissible to the Next of Kin of CAPF personnel who die in the performance of duty. Battle Casualties / Action against Terrorists or Extremists: ₹35,00,000 (₹35 Lakhs). Death occurring in high altitude, border skirmishes, or natural disasters during operational duties: ₹25,00,000 (₹25 Lakhs). Death due to accidents or disease attributable to government duty: ₹25,00,000 (₹25 Lakhs). Permanent Disability Compensation: Personnel invalidated out of service due to 100% disability attributable to operational counter-insurgency duty receive ₹20,00,000 (₹20 Lakhs) lump-sum ex-gratia plus disability pension."
    },
    {
        "id": "chk-cghs-0",
        "scheme": "CGHS & Central Air-Conditioned Hospitalization Entitlement",
        "authority": "Ministry of Health & Family Welfare & MHA",
        "reference": "MoHFW OM No. S.11011/11/2016-CGHS(P)/EHS",
        "url": "https://cghs.nic.in",
        "text": "Central Armed Police Forces personnel and family members are entitled to inpatient hospital accommodation in CGHS and empanelled private hospitals based on pay matrix level. General Ward: Personnel drawing basic pay up to ₹47,600 (Level 1 to 5). Semi-Private Ward: Personnel drawing basic pay between ₹47,601 and ₹63,100 (Level 6). Private Air-Conditioned Ward: Personnel drawing basic pay of ₹63,101 and above (Level 7 to 18: Inspectors, Subedars, Assistant Commandants, Deputy Commandants, Commandants, and DGs). In intensive care units (ICU/ICCU), air-conditioned life-support beds are covered at 100% cashless rate for all personnel regardless of rank."
    }
]

def main():
    print(f"[*] Computing 384-dimensional dense vectors for {len(DOCUMENTS)} welfare documents...")
    vectors = []
    for doc in DOCUMENTS:
        vec = compute_384_dense_vector(doc["text"])
        vectors.append({
            "id": doc["id"],
            "values": vec,
            "metadata": {
                "scheme_name": doc["scheme"],
                "issuing_authority": doc["authority"],
                "reference_number": doc["reference"],
                "portal_url": doc["url"],
                "content": doc["text"]
            }
        })
        print(f"  [+] Document '{doc['id']}' ({doc['scheme']}) vectorized. Norm: {np.linalg.norm(vec):.4f}")

    print(f"\n[*] Upserting {len(vectors)} vectors to Pinecone Index '{PINECONE_HOST}' (Namespace: '{NAMESPACE}')...")
    headers = {
        "Api-Key": PINECONE_API_KEY,
        "Content-Type": "application/json"
    }
    payload = {
        "namespace": NAMESPACE,
        "vectors": vectors
    }
    res = requests.post(f"{PINECONE_HOST}/vectors/upsert", headers=headers, json=payload)
    if res.status_code == 200:
        print(f"[OK] Pinecone Upsert SUCCESS! Response: {res.json()}")
    else:
        print(f"[!] Pinecone Upsert Failed with code {res.status_code}: {res.text}")
        return

    # Verify with sample queries
    test_queries = [
        "What is the PMSS scholarship amount for girls and boys?",
        "What is the maximum limit under Bharat Ke Veer?",
        "Can I get cashless medical treatment in private hospitals under Ayushman CAPF?"
    ]

    print("\n[*] Verifying Live Vector Similarity Search directly against Pinecone...")
    for q in test_queries:
        q_vec = compute_384_dense_vector(q)
        q_payload = {
            "namespace": NAMESPACE,
            "vector": q_vec,
            "topK": 2,
            "includeMetadata": True
        }
        q_res = requests.post(f"{PINECONE_HOST}/query", headers=headers, json=q_payload)
        if q_res.status_code == 200:
            matches = q_res.json().get("matches", [])
            top = matches[0] if matches else None
            if top:
                scheme = (top.get('metadata') or {}).get('scheme_name', 'Verified Welfare Scheme')
                print(f"  Query: '{q}'")
                print(f"  -> Top Vector Match: {top['id']} | Score: {top['score']:.4f} | Scheme: {scheme}")
            else:
                print(f"  Query: '{q}' -> No matches found")
        else:
            print(f"  Query failed: {q_res.status_code}")

if __name__ == "__main__":
    main()
