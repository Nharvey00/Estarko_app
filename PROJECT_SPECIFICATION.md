# ESTARKO: MASTER PROJECT SPECIFICATION & CONTEXT

## 1. Project Overview & Core Vision
* **App Name:** EstarKo
* **Academic Course:** CCE106/L Project
* **Core Problem Solved:** Eliminates the physical exhaustion and safety risks of manually hunting for boarding houses, dormitories, and apartments. It replaces chaotic, unverified social media housing groups with a moderated, geographically mapped marketplace.
* **Core Value Proposition:** Absolute trust through mandatory admin verification of landlord identity documents, structured scheduling via a 4-stage Viewing Inquiry lifecycle, scoped real-time chat, and an interactive Mapbox discovery canvas.

---

## 2. Tech Stack & Integration Rules
* **Frontend Framework:** Flutter (Dart) using Feature-First MVVM architecture.
* **State Management:** `provider` (ChangeNotifier / ViewModels).
* **Identity & Auth:** Firebase Authentication (Email/Password).
* **Database:** Cloud Firestore (NoSQL, real-time listeners).
* **Media & Image Storage:** Cloudinary REST API (via `http` multipart requests). *Firebase Storage is strictly avoided to bypass Blaze billing requirements.*
* **Image Selection:** `image_picker` (picks device photos to send to Cloudinary).
* **Geographic Mapping:** `mapbox_maps_flutter` (Mapbox Maps SDK). *Google Maps is deprecated to avoid credit card/billing barriers.*

---

## 3. User Roles & Access Control
The application enforces strict role-based access control across three user types:

1. **Tenant (Housing Seeker):**
   * Can browse properties via Feed or Mapbox map.
   * Can open property details and submit a formal Viewing Inquiry with an optional note.
   * Can access the Scoped Chat once an inquiry is created/active.
   * Subject to daily inquiry limits enforced by the Freemium module.
2. **Seller (Landlord / Property Owner):**
   * Must upload a government-issued ID to Cloudinary upon registration.
   * **Gated State:** Blocked from publishing listings until an Admin approves their ID (`isVerified == true`).
   * Can create, edit, and delete property listings with Cloudinary images and Mapbox coordinates.
   * Can manage viewing requests (Approve, Decline, Complete).
   * Subject to active listing limits enforced by the Freemium module.
3. **Admin (Platform Moderator):**
   * Accesses a dedicated moderation dashboard.
   * Reviews pending seller verification submissions (viewing uploaded IDs).
   * Approves or rejects seller verifications, flipping the seller's `isVerified` status in Firestore.

---

## 4. Core Business Logic & Workflows

### A. The Trust & Verification Gateway
1. Seller signs up and is routed to `seller_upload_screen.dart`.
2. Seller selects their government ID using `image_picker`.
3. The image is uploaded directly to Cloudinary via HTTP multipart request (`cloudinary_service.dart`).
4. A document is created in the `verifications` collection with status `pending`.
5. Admin reviews the queue on `admin_dashboard.dart`. Tapping "Approve" sets `verifications.status = 'approved'` and updates the user document `isVerified = true`.
6. Only verified sellers can access listing creation tools.

### B. Property Discovery (Feed & Mapbox)
* **Dual-View Experience:** Tenants switch seamlessly between a Facebook-style vertical card feed and a full-screen interactive Mapbox map.
* **Property Pinning:** Each listing stores latitude and longitude coordinates. Tapping a pin on Mapbox slides up a contextual bottom sheet showing property specs and pricing.

### C. The 4-Stage Viewing Inquiry Lifecycle
Instead of unstructured texting, inquiries follow an explicit status lifecycle:
1. `pending`: Tenant picks a date/time and sends a note. The property badge updates to "Viewing Pending".
2. `confirmed`: Seller accepts the appointment. Scoped Chat unlocks.
3. `completed`: Viewing finished; property status updates.
4. `cancelled`: Either party cancels the visit.

### D. Scoped Real-Time Messaging
* No global inbox. Chat is **strictly scoped** to an active `inquiryId`.
* Messaging rooms exist only within the context of a scheduled property viewing, preventing platform spam and database quota exhaustion.

### E. Freemium Monetization Limits
* **Seller Quota:** Free tier allows up to 1 active listing. Creating additional listings triggers `mock_checkout_screen.dart`.
* **Tenant Quota:** Free tier allows up to 3 viewing inquiries per day.
* **Mock Checkout:** A simulated payment modal where tapping "Pay" resets the respective quota counter in Firestore without real banking APIs.

---

## 5. Cloud Firestore Schema Plan

