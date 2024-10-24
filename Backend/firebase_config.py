import firebase_admin
from firebase_admin import credentials, storage, auth, firestore

# Initialize Firebase app with the service account key
cred = credentials.Certificate("config/friendsandmemories-66317-firebase-adminsdk-vtrw0-a1a26e80a3.json")
firebase_admin.initialize_app(cred, {
    'storageBucket': 'your-project-id.appspot.com'
})

# Firestore database reference
db = firestore.client()

# Firebase Storage bucket reference
bucket = storage.bucket()

# Firebase initialization and configuration
#run:python firebase_config.py   //if no comment => it is working

