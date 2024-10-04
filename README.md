# AI Music Production

AI Music Production is a Flutter and FastAPI-based application that leverages AI to generate song lyrics based on user input. The application features a sleek, animated user interface and uses Groq's language model for lyric generation.

## Features

- AI-powered lyrics generation
- Multi-language support
- Genre versatility
- Real-time streaming of generated lyrics
- Animated, responsive UI

## Prerequisites

- Flutter (latest stable version)
- Python 3.8+
- Dart
- An API key from Groq

## Setup

### Backend

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/ai-music-production.git
   cd ai-music-production
   ```

2. Set up a virtual environment:
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
   ```

3. Install the required Python packages:
   ```
   pip install -r requirements.txt
   ```

4. Create a `.env` file in the project root and add your Groq API key:
   ```
   GROQ_API_KEY=your_groq_api_key_here
   ```

5. Run the FastAPI server:
   ```
   python main.py
   ```

The server will start running on `http://localhost:8000`.

### Frontend

1. Ensure you have Flutter installed and set up.

2. Navigate to the project directory and run:
   ```
   flutter pub get
   ```

3. Run the Flutter application:
   ```
   flutter run
   ```

## Usage

1. Launch the Flutter application.
2. Enter the desired language and genre in the respective tabs.
3. In the Lyrics tab, describe your song idea.
4. Click "Create/Update Lyrics" to generate lyrics.
5. Watch as the lyrics are streamed in real-time!

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).
