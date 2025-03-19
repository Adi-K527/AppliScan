import AWS from 'aws-sdk'
import env from 'dotenv'

class AWSResourceHandler {
    constructor() {
        this.dynamodbClient = new AWS.DynamoDB.DocumentClient({
            region: 'us-east-1',
            accessKeyId: process.env.AWS_ACCESS_KEY_ID,
            secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
        })

        this.firehoseClient = new AWS.Firehose({
            region: 'us-east-1',
            accessKeyId: process.env.AWS_ACCESS_KEY_ID,
            secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
        })
    }

    async insert(userID, emailToken) {
        const params = {
            TableName: "Appliscan_Email_Table",
            Item: {
                UserId:     userID,
                EmailToken: emailToken,
                CreatedAt:  new Date().toISOString()
            }
        }
        
        try {
            const data = await this.dynamodbClient.put(params).promise()
            return data
        } catch (err) {
            console.error(err)
            return err
        }        
    }

    async read() {
        const params = {
            TableName: "Appliscan_Email_Table",
        }
        
        try {
            const data = await this.dynamodbClient.scan(params).promise()
            return data.Items
        } catch (err) {
            console.error(err)
            return err
        }
    }

    async firehosePUT(emails) {
        const params = {
            DeliveryStreamName: "appliscan-email-preprocessor",
            Record: {
                Data: JSON.stringify(emails) + "\n"
            }
        }

        try {
            const result = await this.firehoseClient.putRecord(params).promise();
            return result;
        } catch (error) {
            console.error("Error sending data to Firehose:", error);
            throw error;
        }
    }
}

export default AWSResourceHandler