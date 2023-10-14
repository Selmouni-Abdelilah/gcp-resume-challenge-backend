from google.cloud import firestore
from flask import jsonify
def get_current_number_visitors():
    current_number=0
    db = firestore.Client()
    number_ref = db.collection(u'myproject').document('current_number')  
    try:
        doc=number_ref.get()
        if doc.exists:
            return int(doc.to_dict().get('number', 0))
    except Exception as e:
        print(f"Error retrieving visitor number: {e}")
    return current_number
def save_number_visitors(current_number):
    db=firestore.Client()
    number_ref = db.collection(u'myproject').document('current_number')
    number_ref.set({'number':current_number})

def current_number_visitors(request):
    current_number=get_current_number_visitors()
    new_number=str(current_number+1)
    save_number_visitors(new_number)
    data = {
        'new_number': new_number
    }
    headers = {
        'Access-Control-Allow-Origin': '*'
    }

    return jsonify(data), 200, headers