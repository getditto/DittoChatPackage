package com.ditto.chat.sample

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.ditto.chat.model.ChatUser
import com.ditto.chat.model.Room
import com.ditto.chat.repository.ChatRepository
import com.ditto.chat.ui.ChatScreen
import com.ditto.chat.ui.ChatViewModel
import live.ditto.Ditto
import live.ditto.DittoIdentity
import live.ditto.DittoDependencies
import live.ditto.DittoLogLevel
import live.ditto.DittoLogger
import live.ditto.android.AndroidDittoDependencies
import live.ditto.android.DefaultAndroidDittoDependencies
import live.ditto.transports.DittoTransportConfig

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
                            label = { Text("Playground Token") },
                            modifier = Modifier.fillMaxWidth()
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Button(onClick = {
                            DittoLogger.minimumLogLevel = DittoLogLevel.DEBUG

                            val androidDependencies = DefaultAndroidDittoDependencies(applicationContext)

                            // Please get your Ditto App ID and Playground Token from Portal: https://portal.ditto.live/
                            val identity = DittoIdentity.OnlinePlayground(
                                dependencies = androidDependencies,
                                appId = appId,
                                token = token,
                                enableDittoCloudSync = false // Cloud sync is disabled
                            )

                            ditto = Ditto(
                                dependencies = androidDependencies,
                                identity = identity
                            ).apply {
                                // Disable sync with V3 Ditto
                                disableSyncWithV3()
                                // Start sync
                                startSync()
                            }

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