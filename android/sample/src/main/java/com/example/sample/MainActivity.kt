package com.example.sample

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.dittochat.model.ChatUser
import com.example.dittochat.model.Room
import com.example.dittochat.repository.ChatRepository
import com.example.dittochat.ui.ChatScreen
import com.example.dittochat.ui.ChatViewModel
import live.ditto.Ditto

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            var appId by remember { mutableStateOf("") }
            var token by remember { mutableStateOf("") }
            var started by remember { mutableStateOf(false) }
            var ditto by remember { mutableStateOf<Ditto?>(null) }
            var viewModel by remember { mutableStateOf<ChatViewModel?>(null) }
            var room by remember { mutableStateOf<Room?>(null) }

            MaterialTheme {
                if (!started) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        OutlinedTextField(
                            value = appId,
                            onValueChange = { appId = it },
                            label = { Text("App ID") },
                            modifier = Modifier.fillMaxWidth()
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        OutlinedTextField(
                            value = token,
                            onValueChange = { token = it },
                            label = { Text("Auth Token") },
                            modifier = Modifier.fillMaxWidth()
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Button(onClick = {
                            ditto = Ditto(appId, token)
                            val repo = ChatRepository(ditto!!)
                            val user = ChatUser("user1", "John", "Doe")
                            viewModel = ChatViewModel(repo, user)
                            room = repo.createRoom("General")
                            started = true
                        }) {
                            Text("Start")
                        }
                    }
                } else {
                    val vm = viewModel!!
                    val r = room!!
                    ChatScreen(room = r, viewModel = vm)
                }
            }
        }
    }
}
