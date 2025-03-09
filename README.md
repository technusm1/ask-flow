# AskFlow
A clone of Stack Overflow that allows users to search for questions, view answers, and see AI-reranked answers based on relevance.
Powered by StackExchange API and OpenAI API compatible LLMs.

## Features
- Search for questions on Stack Overflow
- View answers to questions
- AI-powered reranking of answers based on relevance
- Recent questions history
- Responsive UI that resembles Stack Overflow

## Demo
Here's a demo video showing the website in action:  
[![AskFlow demo video](https://img.youtube.com/vi/j1AR5ikUJRA/0.jpg)](https://www.youtube.com/watch?v=j1AR5ikUJRA)

## Tech Stack and its justifications
- **Backend**: Elixir + Phoenix Framework. Elixir is the only language I've done most of my front-end stuff on. Plus, Phoenix Framework avoids the most painful of tasks - synchronizing client-side and server-side states.
- **Frontend**: Phoenix LiveView + TailwindCSS + Heroicons. All this stuff ships built-in with the Phoenix Framework. So, its "good enough" for rendering.
- **Database**: PostgreSQL. Feel free to enjoy this [Just Use Postgres](https://www.youtube.com/watch?v=3JW732GrMdg) video. But all things considered, its the database I've used the most, and it comfortably works with this use-case.
- **Caching**: Cachex. No need for redis, yet.
- **AI Integration**: OpenAI API. Or anything that behaves like it, like Ollama, LM Studio etc. This supports all of my use-cases with LLMs so far, and most of the libraries like ExOpenAI etc. are built around this.
- **Containerization**: Docker + Docker Compose (for local testing). For production deployment, I'd prefer using Kubernetes.

## Documents of Interest
- [List of tasks](/tasks.md): Tracks the tasks completed and yet to be completed. A checklist for keeping track of things and the overall development of the project.
- [Architecture Diagram](/docs/Project%20Architecture.svg): A high-level overview of the architecture of the application.

## Project Assumptions
This project is created with the following assumptions:
- Any search terms entered into the StackExchange search API will be programming-related.
- **StackExchange basic search API is good enough**. For example: If I enter the query: "differences between case and cond keywords in Elixir", I would expect some related results back.
- **No guardrails around LLMs**: Many of the LLM APIs implement this themselves. There is no query filtering of any sorts that prevents any misuse of underlying LLM API. For example: Someone could very well enter the question: "tell me the capital of India", and even though this question is not programming-related, they could use "Ask AI" feature to answer it.


## Prerequisites
- Docker and Docker Compose
- OpenAI API key or a local LLM running using an OpenAI compatible API

## Running the Application

### Using Docker Compose (Recommended)

1. Clone the repository:
   ```bash
   git clone https://github.com/technusm1/ask-flow.git
   cd ask-flow
   ```

2. Create a `.env` file in the root directory with your OpenAI API key and other details. You can use the `.env.example` file as a template.

3. Build and start the containers:
   ```bash
   # For development
   docker-compose -f docker-compose.dev.yml up --build

   # For production
   docker-compose -f docker-compose.prod.yml up --build
   ```

4. Access the application at http://localhost:4000

### Running Locally

1. Clone the repository:
   ```bash
   git clone https://github.com/technusm1/ask-flow.git
   cd ask-flow
   ```

2. Install dependencies:
   ```bash
   mix deps.get
   ```

3. Set up the database:
   ```bash
   mix ecto.setup
   ```

4. Set environment variables according to `.env.example` file:
   ```bash
   export OPENAI_API_KEY=your_openai_api_key
   export OPENAI_ORGANIZATION_KEY=your_openai_org_key
   ... and other variables
   ```

5. Make sure you have postgres running on your machine. If you don't have it installed, you can use the following docker command:
   ```bash
   docker run --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres
   ```

6. Start the Phoenix server:
   ```bash
   mix phx.server
   ```

7. Access the application at http://localhost:4000

## Architecture
- **Phoenix LiveView**: Provides real-time updates without writing (too much) JavaScript
- **Stack Overflow API**: Used to fetch questions and answers
- **OpenAI API**: Used to rerank answers based on relevance
- **Cachex**: In-memory cache for storing recent questions and recent searches
- **PostgreSQL**: Database for persisting user questions and searches

## License
MIT

## Credits
- [Robot icons created by Hilmy Abiyyu A. - Flaticon](https://www.flaticon.com/free-icons/robot)
