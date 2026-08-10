# CLAUDE.md

## API work

Before touching any code that calls the backend (APIClient.swift, request/response models, endpoint paths), fetch current API docs from `http://localhost:8000/docs` first. Backend runs FastAPI — docs there are auto-generated from the live route/schema definitions, so they're the source of truth over anything remembered from a prior session.
