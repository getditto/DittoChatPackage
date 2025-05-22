# DittoChat Android Module

This directory contains a minimal Android implementation of the chat
screens written with **Kotlin 2.0** and **Jetpack Compose** using
Material3 components. The code mirrors the functionality of the Swift
package but is tailored for Android apps.

The primary library module lives in `chat/` and depends on the **Ditto SDK**
for persistence and sync. A small sample app in `sample/` allows
standalone testing of the chat UI.

```kotlin
include(":chat")
```

### Features
- `ChatRepository` backed by Ditto
- `ChatViewModel` using `StateFlow`
- `ChatScreen` and `MessageBubble` composables built with Material3
- Sample app prompts for App ID and token before launching chat

This serves as a starting point for integrating Ditto Chat on Android.
