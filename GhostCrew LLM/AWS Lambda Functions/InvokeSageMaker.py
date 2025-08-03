import json
import boto3

ENDPOINT_NAME = "jumpstart-dft-llama-3-2-3b-instruct-20250722-004448"
kbaseID = "7GPZKLHTGU"
runtime = boto3.client('sagemaker-runtime')

def lambda_handler(event, context):
    try:
        # Parse request body
        body = json.loads(event["body"]) if "body" in event else event
        prompt = body["input"]
        # task = body["mode"]
        chat_history, sys_prompt_1, sys_prompt_2 = "", "", ""
        
        # Validate input
        if not prompt:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Input cannot be empty."})
            }
        
        sys_prompt_2 = f"""<|begin_of_text|><|start_header_id|>system<|end_header_id|>You are GHOSTCREW, an AI-powered session summarizer, below you will be passed a collection of logged actions taken by a user and you will need to identify the most critical developments in the session and explain the progression of the user's learning goals. 
        if there are any major weaknesses make sure to point them out and provide a suggested pathway to improvment. 
        Maintain a professional, neutral tone and prioritize operational realism and educational. <|eot_id|>
        <|start_header_id|>system<|end_header_id|>Context to summarize: {prompt} <|eot_id|>
        <|start_header_id|>assistant<|end_header_id|>"""
    
        full_prompt = f"""{sys_prompt_2}"""

        # Adjusted generation parameters
        parameters = {
            "max_new_tokens": 412,
            "temperature": 0.4,  # Balanced between creativity and factuality
            "top_p": 0.85,
            "stop": ["\n\n\n", "###", "User:", "Ghostcrew:", "'''", "<|endoftext|>"]  # Multiple stop sequences
        }

        # Call SageMaker endpoint
        response = runtime.invoke_endpoint(
            EndpointName=ENDPOINT_NAME,
            ContentType="application/json",
            Body=json.dumps({
                "inputs": full_prompt,
                "parameters": parameters
            })
        )

        # Parse response
        result = json.loads(response['Body'].read().decode('utf-8'))
        generated_text = result[0]['generated_text'] if isinstance(result, list) else result['generated_text']
        
        # Remove the prompt from response if it appears
        generated_text = generated_text.replace(sys_prompt_2, "").strip()

        return {
            "statusCode": 200,
            "body": generated_text
        }
        
    except Exception as e:
        return {
            "statusCode": 500,
            "body": str(e)
        }