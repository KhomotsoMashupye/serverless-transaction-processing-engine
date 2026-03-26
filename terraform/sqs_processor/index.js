const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");
const { Client } = require("pg");

const clientSM = new SecretsManagerClient({ region: process.env.AWS_REGION || "af-south-1" });
let schemaInitialized = false;

const initSchema = async (dbClient) => {
    const createTableQuery = `
        CREATE TABLE IF NOT EXISTS transactions (
            id VARCHAR(50) PRIMARY KEY,
            amount DECIMAL(12, 2) NOT NULL,
            currency VARCHAR(10) NOT NULL,
            status VARCHAR(20) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    `;
    await dbClient.query(createTableQuery);
    schemaInitialized = true;
    console.log("Database schema verified/created.");
};

exports.handler = async (event) => {
    // 1. Fetch DB Password from Secrets Manager
    const command = new GetSecretValueCommand({ SecretId: process.env.SECRET_ARN });
    const secretResponse = await clientSM.send(command);
    const password = secretResponse.SecretString;

    const dbClient = new Client({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        database: process.env.DB_NAME,
        password: password,
        port: 5432,
        ssl: { rejectUnauthorized: false }
    });

    try {
        await dbClient.connect();

        // 2. Initialize table if this is a fresh cold start
        if (!schemaInitialized) {
            await initSchema(dbClient);
        }

        // 3. Process Batch
        for (const record of event.Records) {
            const body = JSON.parse(record.body);
            const query = "INSERT INTO transactions (id, amount, currency, status) VALUES ($1, $2, $3, $4) ON CONFLICT (id) DO NOTHING";
            const values = [body.transactionId, body.amount, body.currency, body.status];
            
            await dbClient.query(query, values);
            console.log(`Processed: ${body.transactionId}`);
        }

        return { statusCode: 200 };
    } catch (err) {
        console.error("Error:", err);
        throw err;
    } finally {
        await dbClient.end();
    }
};