### Collection: `users`
```json
{
  "uid": "string (matches Auth UID)",
  "name": "string",
  "email": "string",
  "role": "tenant | seller | admin",
  "isVerified": false,
  "inquiryCountToday": 0,
  "activeListingCount": 0,
  "createdAt": "timestamp"
}

Collection: verifications
JSON
{
  "id": "string",
  "sellerId": "string",
  "sellerName": "string",
  "idImageUrl": "string (Cloudinary HTTPS URL)",
  "documentType": "gov_id",
  "status": "pending | approved | rejected",
  "submittedAt": "timestamp"
}
Collection: listings
JSON
{
  "id": "string",
  "sellerId": "string",
  "title": "string",
  "description": "string",
  "monthlyRate": 3500.0,
  "address": "string",
  "latitude": 7.0731,
  "longitude": 125.6128,
  "imageUrls": ["string (Cloudinary URLs)"],
  "amenities": ["WiFi", "Private Bathroom"],
  "isAvailable": true,
  "createdAt": "timestamp"
}
Collection: inquiries
JSON
{
  "id": "string",
  "listingId": "string",
  "listingTitle": "string",
  "tenantId": "string",
  "tenantName": "string",
  "sellerId": "string",
  "scheduledDate": "timestamp",
  "note": "string",
  "status": "pending | confirmed | completed | cancelled",
  "createdAt": "timestamp"
}
Collection: chats (Scoped by inquiryId)
JSON
{
  "inquiryId": "string (matches inquiries.id)",
  "lastMessage": "string",
  "lastUpdated": "timestamp",
  "participants": ["tenantId", "sellerId"]
}
Subcollection: chats/{inquiryId}/messages

JSON
{
  "senderId": "string",
  "text": "string",
  "timestamp": "timestamp"
}
6. Project Architecture & Directory Structure
The application strictly adheres to Feature-First MVVM using provider:

Plaintext
lib/
├── firebase_options.dart               # CLI auto-generated configuration
├── main.dart                           # Entry point, MultiProvider root, Role routing
├── core/
│   ├── constants.dart                  # Mapbox tokens, Cloudinary config, dimensions
│   ├── theme.dart                      # Emerald Teal palette, typography, shapes
│   └── services/
│       └── cloudinary_service.dart     # HTTP multipart image uploader
├── shared/
│   └── widgets/
│       ├── custom_button.dart          # EstarButton (pill shape with loading indicator)
│       └── status_badge.dart           # EstarStatusBadge (pill badge with tinted background)
└── features/
    ├── auth/                           # Identity, authentication, and role routing
    ├── verification/                   # Seller ID upload and Admin review queue
    ├── listings/                       # Seller listing creation and property management
    ├── discovery/                      # Tenant Feed, Mapbox canvas, and Detail screen
    ├── inquiry/                        # 4-stage booking lifecycle and date picker
    ├── chat/                           # Inquiry-scoped real-time messaging
    └── monetization/                   # Mock payment screens and quota limits
7. Phased Implementation Roadmap
Phase 1: Core Design System & Shared UI Toolkit

lib/core/theme.dart, lib/core/constants.dart, lib/shared/widgets/custom_button.dart, lib/shared/widgets/status_badge.dart.

Phase 2: Authentication & Role-Based Gateway

features/auth/ (Login, Register with role toggle, user_model.dart, root redirection in main.dart).

Phase 3: The Trust Layer (Cloudinary Service & Seller Verification)

core/services/cloudinary_service.dart, features/verification/ (seller_upload_screen.dart, admin_dashboard.dart).

Phase 4: Listings & Seller Property Management

features/listings/ (create_listing_screen.dart with image picker & coordinates, seller_dashboard_screen.dart).

Phase 5: Tenant Discovery (Feed & Mapbox Integration)

features/discovery/ (feed_view.dart, map_view.dart using Mapbox SDK, listing_detail_screen.dart).

Phase 6: Viewing Inquiries & Status Lifecycle

features/inquiry/ (inquiry_form_screen.dart bottom sheet, inquiry_list_screen.dart, status updates).

Phase 7: Scoped Real-Time Chat

features/chat/ (Stream-based chat room bound strictly to inquiryId).

Phase 8: Freemium Monetization & Quota Checkouts

features/monetization/ (Limit checks wrapping listing creation and viewing requests).

8. Antigravity Agent Directives & Rules
When implementing code inside this repository, Antigravity must strictly follow these constraints:

Reference Design System: Adhere strictly to UI_UX_DESIGN_SYSTEM.md. Never use generic Material buttons or boxy cards. Use EstarButton, EstarStatusBadge, pill radiuses, and the Emerald Teal palette (#0F766E).

Strict File Boundaries: Only implement files requested in the active phase. Do not jump ahead or write placeholder logic for future phases.

Protected Files: Never delete or overwrite native directories (android/, ios/, etc.) or root Firebase configuration files (firebase_options.dart).

No Direct Database Calls in UI: Views (views/) must only communicate with ViewModels (providers/). Providers handle state and invoke Services (services/). Services communicate with Firebase/Cloudinary.

No Scope Creep: Do not create global chat inboxes, payment gateways beyond the mock checkout, or review/rating systems.