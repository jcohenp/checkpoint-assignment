import time
import boto3
import json

s3 = boto3.client('s3', endpoint_url='http://localhost:4566', region_name='us-east-1')  # LocalStack S3 endpoint
sqs = boto3.client('sqs', endpoint_url='http://localhost:4566')  # LocalStack SQS endpoint
ssm = boto3.client('ssm', endpoint_url='http://localhost:4566')  # LocalStack SSM endpoint

def get_sqs_from_ssm():
    try:
        response = ssm.get_parameter(
            Name='my_sqs_queue',
            WithDecryption=True
        )
        return response['Parameter']['Value']
    except Exception as e:
        print(f"Error getting sqs queue from SSM: {str(e)}")
        return None

def get_bucket_from_ssm():
    try:
        response = ssm.get_parameter(
            Name='S3_bucket',
            WithDecryption=True
        )
        return response['Parameter']['Value']
    except Exception as e:
        print(f"Error getting sqs queue from SSM: {str(e)}")
        return None

def process_messages():
    queue_url = get_sqs_from_ssm()
    bucket_name = get_bucket_from_ssm()
    print(bucket_name)
    while True:
        response = sqs.receive_message(
            QueueUrl=queue_url,
            AttributeNames=[
                'All'
            ],
            MessageAttributeNames=[
                'All'
            ],
            MaxNumberOfMessages=1,
            VisibilityTimeout=0,
            WaitTimeSeconds=0
        )

        if 'Messages' in response:
            for message in response['Messages']:
                try:
                    body = eval(message['Body'])
                    user_data = body.get("data")
                    s3.put_object(
                        Bucket=bucket_name,
                        Key=f'sqs_message_{user_data.get("email_timestream")}.json',
                        Body=json.dumps(user_data)
                    )

                    # Delete the processed message from the queue
                    sqs.delete_message(
                        QueueUrl=queue_url,
                        ReceiptHandle=message['ReceiptHandle']
                    )

                except Exception as e:
                    print(f"Error processing message: {str(e)}")

        time.sleep(5)  # Adjust the sleep interval as needed

if __name__ == '__main__':
    process_messages()
