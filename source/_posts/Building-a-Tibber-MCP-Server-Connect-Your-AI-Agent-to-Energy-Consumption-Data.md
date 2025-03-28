---
title: 'Building a Tibber MCP Server: Connect Your AI Agent to Energy Consumption Data'
date: 2025-03-28 14:25:48
tags:
- AI
- AI Agent
- Generative AI
- GenAI
- MCP
- Model Context Protocol
- Tibber
---

### Introduction
In the era of AI, integrating agents with external systems is crucial for expanding their capabilities. Whether accessing local file systems, remote databases, or APIs, external data significantly enhances an AI agent's ability to assist in daily tasks.

However, connecting AI agents to external systems can be challenging. Different systems use various interfaces and protocols, making integration complex. Fortunately, Anthropic’s [Model Context Protocol (MCP)](https://modelcontextprotocol.io/introduction) simplifies this process, providing a standardized way for AI agents to interact with external resources and tools.

MCP functions similarly to HTTP on the internet—it defines a standardized approach that enables AI agents to discover and interact with external systems seamlessly.

### Building an MCP Server for Tibber
In this blog post, I’ll demonstrate how I built a MCP server for integrating [Tibber](https://tibber.com/) with an AI agent.

Tibber is a Norwegian power supplier that we’ve been using for years. They provide [APIs](https://developer.tibber.com/docs) that allow users to retrieve electricity prices and energy consumption data. By integrating Tibber’s API with an AI agent, I can ask natural language questions like:
- “What is the current electricity price?”
- “What was my house’s energy cost yesterday?”
- "List the 3 cheapest hours of tomorrow."

This integration enables a more intuitive and efficient way to access real-time energy data without manually querying APIs.

### Demo video
{% youtube FiqKPa9i6V4 %}

### Architecture
{% asset_img "tibber-mcp-architecture.png" "tibber mcp config" %}

### Installation and Setup Tibber MCP server
You can find the source code for Tibber MCP on my GitHub repository: https://github.com/linkcd/tibber-mcp.

Follow the installation steps in the repository to deploy Tibber MCP on your local machine. Once installed, configure the MCP server settings as follows:
```json
{
   "mcpServers":{
      "tibber":{
         "command":"uv",
         "args":[
            "--directory",
            "[PATH-TO-ROOT-OF-THE-CLONED-TIBBER-MCP-FOLDER]",
            "run",
            "server.py"
         ],
         "env":{
            "TIBBER_API_TOKEN":"[YOUR-TIBBER-TOKEN]"
         }
      }
   }
}
```
Once it is successfully connected to the MCP server, you can see the available tools (and resources) this MCP server provides. This is the screenshot of [Roo Code](https://marketplace.visualstudio.com/items?itemName=RooVeterinaryInc.roo-cline) MCP servers in VS Code.
{% asset_img "tibber-mcp-config.png" "tibber mcp config" %}

### Sample questions and answers

**Question #1: “What is the current electricity price?”**
**Answer:**
{% codeblock %}
The current electricity price (as of 16:00) is 0.6955 NOK/kWh with a NORMAL price level. 
This price consists of:
- Energy cost: 0.5328 NOK/kWh
- Tax: 0.1627 NOK/kWh

This is a moderate price compared to today's range:
- Lowest price today: 0.4924 NOK/kWh (at 23:00)
- Highest price today: 0.732 NOK/kWh (at 18:00)

Tomorrow's prices will be generally lower, with some very cheap periods:
- Lowest price: 0.1673 NOK/kWh (at 01:00)
- Highest price: 0.7472 NOK/kWh (at 18:00)
{% endcodeblock %}

**Question #2: “What was my house’s energy cost yesterday?”**
**Answer:**
{% codeblock %}
Your total electricity cost for yesterday (March 27th) was:
- Total consumption: 63.811 kWh
- Total cost: 45.31 NOK

The most expensive hours were:
- 08:00-09:00: 0.7795 NOK/kWh
- 07:00-08:00: 0.7736 NOK/kWh
- 06:00-07:00: 0.7424 NOK/kWh

The cheapest hours were:
- 13:00-14:00: 0.5969 NOK/kWh
- 12:00-13:00: 0.6264 NOK/kWh
- 14:00-15:00: 0.6617 NOK/kWh
{% endcodeblock %}

### Thoughts and improvement areas
When reading the source code, you may have noticed how easy it is to build an MCP server using tools like [FastMCP](https://github.com/jlowin/fastmcp). With fewer than 100 lines of code, it efficiently wraps the [pyTibber](https://github.com/Danielhiversen/pyTibber) library into an MCP server implementation, enabling the AI agent to interact with it automatically.

Currently, this MCP server implementation does not support parameters such as date or time when making API calls. For example, when you ask, "What was my energy consumption yesterday?", it retrieves all consumption data for the past 30 days and relies on the LLM (Large Language Model) to extract the relevant information.

To improve efficiency and reduce token usage, we could implement parameterized API calls. This would allow the AI agent to pass a specific date (e.g., yesterday) and retrieve only the necessary data, making the interaction more precise and resource-efficient.

### Feedback
If you have any questions or suggestions, feel free to reach out or create a GitHub issue for the repository: https://github.com/linkcd/tibber-mcp.