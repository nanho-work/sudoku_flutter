import os
import json
import firebase_admin
from firebase_admin import credentials, firestore

# 🔹 Firebase 서비스 계정 키 경로 (경로 수정 필요)
SERVICE_ACCOUNT_PATH = "/Users/choenamho/Documents/GitHub/sudoku_flutter/lib/firebase_service_account.json"

# 🔹 업로드할 스테이지 JSON 파일 폴더
STAGE_FOLDER = "assets/stages"

# 🔹 Firestore 컬렉션명
COLLECTION_NAME = "stages"


def initialize_firestore():
    """Firebase Firestore 초기화"""
    if not firebase_admin._apps:
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        firebase_admin.initialize_app(cred)
    return firestore.client()


def upload_stage_json(db, filepath):
    """단일 스테이지 JSON 업로드"""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            data = json.load(f)

        stage_id = data.get("id")
        if not stage_id:
            print(f"⚠️  {filepath}: 'id' 필드가 없습니다. 건너뜀.")
            return

        # Firestore는 중첩 배열을 허용하지 않으므로,
        # 'puzzle', 'solution', 'block_pattern' 같은 복잡한 필드는 JSON 문자열로 변환하여 저장
        for key in ["puzzle", "solution"]:
            if key in data and isinstance(data[key], list):
                data[key] = json.dumps(data[key])

        db.collection(COLLECTION_NAME).document(stage_id).set(data)
        print(f"✅ 업로드 완료 → {stage_id}")

    except Exception as e:
        print(f"❌ 업로드 실패 ({filepath}): {e}")


def upload_all_stages():
    """폴더 내 모든 스테이지 JSON 업로드"""
    db = initialize_firestore()

    for filename in os.listdir(STAGE_FOLDER):
        if not filename.endswith(".json"):
            continue
        if filename == "stage_index.json":
            continue  # index 파일은 제외

        filepath = os.path.join(STAGE_FOLDER, filename)
        upload_stage_json(db, filepath)

    print("\n🎯 모든 스테이지 업로드 완료.")


if __name__ == "__main__":
    print("🚀 Firestore 스테이지 업로드 시작...")
    upload_all_stages()