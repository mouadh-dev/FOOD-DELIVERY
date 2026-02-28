import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import validator from 'validator';

describe('Security Utilities Tests', () => {
  describe('Password Hashing (bcrypt)', () => {
    test('Should hash password successfully', async () => {
      const password = 'TestPassword123!';
      const hashedPassword = await bcrypt.hash(password, 10);
      
      expect(hashedPassword).toBeDefined();
      expect(hashedPassword).not.toBe(password);
      expect(hashedPassword.length).toBeGreaterThan(0);
    });
    
    test('Should verify correct password', async () => {
      const password = 'TestPassword123!';
      const hashedPassword = await bcrypt.hash(password, 10);
      const isMatch = await bcrypt.compare(password, hashedPassword);
      
      expect(isMatch).toBe(true);
    });
    
    test('Should reject incorrect password', async () => {
      const password = 'TestPassword123!';
      const wrongPassword = 'WrongPassword123!';
      const hashedPassword = await bcrypt.hash(password, 10);
      const isMatch = await bcrypt.compare(wrongPassword, hashedPassword);
      
      expect(isMatch).toBe(false);
    });
  });
  
  describe('JWT Token Generation', () => {
    const secret = 'test-secret-key';
    
    test('Should generate valid JWT token', () => {
      const payload = { userId: '12345', email: 'test@example.com' };
      const token = jwt.sign(payload, secret, { expiresIn: '1h' });
      
      expect(token).toBeDefined();
      expect(typeof token).toBe('string');
      expect(token.split('.').length).toBe(3); // JWT has 3 parts
    });
    
    test('Should verify and decode JWT token', () => {
      const payload = { userId: '12345', email: 'test@example.com' };
      const token = jwt.sign(payload, secret, { expiresIn: '1h' });
      const decoded = jwt.verify(token, secret);
      
      expect(decoded.userId).toBe(payload.userId);
      expect(decoded.email).toBe(payload.email);
    });
    
    test('Should reject invalid JWT token', () => {
      const invalidToken = 'invalid.token.here';
      
      expect(() => {
        jwt.verify(invalidToken, secret);
      }).toThrow();
    });
  });
  
  describe('Input Validation', () => {
    test('Should validate email format', () => {
      expect(validator.isEmail('test@example.com')).toBe(true);
      expect(validator.isEmail('invalid-email')).toBe(false);
      expect(validator.isEmail('test@')).toBe(false);
    });
    
    test('Should validate strong passwords', () => {
      const strongPassword = 'StrongPass123!';
      const weakPassword = '123';
      
      expect(validator.isStrongPassword(strongPassword)).toBe(true);
      expect(validator.isStrongPassword(weakPassword)).toBe(false);
    });
    
    test('Should sanitize user input', () => {
      const maliciousInput = '<script>alert("XSS")</script>';
      const sanitized = validator.escape(maliciousInput);
      
      expect(sanitized).not.toContain('<script>');
      expect(sanitized).toContain('&lt;script&gt;');
    });
  });
});
