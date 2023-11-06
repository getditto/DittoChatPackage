# DittoChatPackage

This chat package allows for a pre canned experience similar to the chat iOS application. There are a few key differences between the package and the 
application. These mainly fall under config as well as what actions are public.

Setup: 

- This package uses SwiftPM to be installed
- Make sure that major versions of Ditto match

Public methods of note:

To setup chat to work in your application:

- DittoInstance.dittoShared = YouDittoInstance
- DataManager.shared = // Your entry point to chat features
- DataManager.shared.publicRoomsPublisher = // The list of chat rooms as a publisher
- public func findPublicRoomById(id: String) -> Room?
- public func createRoom(name: String, isPrivate: Bool) -> DittoDocumentID?
- public func deleteRoom(_ room: Room)
- public func saveCurrentUser(firstName: String, lastName: String) // To set the user if you are managing users and dont need chat to make new ones
- public struct Room // The Room object to work with chat rooms


UI: 

- public struct RoomsListScreen: View // Screen with all rooms on it
- public struct ChatScreen: View // Screen of a specific chat room
