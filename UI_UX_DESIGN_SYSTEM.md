# UI_UX_DESIGN_SYSTEM.md
## EstarKo: Secure, Effortless, & Premium

### 1. Design Vision (The Anti-Template Blueprint)
EstarKo must feel like a premium, handcrafted product. We strictly avoid the "AI-generated" look by eliminating gradients on buttons, standardizing icons, establishing extreme typographic hierarchy, ensuring every empty/loading state is designed beautifully, and utilizing subtle motion.

### 2. Core Visual Language
*All styling MUST be inherited from `Theme.of(context)` defined in `core/theme.dart`. Random hardcoded colors are strictly forbidden.*

*   **Primary Accent:** Ruby Red (`#E11D48`) - Used strictly for main calls-to-action (e.g., "Request Viewing", active borders). Never use secondary accent colors.
*   **Background (Scaffold):** Off-White (`#FAFAFA`) - A crisp, clean canvas.
*   **Surface:** Pure White (`#FFFFFF`) - Used for elevated cards and bottom sheets.
*   **Text (Primary):** Dark Slate (`#111827`) - For all critical information and big numbers.
*   **Text (Secondary):** Cool Grey (`#6B7280`) - For addresses and subtitles. Keep it quiet.

### 3. Typography & Hierarchy
*   **Font Family:** Plus Jakarta Sans.
*   **Hierarchy Rule:** One element per screen must be massive (e.g., screen title or the monthly price). Everything else must be significantly smaller and lighter. Do not make every line bold.
*   **Grid:** Strict 8-point grid. Standard outer screen padding is `24.0`.

### 4. Iconography & Components
*   **Icons:** Use a single, consistent icon set with uniform line weights (e.g., `Icons.roofing_outlined`). Never use emojis as UI elements.
*   **Border Radius:** `16.0` or `24.0` for structural elements (cards, bottom sheets). `StadiumBorder` (fully rounded pills) for buttons.
*   **Shadows:** Highly diffused to create a "floating" effect: `BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 8))`. Ruby Red buttons should have a soft glowing shadow `Color(0x40E11D48)`.

### 5. Creative Imagery (The Visual Hook)
*   **Header Photography:** Use high-resolution architectural/real estate imagery from Unsplash via `CachedNetworkImage`.
*   **Image Blending:** Images must never have hard bottom edges. Wrap them in a `ShaderMask` with a top-to-bottom `LinearGradient` (Black to Transparent) so they melt smoothly into the `Scaffold` background color.

### 6. States & Motion
*   **All States:** Never show a blank screen with a default spinner. Use the `EstarSkeleton` widget for loading data. Design dedicated empty and error screens.
*   **Tiny Motion:** Elements should not just "appear". Screen contents (lists, forms) must use `flutter_animate` to cascade in with a staggered interval (`100.ms`), fading and sliding up slightly (`fade(duration: 400.ms).slideY(begin: 0.1)`). 

### 7. Implementation Rules for AI Assistants
*   **ALWAYS** use the established components (`EstarButton`, `EstarTextField`, `EstarSkeleton`).
*   **NEVER** invent new colors or typography styles. Stick exclusively to the hierarchy defined above.
*   **ALWAYS** wrap primary page content in entry animations.