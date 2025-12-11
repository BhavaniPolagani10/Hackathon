#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Starting Frontend & Backend Services ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if backend dependencies are installed
if [ ! -d "backend/venv" ]; then
    echo -e "${YELLOW}Setting up backend virtual environment...${NC}"
    cd backend
    python -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    cd ..
    echo -e "${GREEN}Backend setup complete!${NC}"
    echo ""
fi

# Check if frontend dependencies are installed
if [ ! -d "frontend/node_modules" ]; then
    echo -e "${YELLOW}Installing frontend dependencies...${NC}"
    cd frontend
    npm install
    cd ..
    echo -e "${GREEN}Frontend setup complete!${NC}"
    echo ""
fi

# Check if .env files exist
if [ ! -f "backend/.env" ]; then
    echo -e "${YELLOW}Warning: backend/.env not found. Copying from .env.example${NC}"
    cp backend/.env.example backend/.env
    echo -e "${YELLOW}Please edit backend/.env with your configuration${NC}"
    echo ""
fi

if [ ! -f "frontend/.env" ]; then
    echo -e "${YELLOW}Creating frontend/.env (using Vite proxy)${NC}"
    cp frontend/.env.example frontend/.env
    echo ""
fi

echo -e "${GREEN}Starting services...${NC}"
echo ""

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}Stopping services...${NC}"
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start backend
echo -e "${GREEN}Starting backend on http://localhost:8000${NC}"
cd backend
source venv/bin/activate
python -m app.main > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

# Wait a bit for backend to start
sleep 3

# Check if backend started
if curl -s http://localhost:8000/health > /dev/null; then
    echo -e "${GREEN}✓ Backend is running${NC}"
else
    echo -e "${YELLOW}⚠ Backend may not be ready yet (check backend.log for errors)${NC}"
fi

echo ""

# Start frontend
echo -e "${GREEN}Starting frontend on http://localhost:3000${NC}"
cd frontend
npm run dev > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

# Wait a bit for frontend to start
sleep 3

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Services Started!                    ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Frontend:  ${GREEN}http://localhost:3000${NC}"
echo -e "Backend:   ${GREEN}http://localhost:8000${NC}"
echo -e "API Docs:  ${GREEN}http://localhost:8000/docs${NC}"
echo ""
echo -e "Logs:"
echo -e "  Backend:  ${YELLOW}tail -f backend.log${NC}"
echo -e "  Frontend: ${YELLOW}tail -f frontend.log${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all services${NC}"
echo ""

# Wait for user interrupt
wait
