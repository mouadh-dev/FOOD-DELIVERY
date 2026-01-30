# Security Configuration Guide

## 🔒 Security Headers Implemented

### Backend (Express.js)
- **Helmet**: Comprehensive security headers
- **CSP**: Content Security Policy to prevent XSS
- **HSTS**: Strict Transport Security for HTTPS
- **X-Frame-Options**: Prevent clickjacking
- **X-Content-Type-Options**: Prevent MIME sniffing
- **X-XSS-Protection**: Browser XSS protection

### Frontend (Nginx)
Add to nginx.conf:
```nginx
add_header X-Frame-Options "DENY" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self' http://localhost:4000;" always;
```

## 🛡️ Security Measures

### 1. Rate Limiting
- **API Endpoints**: 100 requests per 15 minutes
- **Authentication**: 5 login attempts per 15 minutes
- Prevents brute force attacks

### 2. Input Validation
- Email format validation
- Strong password enforcement (8+ chars, uppercase, lowercase, number)
- HTML sanitization to prevent XSS

### 3. MongoDB Injection Protection
- express-mongo-sanitize middleware
- Sanitizes user input before database queries

### 4. CORS Configuration
- Whitelist specific origins
- Credentials support for cookies
- Controlled HTTP methods

### 5. Authentication Security
- JWT tokens with expiration
- Password hashing with bcrypt (salt rounds: 10)
- Secure token storage recommendations

## 📊 DAST (Dynamic Application Security Testing)

### OWASP ZAP Integration
- Automated security scans
- Baseline scans for quick checks
- Full active scans for comprehensive testing
- Reports in HTML, JSON, XML, Markdown formats

### Common Vulnerabilities Checked
1. **SQL Injection**: Database query attacks
2. **XSS (Cross-Site Scripting)**: Malicious script injection
3. **CSRF (Cross-Site Request Forgery)**: Unauthorized requests
4. **Broken Authentication**: Weak auth mechanisms
5. **Sensitive Data Exposure**: Unencrypted data
6. **XML External Entities (XXE)**: XML parsing attacks
7. **Broken Access Control**: Unauthorized access
8. **Security Misconfiguration**: Insecure defaults
9. **Insecure Deserialization**: Object injection
10. **Using Components with Known Vulnerabilities**

## 🚀 Running DAST Scans

### Local Testing
```bash
# Start applications
docker-compose up -d

# Run DAST scan
./test-dast.sh
```

### Jenkins Integration
Automatically runs in the pipeline after deployment to staging.

## 🔧 Security Configuration Files

- `zap-config.yaml`: OWASP ZAP configuration
- `backend/middleware/security.js`: Express security middleware
- `nginx.conf`: Nginx security headers
- `test-dast.sh`: DAST testing script

## 📈 Security Metrics

### Severity Levels
- **High**: Critical vulnerabilities requiring immediate attention
- **Medium**: Important vulnerabilities to address soon
- **Low**: Minor issues with low risk
- **Informational**: Best practices and recommendations

### Acceptable Thresholds
- High: 0
- Medium: < 5
- Low: < 10
- Informational: Any

## 🔐 Production Security Checklist

- [ ] Enable HTTPS/TLS
- [ ] Configure CSP headers
- [ ] Enable HSTS
- [ ] Implement rate limiting
- [ ] Use secure session management
- [ ] Enable security logging
- [ ] Regular security audits
- [ ] Dependency vulnerability scanning
- [ ] Input validation on all endpoints
- [ ] Output encoding
- [ ] Secure password storage
- [ ] API authentication
- [ ] Environment variable protection
- [ ] Database access control
- [ ] Regular backups
- [ ] Incident response plan

## 🛠️ Installing Security Dependencies

```bash
cd backend
npm install helmet express-rate-limit express-mongo-sanitize
```

## 📚 Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP ZAP Documentation](https://www.zaproxy.org/docs/)
- [Helmet.js](https://helmetjs.github.io/)
- [Express Security Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)
