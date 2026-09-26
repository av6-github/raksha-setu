import uuid
from supabase import create_client

url = 'https://jkayuhgxjkyffvvalsqt.supabase.co'
key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImprYXl1aGd4amt5ZmZ2dmFsc3F0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MDMzNjYxOCwiZXhwIjoyMTA1OTEyNjE4fQ.dqjnBLXee05nP-pVrr10-4awOkGsfkwEniOAGJW6DUo'
sb = create_client(url, key)

docs = [
    {
        'id': 'd1111111-1111-1111-1111-111111111111',
        'scheme_name': 'Prime Minister Scholarship Scheme (PMSS) for CAPFs & AR',
        'issuing_authority': 'Welfare and Rehabilitation Board (WARB), Ministry of Home Affairs',
        'official_reference_number': 'WARB/2024/PMSS/01',
        'effective_date': '2024-04-01',
        'language': 'en',
        'document_version': '2024-25',
        'chunks': [
            'Eligibility Criteria: Dependent wards and widows of Central Armed Police Forces (CRPF, BSF, CISF, ITBP, SSB) and Assam Rifles personnel. Minimum educational qualification is 60% marks in Minimum Entry Qualification (MEQ) such as 10+2 or Diploma/Graduation.',
            'Financial Grant Structure: Rs 3,000 per month for girls (Rs 36,000 annually) and Rs 2,500 per month for boys (Rs 30,000 annually). Disbursed directly into the student bank account via Direct Benefit Transfer (DBT) through the National Scholarship Portal (NSP).',
            'Approved Courses: Professional and technical degree programs recognised by regulatory bodies such as AICTE and UGC. Eligible degrees include B.Tech, MBBS, BDS, B.Pharm, BBA, BCA, MBA, and MCA. Strictly not applicable for general master or diploma courses.'
        ]
    },
    {
        'id': 'd2222222-2222-2222-2222-222222222222',
        'scheme_name': "Bharat Ke Veer (India's Bravehearts) Trust",
        'issuing_authority': 'Ministry of Home Affairs, Government of India',
        'official_reference_number': 'MHA/BKV/TRUST/2017',
        'effective_date': '2017-04-09',
        'language': 'en',
        'document_version': '1.3',
        'chunks': [
            'Objective: To enable compassionate citizens and corporate donors to contribute financial assistance directly to the bank accounts of Next of Kin (NoK) of CAPF and Assam Rifles martyrs who laid down their lives in the line of duty.',
            'Financial Ceiling: Maximum financial assistance of up to Rs 15 Lakh per braveheart Next of Kin. If public contributions for an individual martyr exceed Rs 15 Lakh, the excess amount is routed to the Bharat Ke Veer General Corpus Fund.',
            'General Corpus: Contributions exceeding Rs 25 Lakh or sent directly to the corpus are managed by a high-level committee including Union Home Secretary and CAPF Director Generals to disburse equitable assistance.'
        ]
    },
    {
        'id': 'd3333333-3333-3333-3333-333333333333',
        'scheme_name': 'Ayushman CAPF Healthcare Scheme',
        'issuing_authority': 'National Health Authority (NHA) & MHA',
        'official_reference_number': 'NHA/MHA/CAPF/2021/04',
        'effective_date': '2021-01-23',
        'language': 'en',
        'document_version': '2.1',
        'chunks': [
            'Coverage: Comprehensive cashless and paperless healthcare across all empaneled CGHS and Ayushman Bharat PM-JAY hospital networks across India for serving personnel and their eligible dependent family members.',
            'Reimbursement Workflow: OPD (outpatient) claims and IPD (inpatient) emergency admissions in non-empaneled hospitals can be claimed directly via the Ayushman CAPF IT Portal using the electronic Ayushman CAPF Health Card.',
            'Medicines & Diagnostics: Cashless diagnostic tests and pharmacy disbursements at all empaneled healthcare centers and government military hospital composite dispensaries.'
        ]
    },
    {
        'id': 'd4444444-4444-4444-4444-444444444444',
        'scheme_name': 'Central Ex-Gratia Lumpsum Compensation',
        'issuing_authority': 'Ministry of Personnel, Public Grievances and Pensions & MHA',
        'official_reference_number': 'PPG/MHA/EX-GRATIA/2016',
        'effective_date': '2016-08-01',
        'language': 'en',
        'document_version': '2016-REV',
        'chunks': [
            'Death in Line of Duty: Rs 25 Lakh for death occurring due to accidents in course of duties. Rs 35 Lakh for death occurring in the course of duties attributable to acts of violence by terrorists, anti-social elements, or during border skirmishes.',
            'High-Altitude & Counter-Insurgency: Rs 45 Lakh for death occurring in high-altitude terrain (above 14,000 ft) or during specific counter-terrorist operations in designated operational theatres.'
        ]
    },
    {
        'id': 'd5555555-5555-5555-5555-555555555555',
        'scheme_name': 'Central Government Health Scheme (CGHS) Ward Entitlements',
        'issuing_authority': 'Ministry of Health and Family Welfare',
        'official_reference_number': 'MOHFW/CGHS/WARD/2023',
        'effective_date': '2023-10-28',
        'language': 'en',
        'document_version': '2023-REV',
        'chunks': [
            'Ward Categories: General Ward for Basic Pay up to Rs 36,500; Semi-Private Ward for Basic Pay Rs 36,501 to Rs 50,500; Private Ward for Basic Pay above Rs 50,500.',
            'Specialist Consultations: Direct cashless consultation at CGHS wellness centres and empaneled private hospitals upon referral by Composite Hospital Chief Medical Officer.'
        ]
    }
]

for doc in docs:
    chunks = doc.pop('chunks')
    sb.table('welfare_scheme_documents').upsert(doc).execute()
    for idx, c in enumerate(chunks):
        chunk_data = {
            'id': str(uuid.uuid4()),
            'document_id': doc['id'],
            'chunk_index': idx + 1,
            'content': c,
            'token_count': len(c.split()),
            'embedding_model': 'all-MiniLM-L6-v2',
            'pinecone_vector_id': f"{doc['id']}_chunk_{idx + 1}",
            'metadata': {'scheme_name': doc['scheme_name']}
        }
        sb.table('welfare_scheme_chunks').upsert(chunk_data, on_conflict='document_id,chunk_index').execute()

print('Corpus successfully seeded into Supabase!')
