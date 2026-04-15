"""Salesforce MCP Server for Claude Code.

Exposes SOQL query, SOSL search, describe, and DML operations
via the Model Context Protocol using simple-salesforce.
"""

import json
import os
import logging

from mcp.server.fastmcp import FastMCP
from simple_salesforce import Salesforce, SalesforceError

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("salesforce-mcp")

mcp = FastMCP("salesforce")

# --- Connection ---

_sf = None


def _load_credentials() -> dict:
    """Load credentials from credentials.json, falling back to env vars."""
    cred_path = os.path.join(os.path.dirname(__file__), "credentials.json")
    if os.path.exists(cred_path):
        with open(cred_path, "r") as f:
            return json.load(f)
    return {
        "username": os.environ["SALESFORCE_USERNAME"],
        "password": os.environ["SALESFORCE_PASSWORD"],
        "security_token": os.environ.get("SALESFORCE_SECURITY_TOKEN", ""),
        "instance_url": os.environ.get("SALESFORCE_INSTANCE_URL", ""),
    }


def get_sf() -> Salesforce:
    global _sf
    if _sf is None:
        creds = _load_credentials()
        _sf = Salesforce(
            username=creds["username"],
            password=creds["password"],
            security_token=creds["security_token"],
            instance_url=creds["instance_url"],
        )
        logger.info("Connected to Salesforce as %s", creds["username"])
    return _sf


# --- Tools ---


@mcp.tool()
def salesforce_query(soql: str) -> str:
    """Execute a SOQL query and return results as JSON.

    Args:
        soql: A valid SOQL query string (e.g. "SELECT Id, Name FROM Account LIMIT 10")
    """
    try:
        sf = get_sf()
        result = sf.query_all(soql)
        records = result.get("records", [])
        clean = []
        for r in records:
            clean.append({k: v for k, v in r.items() if k != "attributes"})
        return json.dumps(
            {"totalSize": result["totalSize"], "records": clean},
            ensure_ascii=False,
            default=str,
        )
    except SalesforceError as e:
        return json.dumps({"error": str(e)})


@mcp.tool()
def salesforce_describe(object_name: str) -> str:
    """Describe a Salesforce object's fields and metadata.

    Args:
        object_name: API name of the object (e.g. "Account", "M_A_Project__c")
    """
    try:
        sf = get_sf()
        desc = getattr(sf, object_name).describe()
        fields = [
            {
                "name": f["name"],
                "label": f["label"],
                "type": f["type"],
                "length": f.get("length"),
                "referenceTo": f.get("referenceTo", []),
                "picklistValues": [
                    {"value": p["value"], "label": p["label"]}
                    for p in f.get("picklistValues", [])
                    if p.get("active")
                ]
                if f["type"] == "picklist"
                else [],
            }
            for f in desc["fields"]
        ]
        return json.dumps(
            {"name": desc["name"], "label": desc["label"], "fields": fields},
            ensure_ascii=False,
        )
    except SalesforceError as e:
        return json.dumps({"error": str(e)})


@mcp.tool()
def salesforce_search(sosl: str) -> str:
    """Execute a SOSL search query.

    Args:
        sosl: A valid SOSL query string (e.g. "FIND {Acme} IN ALL FIELDS RETURNING Account(Id, Name)")
    """
    try:
        sf = get_sf()
        result = sf.search(sosl)
        return json.dumps(result, ensure_ascii=False, default=str)
    except SalesforceError as e:
        return json.dumps({"error": str(e)})


@mcp.tool()
def salesforce_create(object_name: str, data: str) -> str:
    """Create a new Salesforce record.

    Args:
        object_name: API name of the object (e.g. "Account")
        data: JSON string with field values (e.g. '{"Name": "Acme Corp"}')
    """
    try:
        sf = get_sf()
        record_data = json.loads(data)
        result = getattr(sf, object_name).create(record_data)
        return json.dumps(result, ensure_ascii=False, default=str)
    except (SalesforceError, json.JSONDecodeError) as e:
        return json.dumps({"error": str(e)})


@mcp.tool()
def salesforce_update(object_name: str, record_id: str, data: str) -> str:
    """Update an existing Salesforce record.

    Args:
        object_name: API name of the object (e.g. "Account")
        record_id: The 18-char Salesforce record ID
        data: JSON string with fields to update (e.g. '{"Name": "New Name"}')
    """
    try:
        sf = get_sf()
        record_data = json.loads(data)
        getattr(sf, object_name).update(record_id, record_data)
        return json.dumps({"success": True, "id": record_id})
    except (SalesforceError, json.JSONDecodeError) as e:
        return json.dumps({"error": str(e)})


@mcp.tool()
def salesforce_aggregate(soql: str) -> str:
    """Execute a SOQL aggregate query (COUNT, SUM, AVG, etc.).

    Args:
        soql: A valid SOQL aggregate query (e.g. "SELECT COUNT(Id) total FROM Account")
    """
    try:
        sf = get_sf()
        result = sf.query(soql)
        records = result.get("records", [])
        clean = []
        for r in records:
            clean.append({k: v for k, v in r.items() if k != "attributes"})
        return json.dumps(
            {"totalSize": result["totalSize"], "records": clean},
            ensure_ascii=False,
            default=str,
        )
    except SalesforceError as e:
        return json.dumps({"error": str(e)})


if __name__ == "__main__":
    mcp.run(transport="stdio")
