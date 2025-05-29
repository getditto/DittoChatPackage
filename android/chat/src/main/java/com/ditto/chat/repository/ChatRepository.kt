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

class ChatRepository(private val ditto: Ditto) {

    private var liveQuery: DittoLiveQuery? = null

    private val _messagesFlow = MutableStateFlow<List<MessageWithUser>>(emptyList())
    val messagesFlow: StateFlow<List<MessageWithUser>> = _messagesFlow.asStateFlow()

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
                    doc.id.toString(),
                    room.id,
                    doc.value["userId"] as String,
                    doc.value["text"] as String,
                    doc.value["createdOn"] as Long
                )
            }
            val withUsers = msgs.map { msg: Message ->
                val userDoc = ditto.store.collection("users").findById(msg.userId).exec()
                val user = if (userDoc != null) {
                    ChatUser(
                        userDoc.id.toString(),
                        userDoc.value["name"] as? String,
                        userDoc.value["firstName"] as? String,
                        userDoc.value["lastName"] as? String
                    )
                } else ChatUser(msg.userId)
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

    fun createRoom(name: String): Room {
        val id = UUID.randomUUID().toString()
        val messagesId = "messages_$id"
        val roomDoc = mapOf(
            "_id" to id,
            "name" to name,
            "messagesId" to messagesId
        )
        ditto.store.collection("rooms").upsert(roomDoc)
        return Room(id = id, name = name, messagesId = messagesId)
    }
}