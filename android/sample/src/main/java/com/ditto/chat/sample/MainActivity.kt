package com.ditto.chat.sample

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.ditto.chat.model.ChatUser
import com.ditto.chat.model.Room
import com.ditto.chat.repository.ChatRepository
import com.ditto.chat.ui.ChatScreen
import com.ditto.chat.ui.ChatViewModel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import live.ditto.Ditto
import live.ditto.DittoIdentity
import live.ditto.DittoLogLevel
import live.ditto.DittoLogger
import live.ditto.android.DefaultAndroidDittoDependencies
import live.ditto.transports.DittoSyncPermissions

@OptIn(ExperimentalMaterial3Api::class)
class MainActivity : ComponentActivity() {
    companion object {
        private const val TAG = "DittoSample"
    }

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var ditto: Ditto? = null

    private val requestPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) {
            this.ditto?.refreshPermissions()
        }

    fun requestPermissions() {
        val missing = DittoSyncPermissions(this).missingPermissions()
        if (missing.isNotEmpty()) {
            this.requestPermissions(missing, 0)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Use post to ensure Activity is fully created before requesting permissions
        requestPermissions()

        setContent {
            var appId by remember { mutableStateOf(BuildConfig.DITTO_APP_ID) }
            var token by remember { mutableStateOf(BuildConfig.DITTO_TOKEN) }
            var started by remember { mutableStateOf(false) }
            var isLoading by remember { mutableStateOf(false) }
            var viewModel by remember { mutableStateOf<ChatViewModel?>(null) }
            var room by remember { mutableStateOf<Room?>(null) }

            MaterialTheme {
                if (!started) {
                    if (isLoading) {
                        Box(
                            modifier = Modifier.fillMaxSize(),
                            contentAlignment = Alignment.Center
                        ) {
                            Column(
                                horizontalAlignment = Alignment.CenterHorizontally,
                                modifier = Modifier.padding(16.dp)
                            ) {
                                CircularProgressIndicator()
                                Spacer(modifier = Modifier.height(16.dp))
                                Text("Initializing Ditto...")
                                Spacer(modifier = Modifier.height(16.dp))
                                OutlinedButton(onClick = {
                                    Log.d(TAG, "Cancelling Ditto initialization")
                                    isLoading = false
                                    ditto?.let {
                                        Log.d(TAG, "Stopping Ditto sync")
                                        it.stopSync()
                                        ditto = null
                                    }
                                }) {
                                    Text("Cancel")
                                }
                            }
                        }
                    } else {
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
                                scope.launch {
                                    try {
                                        withContext(Dispatchers.IO) {
                                            Log.d(TAG, "Setting Ditto log level to DEBUG")
                                            DittoLogger.minimumLogLevel = DittoLogLevel.DEBUG

                                            Log.d(TAG, "Creating Android dependencies")
                                            val androidDependencies =
                                                DefaultAndroidDittoDependencies(applicationContext)

                                            Log.d(TAG, "Creating Ditto identity with appId: $appId")
                                            val identity = DittoIdentity.OnlinePlayground(
                                                dependencies = androidDependencies,
                                                appId = appId,
                                                token = token,
                                                enableDittoCloudSync = false
                                            )

                                            Log.d(TAG, "Initializing Ditto instance")
                                            val dittoInstance = Ditto(
                                                dependencies = androidDependencies,
                                                identity = identity
                                            )

                                            Log.d(TAG, "Disabling sync with V3 Ditto")
                                            dittoInstance.disableSyncWithV3()

                                            Log.d(TAG, "Starting Ditto sync")
                                            dittoInstance.startSync()

                                            ditto = dittoInstance

                                            Log.d(TAG, "Creating chat repository")
                                            val repo = ChatRepository(dittoInstance)

                                            Log.d(TAG, "Creating user and view model")
                                            val user = ChatUser("user1", "John", "Doe")
                                            viewModel = ChatViewModel(repo, user)

                                            Log.d(TAG, "Creating chat room")
                                            room = repo.createRoom("General", user.id)
                                            repo.createRoom("Random", user.id)
                                        }

                                        Log.d(TAG, "Ditto initialization complete")
                                        isLoading = false
                                        started = true
                                    } catch (e: Exception) {
                                        Log.e(TAG, "Error initializing Ditto", e)
                                        isLoading = false

                                        // Clean up if initialization failed
                                        ditto?.let {
                                            Log.d(TAG, "Stopping Ditto sync due to error")
                                            it.stopSync()
                                            ditto = null
                                        }
                                    }
                                }
                            }) {
                                Text("Start")
                            }
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

    override fun onDestroy() {
        Log.d(TAG, "onDestroy called, stopping Ditto sync")
        ditto?.let {
            Log.d(TAG, "Stopping Ditto sync")
            it.stopSync()
        }
        super.onDestroy()
    }
}