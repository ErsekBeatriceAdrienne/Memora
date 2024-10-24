# Entry point for your application

from user_service import create_user, get_user, update_user, delete_user
from event_service import create_event, get_event, update_event, delete_event

# Example usage
if __name__ == "__main__":
    # User CRUD operations
    user_id = create_user("john_doe", "john@example.com", "url_to_profile_pic")
    print(f"Created User ID: {user_id}")

    user_info = get_user(user_id)
    print("User Info:", user_info)

    update_user(user_id, {"friends": ["friend_user_id"]})
    print("Updated User Info:", get_user(user_id))

    delete_user(user_id)
    print("User deleted.")

    # Event CRUD operations
    event_id = create_event("Birthday Party", "2024-10-25T18:00:00Z", "John's House", 
                            "Celebrating John's 30th birthday!", 
                            ["user1_id", "user2_id"], 
                            user_id)  # Assuming user_id is the creator's ID
    print(f"Created Event ID: {event_id}")

    event_info = get_event(event_id)
    print("Event Info:", event_info)

    update_event(event_id, {"title": "Updated Birthday Party"})
    print("Updated Event Info:", get_event(event_id))

    delete_event(event_id)
    print("Event deleted.")
