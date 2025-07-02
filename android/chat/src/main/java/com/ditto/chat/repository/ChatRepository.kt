package com.ditto.chat.repository

import com.ditto.chat.model.ChatUser
import com.ditto.chat.model.Message
import com.ditto.chat.model.MessageWithUser
import com.ditto.chat.model.Room
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import live.ditto.Ditto
import live.ditto.DittoDocument
import live.ditto.DittoLiveQuery
import live.ditto.DittoLiveQueryEvent
import java.util.UUID
import java.util.Date

class ChatRepository(private val ditto: Ditto) {

    private var liveQuery: DittoLiveQuery? = null
    private var roomsQuery: DittoLiveQuery? = null

    private val _messagesFlow = MutableStateFlow<List<MessageWithUser>>(emptyList())
    val messagesFlow: StateFlow<List<MessageWithUser>> = _messagesFlow.asStateFlow()

    private val _roomsFlow = MutableStateFlow<List<Room>>(emptyList())
    val roomsFlow: StateFlow<List<Room>> = _roomsFlow.asStateFlow()

    fun observeRooms() {
        roomsQuery?.close()
        roomsQuery = ditto.store.collection("rooms").findAll().observeLocal { docs, _ ->
            val rooms = docs.map { doc ->
                Room(
                    id = doc.id.toString(),
                    name = doc["name"] as? String ?: "",
                    messagesId = doc["messagesId"] as? String ?: "",
                    collectionId = doc["collectionId"] as? String,
                    createdBy = doc["createdBy"] as? String ?: "",
                    createdOn = Date(doc["createdOn"] as? Long ?: System.currentTimeMillis()),
                    isGenerated = doc["isGenerated"] as? Boolean ?: false
                )
            }
            _roomsFlow.value = rooms
        }
    }

    /**
     * Start observing messages for the given room. Messages will be emitted
     * on [messagesFlow]. This mirrors the Swift implementation that observes
     * Ditto queries and converts the database documents to [Message] objects.
     */
    fun observeMessages(room: Room) {
        liveQuery?.close()
        liveQuery = ditto.store.collection(room.messagesId).findAll().observeLocal { docs: List<DittoDocument>, _: DittoLiveQueryEvent ->
            val msgs = docs.map { doc: DittoDocument ->
                Message(
                    id = doc.id.toString(),
                    createdOn = Date(doc.value["createdOn"] as Long),
                    roomId = room.id,
                    text = doc.value["text"] as? String ?: "",
                    userId = doc.value["userId"] as String,
                    largeImageToken = doc.value["largeImageToken"] as? Map<String, Any>,
                    thumbnailImageToken = doc.value["thumbnailImageToken"] as? Map<String, Any>
                )
            }
            val withUsers = msgs.map { msg: Message ->
                val userDoc = ditto.store.collection("users").findById(msg.userId).exec()
                val user = if (userDoc != null) {
                    ChatUser(
                        id = userDoc.id.toString(),
                        firstName = userDoc.value["firstName"] as? String ?: "",
                        lastName = userDoc.value["lastName"] as? String ?: "",
                        subscriptions = emptyMap(),
                        mentions = emptyMap()
                    )
                } else ChatUser.unknownUser().copy(id = msg.userId)
                MessageWithUser(msg, user)
            }
            _messagesFlow.value = withUsers
        }
    }

    fun sendMessage(room: Room, user: ChatUser, text: String) {
        val doc = mapOf(
            "_id" to UUID.randomUUID().toString(),
            "roomId" to room.id,
            "userId" to user.id,
            "text" to text,
            "createdOn" to System.currentTimeMillis()
        )
        ditto.store.collection(room.messagesId).upsert(doc)
    }

    fun sendImageMessage(room: Room, user: ChatUser, uri: String) {
        val doc = mapOf(
            "_id" to UUID.randomUUID().toString(),
            "roomId" to room.id,
            "userId" to user.id,
            "text" to "",
            "createdOn" to System.currentTimeMillis(),
            "largeImageToken" to mapOf("path" to uri),
            "thumbnailImageToken" to mapOf("path" to uri)
        )
        ditto.store.collection(room.messagesId).upsert(doc)
    }

    fun createRoom(name: String, createdBy: String): Room {
        val id = UUID.randomUUID().toString()
        val messagesId = "messages_$id"
        val roomDoc = mapOf(
            "_id" to id,
            "name" to name,
            "messagesId" to messagesId,
            "createdBy" to createdBy,
            "createdOn" to System.currentTimeMillis(),
            "isGenerated" to false
        )
        ditto.store.collection("rooms").upsert(roomDoc)
        return Room(
            id = id,
            name = name,
            messagesId = messagesId,
            collectionId = null,
            createdBy = createdBy,
            createdOn = Date()
        )
    }
}