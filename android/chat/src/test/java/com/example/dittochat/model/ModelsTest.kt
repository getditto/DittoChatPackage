package com.example.dittochat.model

import org.junit.Assert.assertEquals
import org.junit.Test

class ModelsTest {
    @Test
    fun chatUserFullName() {
        val user = ChatUser("1", "Jane", "Doe")
        assertEquals("Jane Doe", user.fullName)
    }

    @Test
    fun roomDefaultMessagesId() {
        val room = Room(id = "abc", name = "General")
        assertEquals("messages_abc", room.messagesId)
    }
}
