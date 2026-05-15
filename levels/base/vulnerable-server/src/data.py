"""
Mock employee data for workshop demonstration.

Represents an HR system MCP server — a realistic enterprise scenario
where PII exposure and unauthorized access have immediate real-world consequences.

⚠️ DO NOT use real data! This is for educational purposes only.
"""

# Mock HR employee database
USERS = {
    "emp_001": {
        "name": "Alice Johnson",
        "email": "alice.johnson@contoso.com",
        "department": "Engineering",
        "role": "Senior Software Engineer",
        "ssn_last4": "1234",
        "salary": 135000,
        "phone": "555-0101",
        "manager": "emp_003"
    },
    "emp_002": {
        "name": "Bob Smith",
        "email": "bob.smith@contoso.com",
        "department": "Finance",
        "role": "Financial Analyst",
        "ssn_last4": "5678",
        "salary": 95000,
        "phone": "555-0102",
        "manager": "emp_003"
    },
    "emp_003": {
        "name": "Carol Williams",
        "email": "carol.williams@contoso.com",
        "department": "Engineering",
        "role": "Engineering Director",
        "ssn_last4": "9012",
        "salary": 185000,
        "phone": "555-0103",
        "manager": None
    }
}

