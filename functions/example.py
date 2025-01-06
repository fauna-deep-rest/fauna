# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

# The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
from firebase_functions import firestore_fn, https_fn
from firebase_admin import initialize_app, credentials, firestore

cred = credentials.Certificate("prototype-a9eae-388ec599cab0.json")
initialize_app(cred)
db = firestore.client()

@https_fn.on_request()
def on_request_example(req: https_fn.Request) -> https_fn.Response:
    return https_fn.Response("Hello world from Firebase Cloud Functions for Python!")

@https_fn.on_call()
def addmessage(req: https_fn.CallableRequest) -> Any:
    """Saves a message to the Firebase Realtime Database but sanitizes the text
    by removing swear words."""
    
    try:
        text = req.data["text"]
    except KeyError:
        raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
                                  message=('The function must be called with one argument, "text",'
                                           " containing the message text to add."))

    if not isinstance(text, str) or len(text) < 1:
        raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
                                  message=('The function must be called with one argument, "text",'
                                           " containing the message text to add."))

    try:
        db.collection("messages").document("message").set({ 
             "text": text,
             "original": text
         })
        
        return {"text": text}
    except Exception as e:
        raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.UNKNOWN,
                                  message="Error",
                                  details=e)


@firestore_fn.on_document_created(document="messages/{pushId}")
def makeuppercase(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    """Listens for new documents to be added to /messages. If the document has
    an "original" field, creates an "uppercase" field containg the contents of
    "original" in upper case."""

    # Get the value of "original" if it exists.
    if event.data is None:
        return
    try:
        original = event.data.get("original")
    except KeyError:
        # No "original" field, so do nothing.
        return

    # Set the "uppercase" field.
    print(f"Uppercasing {event.params['pushId']}: {original}")
    upper = original.upper()
    event.data.reference.update({"uppercase": upper})