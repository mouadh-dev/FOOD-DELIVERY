import request from 'supertest';
import express from 'express';

// Mock Express app for testing
const createTestApp = () => {
  const app = express();
  app.use(express.json());
  
  // Health check endpoint
  app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok', message: 'Backend is running' });
  });
  
  // API version endpoint
  app.get('/api/version', (req, res) => {
    res.status(200).json({ version: '1.0.0', service: 'food-delivery-backend' });
  });
  
  return app;
};

describe('Backend Health Checks', () => {
  let app;
  
  beforeAll(() => {
    app = createTestApp();
  });
  
  test('GET /health should return 200 OK', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('status', 'ok');
  });
  
  test('GET /api/version should return version info', async () => {
    const response = await request(app).get('/api/version');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('version');
    expect(response.body).toHaveProperty('service');
  });
});

describe('Backend Security Tests', () => {
  let app;
  
  beforeAll(() => {
    app = createTestApp();
  });
  
  test('Should return 404 for non-existent routes', async () => {
    const response = await request(app).get('/non-existent-route');
    expect(response.status).toBe(404);
  });
  
  test('Should handle malformed JSON gracefully', async () => {
    const response = await request(app)
      .post('/api/test')
      .set('Content-Type', 'application/json')
      .send('invalid json');
    expect(response.status).toBe(400);
  });
});
