/*
 * SPDX-FileCopyrightText: 2015 The CyanogenMod Project
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.settings.device

import android.app.Service
import android.content.Intent
import android.content.SharedPreferences
import android.content.SharedPreferences.OnSharedPreferenceChangeListener
import android.os.IBinder
import android.util.Log
import androidx.preference.PreferenceManager
import org.lineageos.settings.device.actions.ChopForTorch
import org.lineageos.settings.device.actions.FlipToMute
import org.lineageos.settings.device.actions.LiftToSilence
import org.lineageos.settings.device.actions.ProximitySilencer
import org.lineageos.settings.device.actions.UpdatedStateNotifier

class MotoActionsService : Service() {

    private val updatedStateNotifiers = mutableListOf<UpdatedStateNotifier>()

    override fun onCreate() {
        Log.d(TAG, "Starting")

        val sharedPrefs: SharedPreferences =
            PreferenceManager.getDefaultSharedPreferences(this).apply {
                val prefListener = OnSharedPreferenceChangeListener { _, key ->
                    when (key) {
                        MotoActionsSettings.GESTURE_CHOP_CHOP_KEY,
                        MotoActionsSettings.GESTURE_IR_SILENCER_KEY,
                        MotoActionsSettings.GESTURE_FLIP_TO_MUTE_KEY,
                        MotoActionsSettings.GESTURE_LIFT_TO_SILENCE_KEY -> updateState()
                    }
                }
                registerOnSharedPreferenceChangeListener(prefListener)
            }
        val sensorHelper = SensorHelper(this)

        listOf(::ChopForTorch, ::ProximitySilencer, ::FlipToMute, ::LiftToSilence).forEach {
            runCatching { it(this, sharedPrefs, sensorHelper) }
                .onSuccess(updatedStateNotifiers::add)
                .onFailure { e -> Log.e(TAG, "Sensor missing, skipping action", e) }
        }

        updateState()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun updateState() {
        updatedStateNotifiers.forEach { it.updateState() }
    }

    companion object {
        private const val TAG = "MotoActionsService"
    }
}
