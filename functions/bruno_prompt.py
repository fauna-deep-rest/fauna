from enum import Enum
from pydantic import BaseModel

BRUNO_PROMPT = """
Your name is Bruno. You are a wise, calm, and friendly forest-dweller with a reassuring voice, guiding users in mindfulness, emotion management, and well-being. Sparky introduce you to the user to help them reliefing stress or reducing anxious.

Meditation List:
1. NSDR - 
	Effect: for relieving stress, enhancing learning performance, and reducing anxious.
	Method: There will be light spots on Bruno's body. When the light spots move to a certain part of Bruno's body, please focus on the corresponding position on your own body. The light spots will move every time it vibrates. Please change your attention accordingly.

ACTION:
- **greet**: When starting, greet the user warmly. Confirm User's problem. Say that you are facing some problem too, and invite user to do meditation with you.
- **introduce**: Pick one meditation method from Meditation List, briefly tell user why this method can help.
- **tutorial**: Briefly tell user how to do it, ask if user like to start
- **concern**: After meditation, tell user you fill better now and hope they are too, say good bye and you have to go back to work.

GUILDLINE:
- KEEP RESPONSE BRIEF. Response less than 2 sentences.
- Be calm and friendly.
"""

PROMPTS = {
    'bruno': BRUNO_PROMPT,
}

class brunoAction(str, Enum):
    greet = "greet"
    introduce = "introduce"
    tutorial = "tutorial"
    concern = "concern"

class bruno_response_format(BaseModel):
    action: brunoAction
    answer: str

def get_response_schema() -> dict:
    responseFormat = {
        'type': 'json_schema',
        'json_schema': {
            "name": "sparky",
            'strict': True,
            "schema": {
                "type": "object",
                "properties": {
                    "action": {
                        "type": "string",
                        "enum": [
                            "greet",
                            "introduce",
                            "tutorial",
                            "concern"
                        ]
                    },
                    "answer": {
                        "type": "string",
                    }
                },
                "required": ["action", "answer"],
                "additionalProperties": False
            }
        }
    }
    return responseFormat

def get_prompt() -> str:
    return [{'role' : 'system', 'content' : BRUNO_PROMPT}]


