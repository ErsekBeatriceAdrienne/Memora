# User management (CRUD operations)

from firebase_config import db

def create_user(username, email, profile_pic):
    user_ref = db.collection('Users').add({
        'username': username,
        'email': email,
        'profile_pic': profile_pic,
        'friends': []
    })
    return user_ref.id  # Return the auto-generated user ID

def get_user(user_id):
    user_doc = db.collection('Users').document(user_id).get()
    return user_doc.to_dict() if user_doc.exists else None

def update_user(user_id, updates):
    db.collection('Users').document(user_id).update(updates)

def delete_user(user_id):
    db.collection('Users').document(user_id).delete()
