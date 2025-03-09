# AskFlow
A clone of Stack Overflow that allows users to search for questions, view answers, and see AI-reranked answers based on relevance.
Powered by StackExchange API and OpenAI API compatible LLMs.

## Features
- Search for questions on Stack Overflow
- View answers to questions
- AI-powered reranking of answers based on relevance
- Recent questions history
- Responsive UI that resembles Stack Overflow

## Tech Stack
- **Backend**: Elixir + Phoenix Framework
- **Frontend**: Phoenix LiveView + TailwindCSS
- **Database**: PostgreSQL
- **Caching**: Cachex
- **AI Integration**: OpenAI API
- **Containerization**: Docker + Docker Compose

## Prerequisites
- Docker and Docker Compose
- OpenAI API key or a local LLM running using an OpenAI compatible API

## Running the Application
⚠️ Application packaging isn't complete yet. So these instructions are not correct and subject to change.

### Using Docker Compose (Recommended)

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/ask_flow.git
   cd ask_flow
   ```

2. Create a `.env` file in the root directory with your OpenAI API key:
   ```
   OPENAI_API_KEY=your_openai_api_key
   OPENAI_ORGANIZATION_KEY=your_openai_org_key  # Optional
   SECRET_KEY_BASE=your_secret_key_base  # Optional for development
   ```

3. Build and start the containers:
   ```bash
   docker-compose up --build
   ```

4. Access the application at http://localhost:4000

### Running Locally

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/ask_flow.git
   cd ask_flow
   ```

2. Install dependencies:
   ```bash
   mix deps.get
   ```

3. Set up the database:
   ```bash
   mix ecto.setup
   ```

4. Set environment variables:
   ```bash
   export OPENAI_API_KEY=your_openai_api_key
   export OPENAI_ORGANIZATION_KEY=your_openai_org_key  # Optional
   ```

5. Start the Phoenix server:
   ```bash
   mix phx.server
   ```

6. Access the application at http://localhost:4000

## Architecture
- **Phoenix LiveView**: Provides real-time updates without writing JavaScript
- **Stack Overflow API**: Used to fetch questions and answers
- **OpenAI API**: Used to rerank answers based on relevance
- **Cachex**: In-memory cache for storing recent questions
- **PostgreSQL**: Database for persisting user questions

## License
MIT



## Demo
Here's a demo video showing the website in action:  
[![AskFlow demo video](https://img.youtube.com/vi/j1AR5ikUJRA/0.jpg)](https://www.youtube.com/watch?v=j1AR5ikUJRA)
