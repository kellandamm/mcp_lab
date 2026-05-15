# Secure MCP Server

This is the **secure version** of the Module 0 MCP server, demonstrating how to fix OWASP MCP07 (Insufficient Authentication & Authorization) and MCP01 (Token Mismanagement & Secret Exposure).

## Security Improvements

✅ **Bearer Token Authentication** - All requests require a valid token  
✅ **Authorization Checks** - Users can only access their own data  
✅ **Secure by Default** - Rejects unauthenticated requests  
✅ **Clear Error Messages** - Explains why access was denied

## Quick Start

### 1. Configure Authentication

```bash
# Copy the example environment file
cp .env.example .env

# The default token is: workshop_demo_token_12345
# This token maps to user_001 (Alice Johnson)
```

### 2. Run the Server

```bash
cd modules/base-module/secure-server
uv run --project .. python -m src.server
```

You should see:

```
🔒 Module 0 - Secure MCP Server (Streamable HTTP)
✅ AUTHENTICATION ENABLED
   Required token: workshop_demo_token_12345
```

The server runs on **port 8001** (different from vulnerable server on 8000).

## Testing the Security

### Method 1: Python Test Script

```bash
cd modules/base-module/exploits
uv run --project .. python test_secure.py
```

This will test:
- ✅ Connection succeeds with valid token
- ❌ Connection fails without token
- ✅ Can access own data (user_001)
- ❌ Cannot access other users' data (user_002, user_003)

### Method 2: MCP Inspector

```bash
cd modules/base-module/exploits
./launch-inspector-http.sh
```

Then:
1. Change the URL to: `http://localhost:8001/mcp`
2. Add HTTP Header:
   - **Name:** `Authorization`
   - **Value:** `Bearer workshop_demo_token_12345`
   - **Important:** Enable the toggle button next to the header!
3. Connect and try to access resources

**Note:** VS Code's MCP extension expects OAuth and won't work with simple bearer tokens. Use MCP Inspector or the automated test script instead.

## What's Still Missing?

⚠️ **This is NOT production-ready!** It still lacks:

- ❌ Token expiration and refresh
- ❌ Secure token storage (uses .env, not Azure Key Vault)
- ❌ OAuth 2.1 / OIDC standards
- ❌ Azure Entra ID integration
- ❌ Role-Based Access Control (RBAC)
- ❌ Audit logging
- ❌ Rate limiting

**Module 1: Identity & Access Management** covers all of these with Azure services!

## Code Structure

```python
# Authentication decorator
@require_auth
async def my_handler(...):
    # Validates Bearer token
    # Rejects if invalid/missing

# Authorization check
def check_authorization(requested_user_id, authenticated_user):
    # Verifies user can access resource
    return requested_user_id == authenticated_user

# Applied to all resources and tools
@mcp.resource("user://{user_id}")
@require_auth  # ← Authentication required
async def get_user_resource(user_id, authenticated_user):
    # Authorization check
    if not check_authorization(user_id, authenticated_user):
        raise PermissionError("Cannot access other user's data")
    # ... return data
```

## Key Takeaways

1. **Defense in Depth** - Both authentication AND authorization
2. **Fail Secure** - Reject by default, allow only with permission
3. **Least Privilege** - Users only access their own data
4. **Simple ≠ Secure** - Basic tokens are NOT enough for production

Ready to learn production-grade security? Continue to **Module 1**! 🏔️
