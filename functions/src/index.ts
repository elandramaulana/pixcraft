import {onRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {GoogleAuth} from "google-auth-library";
import axios from "axios";

// Define secret
const serviceAccountSecret = defineSecret("GOOGLE_SERVICE_ACCOUNT");

/**
 * Test Imagen 4 Fast - Functions v2
 */
export const testImagen = onRequest(
  {
    secrets: [serviceAccountSecret],
    timeoutSeconds: 120,
    memory: "512MiB",
    region: "us-central1",
  },
  async (req, res) => {
    try {
      // Step 1: Get service account dari secret
      console.log("Step 1: Loading service account secret...");

      let serviceAccountJson: string;
      try {
        serviceAccountJson = serviceAccountSecret.value();
        console.log("✅ Secret loaded successfully");
      } catch (error) {
        console.error("❌ Failed to load secret:", error);
        res.status(500).json({
          success: false,
          error: "Failed to load service account secret",
          details:
            "Secret GOOGLE_SERVICE_ACCOUNT not found or not accessible",
          hint: "Run: firebase functions:secrets:set GOOGLE_SERVICE_ACCOUNT",
        });
        return;
      }

      // Step 2: Parse service account JSON
      console.log("Step 2: Parsing service account JSON...");

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      let serviceAccount: any;
      try {
        serviceAccount = JSON.parse(serviceAccountJson);
        console.log("✅ JSON parsed successfully");
        console.log("Project ID:", serviceAccount.project_id);
        console.log("Client email:", serviceAccount.client_email);
      } catch (error) {
        console.error("❌ Failed to parse JSON:", error);
        res.status(500).json({
          success: false,
          error: "Invalid service account JSON format",
          details: error instanceof Error ? error.message : String(error),
        });
        return;
      }

      // Step 3: Create auth client
      console.log("Step 3: Creating auth client...");

      const auth = new GoogleAuth({
        credentials: serviceAccount,
        scopes: ["https://www.googleapis.com/auth/cloud-platform"],
      });

      console.log("✅ Auth client created");

      // Step 4: Get access token
      console.log("Step 4: Getting access token...");

      const client = await auth.getClient();
      const accessToken = await client.getAccessToken();

      if (!accessToken.token) {
        throw new Error("Failed to obtain access token");
      }

      console.log("✅ Access token obtained");

      // Step 5: Call Imagen API
      console.log("Step 5: Calling Imagen API...");

      const projectId = serviceAccount.project_id;
      const endpoint = `https://us-central1-aiplatform.googleapis.com/v1/projects/${projectId}/locations/us-central1/publishers/google/models/imagen-4.0-fast-generate-001:predict`;

      console.log("Endpoint:", endpoint);

      const requestBody = {
        instances: [
          {
            prompt: "A beautiful sunset at a tropical beach with palm trees",
          },
        ],
        parameters: {
          sampleCount: 1,
          aspectRatio: "1:1",
          safetyFilterLevel: "block_some",
          personGeneration: "allow_adult",
        },
      };

      const response = await axios.post(endpoint, requestBody, {
        headers: {
          "Authorization": `Bearer ${accessToken.token}`,
          "Content-Type": "application/json",
        },
        timeout: 60000,
      });

      console.log("✅ Response received:", response.status);

      // Step 6: Process response
      const predictions = response.data.predictions;

      if (predictions && predictions.length > 0) {
        const imageBase64 = predictions[0].bytesBase64Encoded;

        res.status(200).json({
          success: true,
          message: "Image generated successfully! 🎉",
          model: "imagen-4.0-fast-generate-001",
          imageSize: imageBase64?.length || 0,
          imagePreview: imageBase64?.substring(0, 50) + "...",
          timestamp: new Date().toISOString(),
        });
      } else {
        res.status(200).json({
          success: false,
          message: "No predictions returned",
          rawResponse: response.data,
        });
      }
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      console.error("❌ Error:", error);

      // Better error messages
      let errorMessage = error.message;
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const errorDetails: any = {};

      if (error.response) {
        // Axios error with response
        errorMessage = error.response.data?.error?.message || error.message;
        errorDetails.status = error.response.status;
        errorDetails.statusText = error.response.statusText;
        errorDetails.data = error.response.data;
      }

      res.status(500).json({
        success: false,
        error: errorMessage,
        errorDetails,
        stack: error.stack?.split("\n").slice(0, 3),
      });
    }
  }
);
