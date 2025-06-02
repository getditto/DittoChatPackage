package com.ditto.chat.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ditto.chat.model.ChatUser
import com.ditto.chat.model.MessageWithUser
import com.ditto.chat.repository.ChatRepository
import com.ditto.chat.model.Room
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class ChatViewModel(
    private val repository: ChatRepository,
    val currentUser: ChatUser
) : ViewModel() {

    val messages: StateFlow<List<MessageWithUser>> = repository.messagesFlow
    val rooms: StateFlow<List<Room>> = repository.roomsFlow

    fun observeRooms() {
        repository.observeRooms()
    }

    fun observeMessages(room: Room) {
        repository.observeMessages(room)
    }

    fun sendMessage(room: Room, text: String) {
        viewModelScope.launch {
            repository.sendMessage(room, currentUser, text)
        }
    }

    fun sendImage(room: Room, uri: String) {
        viewModelScope.launch {
            repository.sendImageMessage(room, currentUser, uri)
        }
    }
}
