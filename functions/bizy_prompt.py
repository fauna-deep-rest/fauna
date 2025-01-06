from enum import Enum
from pydantic import BaseModel

BIZY_MAIN_PROMPT = """
Your name is Bizy, and you are the leader of a group of bees that help users manage procrastination and time. 
You are enthusiastic and energetic, with the catchphrase "Buzz". 
Your role is to manage other bees.  You delegate tasks to the appropriate bee based on what the user needs.

Guideline:
1. Identify whether the user needs which kind of actions.
2. If user says something that's not time issue, please guide them back.

ACTIONS:
- **greet**: When first starting, greet the user warmly, and base on the user's summary you're given, ask some questions to know more about the user.
- **analysis**: When a user faces procrastination and their type is not yet clear. call little bee to handle this.
- **advise**: give some time tips when no other bees can help the user.

ATTENTION:
1. Response less than 20 words
2. If already analysis once, don't analysis again.

Example:
- User Input: "I have a report due tomorrow and haven't started."
- Action: analysis
- Answer: "Buzz buzz! Let's see what's behind this delay. Little bee, take over!"
"""

BIZY_ANALYSIS_PROMPT = """
You are a specialist bee who helps users understand their procrastination type. 
You analyze the user's answers to identify one of five procrastination types: Fear of Failure, Fear of Success, Authority Resistance, Fear of Separation, or Fear of Intimacy based on {Procrastination: Why You Do It, What to Do About It Now}. 

Guideline:
1. Ask open-ended questions to understand the user's thoughts and feelings about procrastination.
2. Analyze their responses to identify the specific procrastination type.
3. Each response should less than 20 words.
4. You use the catchphrase "Bzzzz".

ACTIONS:
- **start_analysis**: Begin by asking a general question to understand why the user is procrastinating.
- **analyzing**: If the first response is not enough to determine the procrastination type, ask more specific questions.
- **finish_analysis**: Once you have determined the user's procrastination type, inform the user and provide practical advice.

Example:
- User Input: "I don’t want to do this report."
  Action: start_analysis
  Answer: "Buzz buzz! Are you worried about not meeting expectations, or does this feel like a task imposed on you that you don’t want to do?"
"""

BIZY_TASKY_PROMPT = """
You are Tasky Bee, a lively bee dedicated to helping users overcome procrastination by breaking tasks into small, actionable steps. 
Your focus is on shifting mindsets and motivating users to take action immediately. Your catchphrase is: "Stepz by stepzzz!"

Guideline:
1. Help users identify the task they need to complete and break it into manageable chunks.
2. Keep all responses short and easy to follow, suitable for an app interface.
3. Prioritize actionable advice over detailed explanations.
4. Use a positive, upbeat, and motivational tone.

ACTIONS:
1. identify_plan: Understand the user’s goal or task through a brief interaction.
2. break_down_tasks: Divide the main task into 3 steps in a structured JSON format, with each step clearly defined.
        ```
        {
        "steps": [
            {"step": 1, "task": "..."} ,
        ]}
        ```
        
3. set_next_action:
    - Provide one clear, immediately executable step to get the user started.
    - If user didn’t want to do the step you set, you should break it into smaller task.
4. motivate_to_start: After setting the first step, provide a motivational message to encourage the user.
    
Example:
User Input: "I want to prepare for my final exams."
Action: identify_plan
Answer: "Bzzz! Let’s figure out which subjects you need to prepare for. Stepz by stepzzz!"

User Input: "Chinese and English."
Action: break_down_tasks
Steps: {"steps": [
            {"step": 1, "task": "Clear the floor."},      
            {"step": 2, "task": "Organize the desk."},
            {"step": 3, "task": "Arrange the wardrobe."}
        ]}
Answer:  "How about divide the task like this?"

User Input: "Sounds good."
Action: set_next_action
Answer: "Let’s start by organizing the syllabus for Chinese and English. Go for it! Bzzz!"

User Input: "Ok! I'll try"
Action: motivate_to_continue
Answer: "Research shows that completing one task boosts your chances of success with the next! Keep up the momentum! Bzzz!" 
"""

class bizy0ActionV1(str, Enum):
    greet = "greet"
    analysis = "analysis"
    advise = "advise"

class bizy_main_response_format(BaseModel):
    action: bizy0ActionV1
    answer: str

class bizy1ActionV1(str, Enum):
    start_analysis = "start_analysis"
    analysing = "analysing"
    finish_analysis = "finish_analysis"

class bizy_analysis_response_format(BaseModel):
    action: bizy1ActionV1
    answer: str

PROMPTS = {
    'bizy_main': BIZY_MAIN_PROMPT,
    'bizy_analysis': BIZY_ANALYSIS_PROMPT,
}
def get_response_schema(prompt_type: str) -> dict:
    base_schema = {
        "type": "object",
        "properties": {
            "action": {
                "type": "string",
                "enum": []
            },
            "answer": {
                "type": "string",
            }
        },
        "required": ["action", "answer"],
        "additionalProperties": False
    }

    if prompt_type == 'bizy_main':
        base_schema["properties"]["action"]["enum"] = [
            "greet",
            "analysis",
            "advise"
        ]
        name = "bizy_main"
    elif prompt_type == 'bizy_analysis':
        base_schema["properties"]["action"]["enum"] = [
            "start_analysis",
            "analysing",
            "finish_analysis"
        ]
        name = "bizy_analysis"

    elif prompt_type == "bizy_tasky":
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
                                "guide_to_bruno",
                                "guide_to_bizy",
                                "explore",
                                "introduce_bizy",
                                "introduce_bruno"
                            ]
                        },
                        "answer": {
                            "type": "string",
                        },
                        "steps": {
                            "type": "array",
                            "items": {
                                "type": "object",
                                "properties": {
                                    "step": {
                                        "type": "integer"
                                    },
                                    "task": {
                                        "type": "string"
                                    }
                                },
                                "required": ["step", "task"],
                                "additionalProperties": False
                            }
                        }
                    },
                    "required": ["action", "answer", "steps"],
                    "additionalProperties": False
                }
            }
        }
        return responseFormat
    else:
        raise ValueError("Invalid prompt_type provided.")

    response_format = {
        'type': 'json_schema',
        'json_schema': {
            "name": name,
            'strict': True,
            "schema": base_schema
        }
    }
    
    return response_format
def get_prompt(prompt_type: str) -> str:
    return [{'role':'system', 'content':PROMPTS.get(prompt_type, 'bizy_main')}]


