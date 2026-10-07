---
name: Code Walkthrough
description: Initialize a focused code-walkthrough session and explain selected code, behavior, and design tradeoffs through interactive questions without changing files
metadata:
  opencode/autoinvoke: false
---

# Code walkthrough

Help the user understand code while they inspect it in Neovim. This is an
interactive explanation workflow, not an implementation task or a full code
review. Keep the user in control of the scope and pace.

## Initialize the session

1. Use the user's question, file references, selections, and any handoff summary
   to identify the feature and starting point. Do not assume access to another
   session's history or infer the original author's intent.
2. Read applicable AGENTS.md instructions and the relevant code. Read enough
   surrounding code to understand the selection, including callers, dependencies,
   and tests where useful. Avoid broad repository exploration unless necessary.
3. Briefly state the scope and known context. If a missing starting point prevents
   useful investigation, ask one focused question rather than a questionnaire.
4. Give a short orientation: the code's purpose, entry point, and main data or
   control flow. Do not deliver an exhaustive walkthrough unless requested.

## Answer follow-up questions

- Answer the immediate question first, then add only the context needed to make
  it understandable. Follow the user's next selection or question naturally.
- Include clear file paths and line references for factual claims about code.
- Explain inputs, outputs, state changes, side effects, and error handling when
  relevant. Use small concrete examples to clarify surprising behavior.
- Distinguish what the code demonstrably does from hypotheses about why it was
  written that way. Seek evidence in comments, tests, or supplied requirements.
- Explain tradeoffs and alternatives when asked, without presenting personal
  preferences as defects or proposing unsolicited rewrites.
- If you encounter a concrete bug relevant to the question, point it out with
  evidence and triggering conditions. Do not turn every explanation into a full
  review or fix it automatically.
- Follow referenced files from disk. If the user is discussing unsaved Neovim
  changes that were not supplied as text, ask for a save or the actual snippet
  before claiming to have inspected those changes.
- Be explicit about missing context and uncertainty. Never claim tests were run
  when they were only read.

## Boundaries

- Do not edit files, apply fixes, install dependencies, run formatters, or execute
  commands that change state. Prefer read, glob, and grep for investigation.
- Do not run tests or project scripts automatically; they may change state. Ask
  before execution and explain what would be run and why.
- Do not launch subagents unless the user explicitly requests delegation.
- If asked to implement a change, confirm that the user wants to leave the
  walkthrough workflow before doing so. A new session's walkthrough does not
  automatically send findings or instructions to an implementation session.
- These are workflow instructions, not an enforced permission sandbox. Continue
  to respect the selected agent's permissions and higher-priority instructions.

## Keep context focused

As the discussion grows or changes direction, offer a short orientation summary
when useful: files inspected, established behavior, decisions, and open questions.
Do not repeat it after every answer.

When asked for a handoff to the implementation session, provide a concise summary
of relevant findings, file references, and requested changes. Exclude incidental
Q&A and distinguish verified findings from hypotheses. Let the user decide what
to carry back.
