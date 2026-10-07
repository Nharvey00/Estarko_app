# UI_UX_DESIGN_SYSTEM.md
## EstarKo: Secure, Effortless, & Premium

### 1. Design Vision (The App Store Standard)
EstarKo must feel like a premium, resilient product. We actively avoid the "AI-generated" or "student project" look by eliminating gradients, enforcing strict typographic hierarchy, and prioritizing user psychology through safe, predictable, and unbreakable interactions. 

### 2. Core Visual Language
*   **Primary Accent:** Ruby Red (`#E11D48`) - Strictly for main calls-to-action.
*   **Background:** Off-White (`#FAFAFA`).
*   **Surfaces:** Pure White (`#FFFFFF`) with ultra-soft shadows (Blur: 20, Y: 8, Opacity: 4%).
*   **Text:** Dark Slate (`#111827`) for headers; Cool Grey (`#6B7280`) for subtitles.
*   **Icons:** Consistent line-weight icons only (e.g., `Icons.roofing_outlined`). No emojis.

### 3. The 5 Rules of Production UX
1.  **Keyboard-Safe Forms:** Primary buttons must NEVER be hidden by the keyboard. Lock them to the bottom of the screen using `SafeArea` and `bottomNavigationBar`.
2.  **Instant UI Feedback:** Buttons must instantly switch to a loading skeleton/spinner on tap (0ms latency), even if the backend process takes several seconds.
3.  **Friendly Error Masking:** Never expose a raw `500` error or Firebase stack trace. Catch all exceptions in the Provider and display polite, helpful UI messages (e.g., "Check your connection and try again").
4.  **Graceful Offline States:** Never show a blank screen or infinite spinner if a data stream fails. Provide an illustrated empty state with a "Retry" button.
5.  **Store-Ready:** Profile screens must include "Privacy Policy" links and "Delete Account" functions to comply with Apple/Google review guidelines.

### 4. Implementation Rules for AI Assistants
*   **ALWAYS** use the established `EstarButton` and `EstarSkeleton`.
*   **NEVER** place a primary submit button inside a `SingleChildScrollView`. It must be fixed to the bottom.
*   **ALWAYS** wrap screen content in entry animations: `.animate(interval: 100.ms).fade().slideY()`.
*   **NEVER** change underlying business logic, database queries, or routing when updating UI layouts.
*   **NEVER** pass `e.toString()` directly to a SnackBar in production.