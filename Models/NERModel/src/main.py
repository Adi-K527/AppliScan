from openai import OpenAI

def lambda_handler(event, context):
    client = OpenAI()

    response = client.responses.create(
        model="gpt-4o",
        input="Write a one-sentence bedtime story about a unicorn."
    )

    print(response.output_text)
