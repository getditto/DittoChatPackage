package com.example.dittochat.repository

import com.example.dittochat.model.ChatUser
import com.example.dittochat.model.Message
import com.example.dittochat.model.MessageWithUser
import com.example.dittochat.model.Room
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import live.ditto.Ditto
import live.ditto.DittoSubscription

class ChatRepository(private val ditto: Ditto) {

    private var subscription: DittoSubscription? = null

    private val _messagesFlow = MutableStateFlow<List<MessageWithUser>>(emptyList())
    val messagesFlow: StateFlow<List<MessageWithUser>> = _messagesFlow.asStateFlow()

    /**
     * Start observing messages for the given room. Messages will be emitted
     * on [messagesFlow]. This mirrors the Swift implementation that observes
     * Ditto queries and converts the database documents to [Message] objects.
     */
    fun observeMessages(room: Room) {
        subscription?.close()
        subscription = ditto.store[room.messagesId].findAll().observe { docs ->
            val msgs = docs.map { Message(it["_id"] as String, room.id, it["userId"] as String, it["text"] as String, it["createdOn"] as Long) }
            val withUsers = msgs.map { msg ->
                val userDoc = ditto.store["users"].findByID(msg.userId).execute()?.value
                val user = if (userDoc != null) {
                    ChatUser(userDoc["_id"] as String, userDoc["firstName"] as String, userDoc["lastName"] as String)
                } else ChatUser(msg.userId, "", "")
                MessageWithUser(msg, user)
            }
            _messagesFlow.value = withUsers
        }
    }

    fun sendMessage(room: Room, user: ChatUser, text: String) {
        val doc = mapOf(
            "_id" to java.util.UUID.randomUUID().toString(),
            "roomId" to room.id,
            "userId" to user.id,
            "text" to text,
            "createdOn" to System.currentTimeMillis()
        )
        ditto.store[room.messagesId].upsert(doc)
    }

    fun createRoom(name: String): Room {
        val id = java.util.UUID.randomUUID().toString()
        val messagesId = "messages_$id"
        val roomDoc = mapOf(
            "_id" to id,
            "name" to name,
            "messagesId" to messagesId
        )
        ditto.store["rooms"].upsert(roomDoc)
        return Room(id = id, name = name, messagesId = messagesId)
    }
}
