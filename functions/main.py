# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

# The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
from enum import Enum
from pydantic import BaseModel
from openai import OpenAI
import os
import json

from firebase_functions import firestore_fn, https_fn
from firebase_admin import initialize_app, credentials, firestore
import sparky_prompt, bizy_prompt, bruno_prompt


cred = credentials.Certificate("fauna-ed8b5-firebase-adminsdk-h5itr-b46b7666c2.json") # todo: put certufication key here
initialize_app(cred)
db = firestore.client()

@https_fn.on_call(secrets=["OPENAI_APIKEY"])
def sparky_completion(req: https_fn.CallableRequest) -> any:
    client = OpenAI(api_key=os.environ.get("OPENAI_APIKEY"))

    try:
        id = req.data["sparky_id"]
        dialogues = req.data["dialogues"]
        summary = db.collection('sparky').document(id).get().get('summary')

        prompt = sparky_prompt.get_prompt()

        if not summary and not dialogues:
            dialogues = [{
                'role': 'user',
                'content': 'Who are you?'
            }]
        
        if summary:
            numbered_summary = "\n".join([f"{i+1}. {item}" for i, item in enumerate(summary)])
            prompt.append({
                "role": "system", 
                "content": f"Following contents are your memory with this user:\n{numbered_summary}"
            })
            
            if not dialogues:
                prompt.append({
                    "role": "system", 
                    "content": "This is the start of this conversation. Greet to user based on the memory. Asking if user have new problem."
                })
        
        if dialogues:
            prompt.append({
                "role": "system", 
                "content": "Following contents are conversation happening now:"
            })
            prompt += dialogues
    except Exception as e:
        raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
                                  message=('Something wrong with the prompt.'),
                                  details=e)

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=prompt,
            response_format=sparky_prompt.get_response_schema()
        )
        message = response.choices[0].message.content
        message = json.loads(message)
        return message
    
    except Exception as e:
        raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.UNKNOWN,
                                  message="Error",
                                  details=e)
    
@https_fn.on_call(secrets=["OPENAI_APIKEY"])
def bizy_completion(req: https_fn.CallableRequest) -> any:
    client = OpenAI(api_key=os.environ.get("OPENAI_APIKEY"))
    try:
        id = req.data["user_id"]
        dialogues = req.data["dialogues"]
        bizy_type = req.data["bizy_type"]
        summary = db.collection('users').document(f'user_{id}').get().get('summary')

        prompt = bizy_prompt.get_prompt(bizy_type)
        prompt.append({"role":"assistant", "content":"please consider this SUMMARY for the user: " + summary})
        prompt += dialogues

        if bizy_type == 'bizy_analysis':
            prompt.append({'role': 'assistant', 'content': "You've been changed to little bee who responsible for analysis."})
        elif bizy_type == 'bizy_main':
            prompt.append({'role': 'assistant', 'content': "You've been changed to the leader of a group of bees that help users manage procrastination and time."})

        
        
    except Exception as e:
        raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
                                  message=('Something wrong with the bizy prompt.'),
                                  details=e)

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=prompt,
            response_format=bizy_prompt.get_response_schema(bizy_type)
        )
        message = response.choices[0].message.content
        message = json.loads(message)

        return message
    
    except Exception as e:
        raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.UNKNOWN,
                                  message="Error",
                                  details=e)
    
@https_fn.on_call(secrets=["OPENAI_APIKEY"])
def bruno_completion(req: https_fn.CallableRequest) -> any:
    client = OpenAI(api_key=os.environ.get("OPENAI_APIKEY"))

    try:
        id = req.data["bruno_id"]
        dialogues = req.data["dialogues"]
        #Todo: get only latest summary from sparky

        if not isinstance(dialogues, list):
            raise ValueError("dialogues must be a list")
        if not id:
            raise ValueError("user_id cannot be empty")

        prompt = bruno_prompt.get_prompt()
        # prompt.append({"role":"assistant", "content":"please consider this SUMMARY for the user: " + summary})
        prompt += dialogues

    except Exception as e:
        raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
                                  message=('Something wrong with the bruno prompt.'),
                                  details=e)

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=prompt,
            response_format=bruno_prompt.get_response_schema()
        )
        message = response.choices[0].message.content
        message = json.loads(message)
        return message
    
    except Exception as e:
        raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.UNKNOWN,
                                  message="Error",
                                  details=e)
    
@https_fn.on_call(secrets=["OPENAI_APIKEY"])
def update_summary(req: https_fn.CallableRequest) -> any:
    client = OpenAI(api_key=os.environ.get("OPENAI_APIKEY"))
    dialogues = req.data["dialogues"]
    #sparkyId = req.data["sparkyId"]
    action = req.data["action"]
    prompt = [
        #Todo: Detailed summary prompt for remembering agents user met before.
        {'role': 'system', 'content': f'Please summarize the above conversation in 100 words or less. Notice that you have already done the {action} action, and user had already talk to it. Please summary it into it also.'}, 
    ]
    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=dialogues + prompt,
        )
        message = response.choices[0].message.content
        db.collection("sparky").document("sparky_01").update({"summary" : firestore.ArrayUnion([message])})
        return message
    
    except Exception as e:
        raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.UNKNOWN,
                                  message="Error",
                                  details=e)
