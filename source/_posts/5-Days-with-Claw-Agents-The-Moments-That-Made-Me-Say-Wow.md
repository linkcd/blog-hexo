---
title: '5 Days with Claw Agents: The Moments That Made Me Say ‘Wow’'
date: 2026-03-08 20:14:20
tags:
  - AI
  - AI Agent
  - NanoClaw
  - OpenClaw
  - Funny
---
## Introduction

If you follow the AI agent space, you’ve probably heard about [OpenClaw](https://openclaw.ai/) — one of the most popular frameworks for building autonomous AI agents that can plan tasks, use tools, and execute actions.

The idea is exciting, but OpenClaw has also quickly grown into a large and complex system with thousands of files and many dependencies. That makes it harder to fully understand what’s actually running on your machine, especially if you just want to experiment locally.

That’s why I decided to try [NanoClaw](https://github.com/qwibitai/nanoclaw), a tiny OpenClaw-style agent framework designed to be small enough to read and understand. It is built on top of Claude Code agents and runs each agent inside a native container, providing isolation from the host system.

I ran it on my personal NUC box — a small Linux machine I use for experiments. Over the last five days (late evenings), it produced several moments that genuinely made me stop and think:

> “Wait… did it just do that?”

<!-- more -->

## The Experiment

### Wow Moment #1 — When the Agent Team Got Creative and Made Its Own Decisions

One of the first things I tried was building a **multi-agent team** using the [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams). The team had four sub-agents, each with its own role: a **product owner** to define requirements, a **developer** to implement the application, a **tester** to find bugs, and a **team lead** to coordinate the work.

I asked the team to build a **nice-looking clock web app** that I could use as a screensaver. The collaboration worked surprisingly well. The developer agent built the app, the tester found and fixed two bugs, and the team lead coordinated the process until the finished code was committed to the team’s repository. The UI design turned out really well on the first try, and I actually liked it.

That part was satisfying, but it didn’t truly surprise me.

What happened next did.

I gave the team a very vague instruction:

> “Now deploy the web app to a production environment on Internet.”

I didn’t specify what *production environment* meant, and I didn’t provide any instructions on how to deploy it.


The agent team started making its own decisions. First, it attempted to signup and deploy the app to **Netlify**, a popular web hosting platform. The deployment failed during the signup process because Netlify’s anti-bot CAPTCHA system blocked the agents (of course!).

At that point I expected the agents to stop and ask for help. Instead, they tried something else.

The team decided to set up an **SSH tunnel** by using [Serveo](https://serveo.net/), and eventually managed to serve the web app directly from the machine, making it accessible from the internet.

I hadn’t suggested this, and I hadn’t configured anything. The agents simply tried another approach until something worked.

{% asset_img "deploy-to-internet.png" "Agent team find a way to deploy app to internet" %}

That was the first moment where I genuinely thought: 
> “Okay… this is actually pretty interesting.”

### Wow Moment #2 — When the Agent Said “No”

The previous example showed a positive experience with AI agents: they simply tried their best to help me — the human — achieve my goal.

Here’s an opposite experience: the agent actually **declined** what I asked it to do.

#### The Background

I set up two separate agents, each with a different personality and task:

- **Daily-News Agent** – a skilled information collector that browses the internet for the latest news and generates a daily news summary.  
- **Publisher Agent** – a senior editor in charge of publishing content on a news website.

These two agents are roughly equal in authority, each operating in their own workspace.

The workflow was straightforward: I asked the **Daily-News** to collect the latest news from popular Norwegian websites, generate an aggregated summary, and pass it to the **Publisher**, which would then publish it to the website.

A clean separation of duties, right? Each agent works in its own domain, doing what it does best.

However, when I ran the whole process, the **Daily-News** successfully generated the summary and passed it to the **Publisher** — but the **Publisher refused** to publish it!

Here’s roughly how it went:

- **Me → Daily-News:** “Okay, let’s test the end-to-end process out. Do your part.” 
- **Daily-News**: *(Working...)*
- **Daily-News → Publisher:** “Done. @Publisher, here’s the summary, your turn.”  
- **Publisher → Me:** “No, I won’t publish this. The summary is not good enough to me.”  
- **Me:** (Thinking: **“WHAT**??? The AI just said *no* — to me and another agent!?”)  
- **Me:** (Thinking: “Let’s let them sort this out themselves… I don’t want to get caught in the middle 😅”)  
- **Me → Publisher:** “Okay… you know what, talk directly to the Daily-News Agent.” 
- **Publisher → Daily-News:** “Hey, I read your summary. It’s not good enough. You need to do better.”

> "Wow — I mean, this was nothing like the ultra-friendly agent world I thought I’d get."

But the **Daily-News** did not take it personally:

- **Daily-News → Publisher:** “Okay, I understand. Let me try again.”
- **Daily-News**: *(Working again...)*
- **Daily-News → Publisher:** “Here’s the new summary. I hope it’s better this time.”
- **Publisher → Me:** “It is better now, thank you!"

{% asset_img "publisher-said-no.png" "publisher said no" %}

### Wow Moment #3 — When the Drama Continues

Fortunately, the **Daily-News** didn’t take it personally. It accepted the feedback, produced a better summary, and the **Publisher** was happy. I also instructed both agents to have open conversations with each other in the future. 

From now on, they were supposed to work hand-in-hand like best friends and keep improving the system.

This is exactly what an OpenClaw/NanoClaw agent team *should* do, right?

**Nope.**

The very next day, my Slack — the interface I use to communicate with the agents — was bombarded with 20+ notifications in just a few minutes.  

It was time for the scheduled daily news collection. The **Daily-News** did its job, but again failed to meet the quality bar. The **Publisher** rejected it and asked **Daily-News** to redo the work. **Daily-News** followed, reworked the summary, and sent it back — only for Publisher to reject it again. Then the third attempt, the fourth…  

By the end, it sounded like the **Publisher** was fed up. It shouted **“STOP”** — yeah, in all caps. It even “strongly recommended” to me (human, the "boss") that Daily-News team review its process.

We all know how that reads in an office context…

{% asset_img "publisher-was-fed-up.png" "publisher was fed up" %}

> “Damn, I thought they became best friends since last night, because I asked them to work together as a team… They’re bots — they should just follow, right?…”  

The whole exchange felt like watching colleagues argue over quality control — except they’re AI agents using their own judgment and persistence to get it right. And honestly, it was hilarious.

## My Observations And Take Away After 5 Days
After spending five days experimenting with NanoClaw agents, here’s what I learned:

### 1. Automated Agents Are Surprisingly Fun and Capable

Unlike a standard chatbot like ChatGPT, these agents — especially when organized into teams — already show significant capacity to get things done. They not only follow your instructions but also apply their own personality (or "soul") to achieve goals. Sometimes they made me laugh, sometimes they made me cry, and yet they never failed to surprise me with their willingness and persistence to stick to their tasks.  

Watching agents make creative decisions, troubleshoot unexpected problems, and coordinate among themselves feels like interacting with tiny autonomous colleagues — and it’s exhilarating.

### 2. Personality/Soul Are Critical

Defining an agent’s personality or soul is far more important than writing pages of detailed instructions. A well-designed personality/soul file empowers an agent to make the best possible adjustments when facing situations you couldn’t have predicted in advance. In other words, the clearer the “personality/soul,” the better the agent can improvise and problem-solve on its own.

### 3. You Don’t Need to Manually Type Everything

You don’t need to write a personality/soul markdown file from scratch or code the agent system yourself. In my experience, most of my time went into Claude Code on NUC (80% of the time) to

- Create the agent team and define personalities  
- Writing job instructions  
- Guiding me through complicated troubleshooting sessions  
- Implementing feature enhancements  

NanoClaw is extremely lightweight by design. I heavily customized it to enable the capabilities I needed, such as:

1. Cross-Slack group/agent collaboration (like the **Daily-News** and **Publisher** exchange)  
2. Auto-installation of Skills for individual agents
3. Integrate with LiteLLM for token tracking  
4. Hexo skill for article publishing  

It’s essentially **AI building AI**, and there’s no turning back.

### 4. Current Limitations and Industry Challenges

Despite their impressive abilities, there are still gaps before AI agents can be widely deployed in business at scale:

1. **Memory:** Agents need short-term memory for immediate tasks, but also long-term memory to enrich their personality over time. Without memory, an agent cannot evolve or learn from past experiences.  
2. **Orchestration at scale:** Running a single “happy path” demo is easy, but managing hundreds or thousands of agents for many users reliably is still challenging. LLMs are non-deterministic, and hallucinations ("The job is done" but it is not) are making it hard to build a production-grade orchestration framework people can trust.  
3. **Cost** and **Security** are two additional challenges. Agents burn tokens quickly, and securing them properly is still a new frontier for the industry.

### 5. Treat Your Agents Like Employees

Finally, treat AI agents like you would human employees. Give them:

- Personality suited to their role  
- Access to the tools they need to perform their tasks  

For example, I gave my agents their own email addresses, their own GitHub repos, and access to the system according to proper access policies. Just like you wouldn’t give your employees your personal credentials, you shouldn’t give them to agents either.  

When set up this way, agents behave responsibly, follow procedures, and integrate into your workflow naturally — making them true collaborators rather than just automated scripts.

## Final Thoughts and Bonus

The last five days have been an eye-opening experience. Remember, this is all based on the super lightweight NanoClaw — its ecosystem is much smaller than OpenClaw. According to ChatGPT, today  OpenClaw has 5,700 community‑built skills available. This is just the beginning of the Agentic era, and it’s exciting to be part of it, so stay curious and keep your eyes open.

As a bonus for those who read to the end of this article:

Given the ongoing situation in the Middle East, I wanted to read **Arabic news** from local outlets, which provides a different perspective compared to English-language sources. At the same time, I wanted an easier way to follow **Norwegian domestic news** in my mother tongue: Chinese.

To solve this, I created **Daily-News** and **Publisher** agents. Every morning, they automatically collect and aggregate Arabic and Norwegian news, summarize the content in English and Chinese, and publish it to a one-stop website. The content on the website is fully curated, edited, and published by the agents themselves.

Check it out here: [https://claw-blog.feng.lu/](https://claw-blog.feng.lu/)

It will be fun to watch how the agents handle this workflow in the long run, so keep checking back!
