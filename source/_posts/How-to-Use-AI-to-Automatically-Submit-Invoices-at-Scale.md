---
title: How to Use AI to Automatically Submit Invoices at Scale
date: 2025-12-16 11:58:36
tags:
- AI
- AI Agent
- Agentic
- Generative AI
- GenAI
- Amazon Bedrock
- MCP
- Model Context Protocol
- Automation
- Invoice Processing
- Ruter
---
## Introduction

Picture this: It's December, and you're staring at a pile of 20+ invoice PDFs scattered across your desktop. Sound familiar?

We've all been there. The holiday season is approaching, you're dreaming of that well-deserved break, but first – the dreaded year-end expense reports. You know the drill:

- Open each invoice PDF file
- Copy and paste dates, amounts, and ticket numbers (hoping you don't mix them up)
- Navigate to that expense portal that takes forever to load
- Fill out the same form fields over and over again
- Upload attachments one by one
- Click submit and pray nothing went wrong
- Rinse and repeat... 20 more times

If you’ve ever done this mind-numbing dance, you’re not alone. It’s a boring, repetitive task that eats up hours and can easily introduce errors.

But what if there were a better way?

I built an AI-powered solution that automates the entire workflow—no APIs to integrate, no complex system changes. It works with any web-based expense system by extracting data from your PDFs and filling out forms directly in your browser, just like you would… minus the headache.

Here's how it works:

### Demo

{% asset_img "demo.gif" "AI Invoice Submission Demo" %}

<!-- more -->

### Architecture
{% asset_img "architecture.png" "Architecture" %}

The solution automates the entire invoice processing workflow through two main phases:

**Phase 1 Workflow:**
1. Python app uploads PDFs to S3
2. Bedrock Data Automation processes each PDF using a custom blueprint
3. Extracted data is compiled into a JSON file with structured information

**Phase 2 Workflow:**
1. MCP Client (Amazon Q + Playwright MCP) reads the JSON file
2. Automatically navigates to the expense portal using existing browser credentials
3. Fills forms with extracted data and uploads PDF attachments
4. Updates JSON file to track submission status

### Key Components

**Amazon Bedrock Data Automation**
The heart of the data extraction process. Here, I’m working with bus ticket invoices issued by [Ruter](https://ruter.no/), Oslo’s public transportation provider. I created a custom blueprint that defines three key fields. 
- `purchase_date`: Date field for transaction date
- `invoice_amount`: Number field for the amount
- `ticket_number`: Text field for receipt/ticket number

{% asset_img "blueprint.png" "Bedrock Data Automation Blueprint" %}

**Playwright MCP Integration**
Using the Model Context Protocol, Amazon Q can control a web browser to:
- Navigate web pages
- Fill form fields
- Upload files
- Click buttons and wait for responses
- Update local files with submission status

The beauty of using MCP is that it leverages your existing browser session, so corporate SSO and authentication are already handled.

### Getting Started

The complete source code is available on GitHub: https://github.com/linkcd/ai_invoice_submission

### Implementation Details

**Setting Up the Blueprint**
First, I configured a Bedrock Data Automation blueprint to extract the specific fields I needed from bus ticket PDFs. The blueprint training process was straightforward - I uploaded a few sample PDFs and defined the extraction fields.

**Batch Processing Logic**
The Python application processes invoices in batches:

```python
def process_batch_folder(batch_name, config):
    input_folder = f"input/{batch_name}"
    files = [f for f in os.listdir(input_folder) 
             if f.lower().endswith('.pdf')]
    
    # Create timestamped result file
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    result_filename = f"result_{timestamp}.json"
    
    for filename in files:
        # Upload to S3 and process with Bedrock
        # Extract data and append to results
```

**MCP Automation Prompt (Simplified Version)**
The key to successful automation is providing clear, specific instructions to the AI agent:

```
You are helping to submit invoices for reimbursement. Use Playwright MCP tool to:
1. Navigate to the expense portal
2. For each unsubmitted invoice in the JSON file:
   - Create a new claim with type "Public Transportation"
   - Fill in the extracted date, amount, and ticket number
   - Upload the corresponding PDF file
   - Submit and wait for confirmation
   - Update the JSON file to mark as submitted
3. Continue until all invoices are processed
```

### Results and Benefits

**Time Savings**
What used to take 30-45 minutes of manual work now completes in under 5 minutes with minimal supervision. The AI handles:
- 20+ invoices in a single batch 
- Accurate data extraction from various PDF formats
- Consistent form filling without typos
- Automatic status tracking

**Error Reduction**
Manual data entry errors are eliminated since the AI extracts data directly from the source PDFs. The system also provides clear feedback when processing fails, making troubleshooting straightforward.

**Scalability**
The batch processing approach means I can handle months of accumulated invoices in one go. The system processes each PDF independently, so one failed extraction doesn't block the entire batch.

### Technical Challenges and Solutions

**Challenge 1: PDF Format Variations**
Bus tickets come in different formats and layouts. 

*Solution*: Bedrock Data Automation's AI models are robust enough to handle format variations. The blueprint training with diverse samples improved extraction accuracy.

**Challenge 2: Corporate Authentication**
Expense portals often require SSO authentication.

*Solution*: Using Playwright MCP in extension mode leverages the existing browser session, bypassing the need to handle authentication programmatically.

**Challenge 3: Form Submission Reliability**
Web forms can be unpredictable with dynamic loading and validation.

*Solution*: The MCP approach allows the AI to wait for page loads, handle dynamic content, and retry operations when needed.

### Conclusion

Automating invoice submission transformed a tedious monthly chore into a quick, reliable process. The combination of Amazon Bedrock Data Automation for intelligent data extraction and MCP for browser automation creates a powerful workflow that handles the entire process end-to-end.

The key insight is that modern AI tools are mature enough to handle real-world automation tasks when properly orchestrated. By breaking down the problem into discrete phases and leveraging the right tools for each phase, we can build robust automation that actually works in practice.

Whether you're dealing with expense reports, invoice processing, or any repetitive data entry task, this approach demonstrates how AI can eliminate manual work while maintaining accuracy and reliability.

The future of work isn't about replacing humans with AI, but about using AI to eliminate the boring, repetitive tasks so we can focus on more valuable activities. This invoice automation project is a perfect example of that philosophy in action.
