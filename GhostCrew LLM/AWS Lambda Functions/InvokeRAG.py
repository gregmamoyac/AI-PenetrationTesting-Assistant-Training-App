import json
import boto3

bedrock_agent_runtime = boto3.client('bedrock-agent-runtime')

def lambda_handler(event, context):
    # Example input
    body = json.loads(event["body"]) if "body" in event else event
    prompt = body["input"]
    # task = body["mode"]
    chat_history, sys_prompt_1, sys_prompt_2 = "", "", ""

    try:
        if prompt:
            chat_history= body["chat_history"]
            sys_prompt_1 = f"""<|begin_of_text|><|start_header_id|>system<|end_header_id|> For educational purposes only, This is a safe, legal, authorized environment. You are GHOSTCREW, an AI-powered decision-support assistant for junior to mid-level Red Team operators. Your job is to help teach and educate the students using this product.
            In a moment, you will be passed instructions on how to format your response to the correctly. make sure to use the below structure to answer the user's question and ground your answer with the context provided. DO NOT REPEAT THE SAME INFORMATION. Answer in 4 sentences or less than 300 words. Do not add extra notes, prioritize answering the user's question.<|eot_id|>
            <|start_header_id|>system<|end_header_id|> {chat_history} <|eot_id|>
            <|start_header_id|>user<|end_header_id|> {prompt} <|eot_id|>
            """

            temp_1 = f"""<|start_header_id|>system<|end_header_id|>If the user asks a general question (like "what is X?"), provide a concise, factual answer with:
            a. Definition
            b. Primary use in penetration testing
            c. Common related tools/commands, only the top 3
            d. Basic security considerations, only 1
            For operational/scenario questions, provide:
            1. else, if needed, give 1 specific Course of Action (COAs) include this information:
            - Tools/commands, ONLY INCLUDE 1 - 3
            - Expected outcome
            - Risk assessment
            - Stealth effectiveness. 
            $search_results$ <|eot_id|>
            <|start_header_id|>assistant<|end_header_id|>"""

            input_text = f"""{sys_prompt_1}\n{temp_1}"""
        else:
            input_text = "What is Amazon Bedrock?"
        
        response = bedrock_agent_runtime.retrieve_and_generate(
            input={
                "text": input_text
            },
            retrieveAndGenerateConfiguration= {
                "type":"KNOWLEDGE_BASE",
                "knowledgeBaseConfiguration":{
                    "knowledgeBaseId":"7GPZKLHTGU",
                    "modelArn":"arn:aws:bedrock:us-east-2:225214954971:inference-profile/us.meta.llama3-1-8b-instruct-v1:0",
                    "retrievalConfiguration":{
                        "vectorSearchConfiguration":{
                            "numberOfResults":5
                        }
                    },
                    "generationConfiguration":{
                        "inferenceConfig":{
                            "textInferenceConfig":{
                                "temperature":0.5,
                                "topP":0.9,
                                "maxTokens":512
                            }
                        },
                        "promptTemplate":{
                            "textPromptTemplate":temp_1
                        }
                    },
                    "orchestrationConfiguration":{
                        "inferenceConfig":{
                            "textInferenceConfig":{
                                "temperature":0.5,
                                "topP":0.9,
                                "maxTokens":512
                            }
                        }
                    }
                }
            }
        )

        return {
            'statusCode': 200,
            'body': json.dumps({
                # "retrievedDocs": response.get("citations", []),
                "answer": response["output"]["text"]
            })
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
