# Event management (CRUD operations)

from firebase_config import db

def create_event(title, date, location, description, invited_people, creator):
    event_ref = db.collection('Events').add({
        'title': title,
        'date': date,
        'location': location,
        'event_description': description,
        'invited_people': invited_people,
        'creator': creator,
        'gallery': []
    })
    return event_ref.id  # Return the auto-generated event ID

def get_event(event_id):
    event_doc = db.collection('Events').document(event_id).get()
    return event_doc.to_dict() if event_doc.exists else None

def update_event(event_id, updates):
    db.collection('Events').document(event_id).update(updates)

def delete_event(event_id):
    db.collection('Events').document(event_id).delete()
