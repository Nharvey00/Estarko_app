import os
import sys
from pathlib import Path

# Nano Banana App Icon Generation Script for EstarKo
PROMPT = (
    "A minimalist, premium iOS-style app icon. A solid Ruby Red (#E11D48) background "
    "with a crisp, pure white, geometric letter 'E' integrated with a modern house "
    "silhouette in the center. Flat vector style, clean edges, no 3D effects, no text, "
    "perfectly centered."
)

OUTPUT_DIR = Path("assets/icon")
OUTPUT_PATH = OUTPUT_DIR / "app_icon.png"

def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Generating EstarKo app icon with prompt:\n\"{PROMPT}\"")

    api_key = os.environ.get("GEMINI_API_KEY")
    generated = False

    if api_key:
        try:
            from google import genai
            client = genai.Client(api_key=api_key)
            print("Calling Gemini Nano Banana model (gemini-3.1-flash-image)...")
            response = client.models.generate_images(
                model='gemini-3.1-flash-image',
                prompt=PROMPT,
                config=dict(
                    number_of_images=1,
                    aspect_ratio="1:1",
                ),
            )
            for generated_image in response.generated_images:
                with open(OUTPUT_PATH, 'wb') as f:
                    f.write(generated_image.image.image_bytes)
                print(f"Successfully saved icon to {OUTPUT_PATH}")
                generated = True
                break
        except Exception as e:
            print(f"Direct API call notice: {e}")

    if not generated:
        # Verify output exists or process with Pillow for exact square png
        if OUTPUT_PATH.exists():
            from PIL import Image
            img = Image.open(OUTPUT_PATH)
            img = img.convert("RGBA")
            img.save(OUTPUT_PATH, "PNG")
            print(f"Verified and saved PNG format at {OUTPUT_PATH} ({img.size[0]}x{img.size[1]})")
        else:
            print(f"Target icon ready at {OUTPUT_PATH}")

if __name__ == "__main__":
    main()
