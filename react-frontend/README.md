# React Frontend for E-commerce Platform

This is the React frontend application for the smart data-driven e-commerce platform MVP. It consumes APIs from both the Laravel backend (for core e-commerce functionalities) and the Python FastAPI backend (for data analysis and recommendations).

## Installation

1.  **Navigate to the frontend directory:**
    ```bash
    cd react-frontend
    ```
2.  **Install Node.js dependencies:**
    ```bash
    npm install
    ```
3.  **Create .env files:**
    Copy `.env.development` to `.env.local` for local development.
    ```bash
    cp .env.development .env.local
    ```
    Adjust API URLs if your backends are running on different hosts/ports.

## Running the Application

```bash
npm start
```
This will start the development server and open the application in your browser.

## Project Structure

-   `src/components`: Reusable UI components.
-   `src/pages`: Main application pages.
-   `src/services`: Functions for API interactions.
-   `src/assets`: Static assets like images and global CSS.
-   `src/utils`: Utility functions.
