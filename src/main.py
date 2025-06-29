# server.py
from fastmcp import FastMCP
from src.tools.add.add import add as _add


# Create an MCP server
mcp = FastMCP("FastMCP Python Preset", debug=True)


# Add an addition tool
@mcp.tool()
def add(a: int, b: int) -> int:
    """Add two numbers"""
    return _add(a, b)


if __name__ == "__main__":
    mcp.run()
